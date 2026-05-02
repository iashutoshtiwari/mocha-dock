/*
    SPDX-FileCopyrightText: 2016 Smith AR <audoban@openmailbox.org>
    SPDX-FileCopyrightText: 2016 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

import org.kde.mocha.core as MochaCore
import org.kde.mocha.private.containment as MochaContainment

Item{
    id: manager
    anchors.fill: parent

    property QtObject window

    property bool isFloatingInClientSide: !root.behaveAsPlasmaPanel
                                          && screenEdgeMarginEnabled
                                          && !root.floatingInternalGapIsForced
                                          && !inSlidingIn
                                          && !inSlidingOut

    property int animationSpeed: MochaCore.WindowSystem.compositingActive ?
                                     (root.editMode ? 400 : animations.speedFactor.current * 1.62 * animations.duration.large) : 0

    property bool inClientSideScreenEdgeSliding: root.behaveAsDockWithMask && hideThickScreenGap
    property bool inNormalState: ((animations.needBothAxis.count === 0) && (animations.needLength.count === 0))
                                 || (mochaView && mochaView.visibility.isHidden && !mochaView.visibility.containsMouse && animations.needThickness.count === 0)
    property bool inRelocationAnimation: mochaView && mochaView.positioner && mochaView.positioner.inRelocationAnimation

    property bool inSlidingIn: false //necessary because of its init structure
    property alias inSlidingOut: slidingAnimationAutoHiddenOut.running
    property bool inRelocationHiding: false

    readonly property bool isSinkedEventEnabled: !(parabolic.isEnabled && (animations.needBothAxis.count>0 || animations.needLength.count>0))
                                                 && myView.isShownFully

    property int length: root.isVertical ?  Screen.height : Screen.width   //screenGeometry.height : screenGeometry.width

    property int slidingOutToPos: {
        if (root.behaveAsPlasmaPanel) {
            var edgeMargin = screenEdgeMarginEnabled ? plasmoid.configuration.screenEdgeMargin : 0
            var thickmarg = mochaView.visibility.isSidebar ? 0 : 1;

            return root.isHorizontal ? root.height + edgeMargin - thickmarg : root.width + edgeMargin - thickmarg;
        } else {
            var topOrLeftEdge = ((plasmoid.location===PlasmaCore.Types.LeftEdge)||(plasmoid.location===PlasmaCore.Types.TopEdge));
            return (topOrLeftEdge ? -metrics.mask.thickness.normal : metrics.mask.thickness.normal);
        }
    }

    //! when Mocha behaves as Plasma panel
    property int thicknessAsPanel: metrics.totals.thickness

    property Item layouts: null

    property bool updateIsEnabled: autosize.inCalculatedIconSize && !inSlidingIn && !inSlidingOut && !inRelocationHiding

    Connections{
        target: background.totals
        onVisualLengthChanged: updateMaskArea();
        onVisualThicknessChanged: updateMaskArea();
    }

    Connections{
        target: background.shadows
        onHeadThicknessChanged: updateMaskArea();
    }

    Connections{
        target: mochaView ? mochaView : null
        onXChanged: updateMaskArea();
        onYChanged: updateMaskArea()
        onWidthChanged: updateMaskArea();
        onHeightChanged: updateMaskArea();
    }

    Connections{
        target: animations.needBothAxis
        onCountChanged: updateMaskArea();
    }

    Connections{
        target: animations.needLength
        onCountChanged: updateMaskArea();
    }

    Connections{
        target: animations.needThickness
        onCountChanged: updateMaskArea();
    }

    Connections{
        target: layoutsManager
        onCurrentLayoutIsSwitching: {
            if (MochaCore.WindowSystem.compositingActive && mochaView && mochaView.layout && mochaView.layout.name === layoutName) {
                parabolic.sglClearZoom();
            }
        }
    }

    Connections {
        target: metrics.mask.thickness
        onMaxZoomedChanged: updateMaskArea()
    }

    Connections {
        target: root.myView
        onInRelocationAnimationChanged: {
            if (!root.myView.inRelocationAnimation) {
                manager.updateMaskArea();
            }
        }
    }

    Connections {
        target: mochaView ? mochaView.effects : null
        onRectChanged: manager.updateMaskArea()
    }

    Connections{
        target: themeExtended ? themeExtended : null
        onThemeChanged: mochaView.effects.forceMaskRedraw();
    }

    Connections {
        target: MochaCore.WindowSystem
        onCompositingActiveChanged: {
            manager.updateMaskArea();
        }
    }

    onIsFloatingInClientSideChanged: updateMaskArea();

    onInNormalStateChanged: {
        if (inNormalState) {
            updateMaskArea();
        }
    }

    onInSlidingInChanged: {
        if (mochaView && !inSlidingIn && mochaView.positioner.inRelocationShowing) {
            mochaView.positioner.inRelocationShowing = false;
        }
    }

    onUpdateIsEnabledChanged: {
        if (updateIsEnabled) {
            updateMaskArea();
        }
    }

    function slotContainsMouseChanged() {
        if(mochaView.visibility.containsMouse && mochaView.visibility.mode !== MochaCore.Types.SidebarOnDemand) {
            updateMaskArea();

            if (slidingAnimationAutoHiddenOut.running && !inRelocationHiding) {
                slotMustBeShown();
            }
        }
    }

    function slotMustBeShown() {
        if (root.inStartup) {
            slidingAnimationAutoHiddenIn.init();
            return;
        }

        //! WindowsCanCover case
        if (mochaView && mochaView.visibility.mode === MochaCore.Types.WindowsCanCover) {
            mochaView.visibility.setViewOnFrontLayer();
        }

        if (!mochaView.visibility.isHidden && mochaView.positioner.inSlideAnimation) {
            // Do not update when Positioner mid-slide animation takes place, for example:
            // 1. Mocha panel is hiding its floating gap for maximized window
            // 2. the user clicks on an applet popup.
            // 3. Applet popups showing/hiding are triggering hidingIsBlockedChanged() signals.
            // 4. hidingIsBlockedChanged() signals create mustBeShown events when visibility::hidingIsBlocked() is not enabled.
            return;
        }

        //! Normal Dodge/AutoHide case
        if (!slidingAnimationAutoHiddenIn.running
                && !inRelocationHiding
                && (mochaView.visibility.isHidden || slidingAnimationAutoHiddenOut.running /*it is not already shown or is trying to hide*/)){
            slidingAnimationAutoHiddenIn.init();
        }
    }

    function slotMustBeHide() {
        if (root.inStartup) {
            slidingAnimationAutoHiddenOut.init();
            return;
        }

        if (inSlidingIn && !inRelocationHiding) {
            /*consider hiding after sliding in has finished*/
            return;
        }

        if (mochaView && mochaView.visibility.mode === MochaCore.Types.WindowsCanCover) {
            mochaView.visibility.setViewOnBackLayer();
            return;
        }

        //! Normal Dodge/AutoHide case
        if (!slidingAnimationAutoHiddenOut.running
                && !mochaView.visibility.blockHiding
                && (!mochaView.visibility.containsMouse || mochaView.visibility.mode === MochaCore.Types.SidebarOnDemand /*for SidebarOnDemand mouse should be ignored on hiding*/)
                && (!mochaView.visibility.isHidden || slidingAnimationAutoHiddenIn.running /*it is not already hidden or is trying to show*/)) {
            slidingAnimationAutoHiddenOut.init();
        }
    }

    //! functions used for sliding out/in during location/screen changes
    function slotHideDockDuringLocationChange() {
        inRelocationHiding = true;

        if(!slidingAnimationAutoHiddenOut.running) {
            slidingAnimationAutoHiddenOut.init();
        }
    }

    function slotShowDockAfterLocationChange() {
        slidingAnimationAutoHiddenIn.init();
    }

    function sendHideDockDuringLocationChangeFinished(){
        mochaView.positioner.hidingForRelocationFinished();
    }

    function sendSlidingOutAnimationEnded() {
        mochaView.visibility.hide();
        mochaView.visibility.isHidden = true;

        if (debug.maskEnabled) {
            console.log("hiding animation ended...");
        }

        sendHideDockDuringLocationChangeFinished();
    }

    ///test maskArea
    function updateMaskArea() {
        if (!mochaView || !root.viewIsAvailable) {
            return;
        }

        var localX = 0;
        var localY = 0;

        // debug maskArea criteria
        if (debug.maskEnabled) {
            console.log(animations.needBothAxis.count + ", " + animations.needLength.count + ", " +
                        animations.needThickness.count + ", " + mochaView.visibility.isHidden);
        }

        //console.log("reached updating geometry ::: "+dock.maskArea);


        if (!mochaView.visibility.isHidden && updateIsEnabled && inNormalState) {
            //! Important: Local Geometry must not be updated when view ISHIDDEN
            //! because it breaks Dodge(s) modes in such case

            var localGeometry = Qt.rect(0, 0, root.width, root.height);

            //the shadows size must be removed from the maskArea
            //before updating the localDockGeometry
            if (!mochaView.behaveAsPlasmaPanel) {
                var cleanThickness = metrics.totals.thickness;
                var edgeMargin = metrics.mask.screenEdge;

                if (plasmoid.location === PlasmaCore.Types.TopEdge) {
                    localGeometry.x = mochaView.effects.rect.x; // from effects area
                    localGeometry.width = mochaView.effects.rect.width; // from effects area

                    localGeometry.y = edgeMargin;
                    localGeometry.height = cleanThickness;
                } else if (plasmoid.location === PlasmaCore.Types.BottomEdge) {
                    localGeometry.x = mochaView.effects.rect.x; // from effects area
                    localGeometry.width = mochaView.effects.rect.width; // from effects area

                    localGeometry.y = root.height - cleanThickness - edgeMargin;
                    localGeometry.height = cleanThickness;
                } else if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
                    localGeometry.y = mochaView.effects.rect.y; // from effects area
                    localGeometry.height = mochaView.effects.rect.height; // from effects area

                    localGeometry.x = edgeMargin;
                    localGeometry.width = cleanThickness;
                } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
                    localGeometry.y = mochaView.effects.rect.y; // from effects area
                    localGeometry.height = mochaView.effects.rect.height; // from effects area

                    localGeometry.x = root.width - cleanThickness - edgeMargin;
                    localGeometry.width = cleanThickness;
                }

                //set the boundaries for mochaView local geometry
                //qBound = qMax(min, qMin(value, max)).

                localGeometry.x = Math.max(0, Math.min(localGeometry.x, mochaView.width));
                localGeometry.y = Math.max(0, Math.min(localGeometry.y, mochaView.height));
                localGeometry.width = Math.min(localGeometry.width, mochaView.width);
                localGeometry.height = Math.min(localGeometry.height, mochaView.height);
            }

            //console.log("update geometry ::: "+localGeometry);
            mochaView.localGeometry = localGeometry;
        }

        //! Input Mask
        if (updateIsEnabled) {
            updateInputGeometry();
        }
    }

    function updateInputGeometry() {
        // VisibilityManager.qml tries to workaround faulty onEntered() signals from ParabolicMouseArea
        // by specifying inputThickness when ParabolicEffect is applied. (inputThickness->animated scenario)
        var animated = (animations.needBothAxis.count>0);

        if (!MochaCore.WindowSystem.compositingActive || mochaView.behaveAsPlasmaPanel) {
            //! clear input mask
            mochaView.effects.inputMask = Qt.rect(0, 0, -1, -1);
        } else {
            var floatingInternalGapAcceptsInput = behaveAsDockWithMask && floatingInternalGapIsForced;
            var inputThickness;

            if (mochaView.visibility.isHidden) {
                inputThickness = metrics.mask.thickness.hidden;
            } else if (root.hasFloatingGapInputEventsDisabled) {
                inputThickness = animated ? metrics.mask.thickness.zoomedForItems - metrics.margins.screenEdge : metrics.totals.thickness;
            } else {
                inputThickness = animated ? metrics.mask.thickness.zoomedForItems : metrics.mask.screenEdge + metrics.totals.thickness;
            }

            var subtractedScreenEdge = root.hasFloatingGapInputEventsDisabled && !mochaView.visibility.isHidden ? metrics.mask.screenEdge : 0;

            var inputGeometry = Qt.rect(0, 0, root.width, root.height);

            //!use view.localGeometry for length properties
            if (plasmoid.location === PlasmaCore.Types.TopEdge) {
                if (!animated) {
                    inputGeometry.x = mochaView.localGeometry.x;
                    inputGeometry.width = mochaView.localGeometry.width;
                }

                inputGeometry.y = subtractedScreenEdge;
                inputGeometry.height = inputThickness;
            } else if (plasmoid.location === PlasmaCore.Types.BottomEdge) {
                if (!animated) {
                    inputGeometry.x = mochaView.localGeometry.x;
                    inputGeometry.width = mochaView.localGeometry.width;
                }

                inputGeometry.y = root.height - inputThickness - subtractedScreenEdge;
                inputGeometry.height = inputThickness;
            } else if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
                if (!animated) {
                    inputGeometry.y = mochaView.localGeometry.y;
                    inputGeometry.height = mochaView.localGeometry.height;
                }

                inputGeometry.x = subtractedScreenEdge;
                inputGeometry.width = inputThickness;
            } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
                if (!animated) {
                    inputGeometry.y = mochaView.localGeometry.y;
                    inputGeometry.height = mochaView.localGeometry.height;
                }

                inputGeometry.x = root.width - inputThickness - subtractedScreenEdge;
                inputGeometry.width = inputThickness;
            }

            //set the boundaries for mochaView local geometry
            //qBound = qMax(min, qMin(value, max)).

            inputGeometry.x = Math.max(0, Math.min(inputGeometry.x, mochaView.width));
            inputGeometry.y = Math.max(0, Math.min(inputGeometry.y, mochaView.height));
            inputGeometry.width = Math.min(inputGeometry.width, mochaView.width);
            inputGeometry.height = Math.min(inputGeometry.height, mochaView.height);

            if (mochaView.visibility.isSidebar && mochaView.visibility.isHidden) {
                //! this way we make sure than no input is accepted anywhere
                inputGeometry = Qt.rect(-1, -1, 1, 1);
            }

            mochaView.effects.inputMask = inputGeometry;
        }
    }

    Loader{
        anchors.fill: parent
        active: debug.graphicsEnabled

        sourceComponent: Item{
            anchors.fill:parent

            Rectangle{
                id: windowBackground
                anchors.fill: parent
                border.color: "red"
                border.width: 1
                color: "transparent"
            }

            Rectangle{
                x: mochaView ? mochaView.effects.mask.x : -1
                y: mochaView ? mochaView.effects.mask.y : -1
                height: mochaView ? mochaView.effects.mask.height : 0
                width: mochaView ? mochaView.effects.mask.width : 0

                border.color: "green"
                border.width: 1
                color: "transparent"
            }
        }
    }

    /***Hiding/Showing Animations*****/

    //////////////// Animations - Slide In - Out
    SequentialAnimation{
        id: slidingAnimationAutoHiddenOut

        PropertyAnimation {
            target: !root.behaveAsPlasmaPanel ? layoutsContainer : mochaView.positioner
            property: !root.behaveAsPlasmaPanel ? (root.isVertical ? "x" : "y") : "slideOffset"
            to: {
                if (root.behaveAsPlasmaPanel) {
                    return slidingOutToPos;
                }

                if (MochaCore.WindowSystem.compositingActive) {
                    return slidingOutToPos;
                } else {
                    if ((plasmoid.location===PlasmaCore.Types.LeftEdge)||(plasmoid.location===PlasmaCore.Types.TopEdge)) {
                        return slidingOutToPos + 1;
                    } else {
                        return slidingOutToPos - 1;
                    }
                }
            }
            duration: manager.animationSpeed
            easing.type: Easing.InQuad
        }

        ScriptAction{
            script: {
                if (mochaView && mochaView.visibility) {
                    mochaView.visibility.isHidden = true;

                    if (root.behaveAsPlasmaPanel && mochaView.positioner.slideOffset !== 0) {
                        //! hide real panels when they slide-out
                        mochaView.visibility.hide();
                    }
                }
            }
        }

        onStarted: {
            if (debug.maskEnabled) {
                console.log("hiding animation started...");
            }
        }

        onStopped: {
            //! Trying to move the ending part of the signals at the end of editing animation
            if (!manager.inRelocationHiding) {
                manager.updateMaskArea();
            } else {
                if (!root.editMode) {
                    manager.sendSlidingOutAnimationEnded();
                }
            }

            if (mochaView && mochaView.visibility) {
                mochaView.visibility.slideOutFinished();
            }
            manager.updateInputGeometry();

            if (root.inStartup) {
                //! when view is first created slide-outs when that animation ends then
                //! it flags that startup has ended and first slide-in can be started
                //! this is important because if it is removed then some views
                //! wont slide-in after startup.
                root.inStartup = false;
            }
        }

        function init() {
            if (manager.inRelocationAnimation || root.inStartup/*used from recreating views*/ || !mochaView.visibility.blockHiding) {
                start();
            }
        }
    }

    SequentialAnimation{
        id: slidingAnimationAutoHiddenIn

        PauseAnimation{
            duration: manager.inRelocationHiding && animations.active ? 500 : 0
        }

        PropertyAnimation {
            target: !root.behaveAsPlasmaPanel ? layoutsContainer : mochaView.positioner
            property: !root.behaveAsPlasmaPanel ? (root.isVertical ? "x" : "y") : "slideOffset"
            to: 0
            duration: manager.animationSpeed
            easing.type: Easing.OutQuad
        }

        ScriptAction{
            script: {
                // deprecated
                // root.inStartup = false;
            }
        }

        onStarted: {
            mochaView.visibility.show();
            manager.updateInputGeometry();

            if (debug.maskEnabled) {
                console.log("showing animation started...");
            }
        }

        onStopped: {
            inSlidingIn = false;

            if (manager.inRelocationHiding) {
                manager.inRelocationHiding = false;
                autosize.updateIconSize();
            }

            manager.inRelocationHiding = false;
            autosize.updateIconSize();

            if (debug.maskEnabled) {
                console.log("showing animation ended...");
            }

            mochaView.visibility.slideInFinished();

            //! this is needed in order to update dock absolute geometry correctly in the end AND
            //! when a floating dock is sliding-in through masking techniques
            updateMaskArea();
        }

        function init() {
            if (!root.viewIsAvailable) {
                return;
            }

            inSlidingIn = true;

            if (slidingAnimationAutoHiddenOut.running) {
                slidingAnimationAutoHiddenOut.stop();
            }

            mochaView.visibility.isHidden = false;
            updateMaskArea();

            start();
        }
    }

    //! Slides Animations for FLOATING+BEHAVEASPLASMAPANEL when
    //! HIDETHICKSCREENCAP dynamically is enabled/disabled
    SequentialAnimation{
        id: slidingInRealFloating

        PropertyAnimation {
            target: mochaView ? mochaView.positioner : null
            property: "slideOffset"
            to: 0
            duration: manager.animationSpeed
            easing.type: Easing.OutQuad
        }

        ScriptAction{
            script: {
                mochaView.positioner.inSlideAnimation = false;
            }
        }

        onStopped: mochaView.positioner.inSlideAnimation = false;

    }

    SequentialAnimation{
        id: slidingOutRealFloating

        ScriptAction{
            script: {
                mochaView.positioner.inSlideAnimation = true;
            }
        }

        PropertyAnimation {
            target: mochaView ? mochaView.positioner : null
            property: "slideOffset"
            to: plasmoid.configuration.screenEdgeMargin
            duration: manager.animationSpeed
            easing.type: Easing.InQuad
        }
    }

    Connections {
        target: root
        onHideThickScreenGapChanged: {
            if (!mochaView || !root.viewIsAvailable) {
                return;
            }

            if (root.behaveAsPlasmaPanel && !mochaView.visibility.isHidden && !inSlidingIn && !inSlidingOut && !inStartup) {
                slideInOutRealFloating();
            }
        }

        onInStartupChanged: {
            //! used for positioning properly real floating panels when there is a maximized window
            if (root.hideThickScreenGap && !inStartup && mochaView.positioner.slideOffset===0) {
                if (root.behaveAsPlasmaPanel && !mochaView.visibility.isHidden) {
                    slideInOutRealFloating();
                }
            }
        }

        function slideInOutRealFloating() {
            if (root.hideThickScreenGap) {
                slidingInRealFloating.stop();
                slidingOutRealFloating.start();
            } else {
                slidingOutRealFloating.stop();
                slidingInRealFloating.start();
            }
        }
    }


}
