/*
    SPDX-FileCopyrightText: 2016 Smith AR <audoban@openmailbox.org>
    SPDX-FileCopyrightText: 2016 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

import org.kde.mocha.core as MochaCore
import org.kde.mocha.components as MochaComponents
import org.kde.mocha.private.containment as MochaContainment

import "../../controls" as MochaExtraControls

PlasmaComponents.Page {
    id: page
    width: content.width + content.Layout.leftMargin * 2
    height: content.height + Kirigami.Units.smallSpacing * 2

    ColumnLayout {
        id: content       
        width: (dialog.appliedWidth - Kirigami.Units.smallSpacing * 2) - Layout.leftMargin * 2
        spacing: dialog.subGroupSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.leftMargin: Kirigami.Units.smallSpacing * 2

        //! BEGIN: Inline Dock/Panel Type, it is used only when the secondary window
        //! overlaps the main dock config window
        Loader {
            Layout.fillWidth: true
            active: dialog.advancedLevel && viewConfig.showInlineProperties && viewConfig.isReady
            visible: active

            sourceComponent: ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing

                MochaComponents.Header {
                    text: i18n("Type")
                }

                MochaExtraControls.TypeSelection{
                    id: viewTypeSelection
                    horizontal: true
                }
            }
        }
        //! END: Inline Dock/Panel Type

        //! BEGIN: Location
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing

            MochaComponents.Header {
                text: screenRow.visible ? i18n("Screen") : i18n("Location")
            }

            Connections {
                target: universalSettings
                onScreensCountChanged: screenRow.updateScreens()
            }

            RowLayout {
                id: screenRow
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                Layout.rightMargin: Kirigami.Units.smallSpacing * 3
                spacing: 2
                visible: screensCount > 1 || dialog.advancedLevel

                property int screensCount: 1

                function updateScreens() {
                    screensCount = universalSettings.screens.length;
                    screensModel.clear();

                    var primary = {name: i18n("On Primary Screen"), icon: 'favorite'};
                    screensModel.append(primary);

                    var allscreens = {name: i18n("On All Screens"), icon: 'favorite'};
                    screensModel.append(allscreens);

                    var allsecscreens = {name: i18n("On All Secondary Screens"), icon: 'favorite'};
                    screensModel.append(allsecscreens);

                    //check if the screen exists, it is used in cases Mocha is moving
                    //the view automatically to primaryScreen in order for the user
                    //to has always a view with tasks shown
                    var screenExists = false
                    for (var i = 0; i < universalSettings.screens.length; i++) {
                        if (universalSettings.screens[i].name === mochaView.positioner.currentScreenName) {
                            screenExists = true;
                        }
                    }

                    if (!screenExists && !mochaView.onPrimary) {
                        var scr = {name: mochaView.positioner.currentScreenName, icon: 'view-fullscreen'};
                        screensModel.append(scr);
                    }

                    for (var i = 0; i < universalSettings.screens.length; i++) {
                        var scr = {name: universalSettings.screens[i].name, icon: 'view-fullscreen'};
                        screensModel.append(scr);
                    }

                    if (mochaView.onPrimary && mochaView.screensGroup === MochaCore.Types.SingleScreenGroup) {
                        screenCmb.currentIndex = 0;
                    } else if (mochaView.screensGroup === MochaCore.Types.AllScreensGroup) {
                        screenCmb.currentIndex = 1;
                    } else if (mochaView.screensGroup === MochaCore.Types.AllSecondaryScreensGroup) {
                        screenCmb.currentIndex = 2;
                    } else {
                        screenCmb.currentIndex = screenCmb.findScreen(mochaView.positioner.currentScreenName);
                    }

                    console.log(mochaView.positioner.currentScreenName);
                }

                Connections{
                    target: viewConfig
                    onShowSignal: screenRow.updateScreens();
                }

                ListModel {
                    id: screensModel
                }

                MochaComponents.ComboBox {
                    id: screenCmb
                    Layout.fillWidth: true
                    model: screensModel
                    textRole: "name"
                    iconRole: "icon"

                    Component.onCompleted: screenRow.updateScreens();

                    onActivated: {
                        if (index === 0) { // primary
                            mochaView.positioner.setNextLocation("", MochaCore.Types.SingleScreenGroup, "{primary-screen}", PlasmaCore.Types.Floating, MochaCore.Types.NoneAlignment);
                        } else if (index === 1) { // all screens
                            mochaView.positioner.setNextLocation("", MochaCore.Types.AllScreensGroup, "{primary-screen}", PlasmaCore.Types.Floating, MochaCore.Types.NoneAlignment);
                        } else if (index === 2) { // all secondary screens
                            mochaView.positioner.setNextLocation("", MochaCore.Types.AllSecondaryScreensGroup, "", PlasmaCore.Types.Floating, MochaCore.Types.NoneAlignment);
                        } else if (index>2 && (index !== findScreen(mochaView.positioner.currentScreenName) || mochaView.onPrimary)) {// explicit screen
                            mochaView.positioner.setNextLocation("", MochaCore.Types.SingleScreenGroup, textAt(index), PlasmaCore.Types.Floating, MochaCore.Types.NoneAlignment);
                        }
                    }

                    function findScreen(scrName) {                        
                        for(var i=0; i<screensModel.count; ++i) {
                            if (screensModel.get(i).name === scrName) {
                                return i;
                            }
                        }

                        return 0;
                    }
                }
            }

            RowLayout {
                id: locationLayout
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                Layout.rightMargin: Kirigami.Units.smallSpacing * 2
                Layout.topMargin: screenRow.visible ? Kirigami.Units.smallSpacing : 0
                LayoutMirroring.enabled: false
                spacing: 2

                readonly property int buttonSize: (dialog.optionsWidth - (spacing * 3)) / 4

                ButtonGroup {
                    id: locationGroup
                }

                PlasmaComponents.Button {
                    id: bottomEdgeBtn
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    text: i18nc("bottom location", "Bottom")
                    icon.name: "arrow-down"
                    checked: plasmoid.location === edge
                    checkable: false
                    ButtonGroup.group: locationGroup

                    readonly property int edge: PlasmaCore.Types.BottomEdge

                    onClicked: {
                        //! clicked event is more wayland friendly because it release focus from the button before hiding the window
                        if (viewConfig.isReady && plasmoid.location !== edge) {
                            mochaView.positioner.setNextLocation("", mochaView.screensGroup, "", edge, MochaCore.Types.NoneAlignment);
                        }
                    }
                }
                PlasmaComponents.Button {
                    id: leftEdgeBtn
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    text: i18nc("left location", "Left")
                    icon.name: "arrow-left"
                    checked: plasmoid.location === edge
                    checkable: false
                    ButtonGroup.group: locationGroup

                    readonly property int edge: PlasmaCore.Types.LeftEdge

                    onClicked: {
                        //! clicked event is more wayland friendly because it release focus from the button before hiding the window
                        if (viewConfig.isReady && plasmoid.location !== edge) {
                            mochaView.positioner.setNextLocation("", mochaView.screensGroup, "", edge, MochaCore.Types.NoneAlignment);
                        }
                    }
                }
                PlasmaComponents.Button {
                    id: topEdgeBtn
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    text: i18nc("top location", "Top")
                    icon.name: "arrow-up"
                    checked: plasmoid.location === edge
                    checkable: false
                    ButtonGroup.group: locationGroup

                    readonly property int edge: PlasmaCore.Types.TopEdge

                    onClicked: {
                        //! clicked event is more wayland friendly because it release focus from the button before hiding the window
                        if (viewConfig.isReady && plasmoid.location !== edge) {
                            mochaView.positioner.setNextLocation("", mochaView.screensGroup, "", edge, MochaCore.Types.NoneAlignment);
                        }
                    }
                }
                PlasmaComponents.Button {
                    id: rightEdgeBtn
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    text: i18nc("right location", "Right")
                    icon.name: "arrow-right"
                    checked: plasmoid.location === edge
                    checkable: false
                    ButtonGroup.group: locationGroup

                    readonly property int edge: PlasmaCore.Types.RightEdge

                    onClicked: {
                        //! clicked event is more wayland friendly because it release focus from the button before hiding the window
                        if (viewConfig.isReady && plasmoid.location !== edge) {
                            mochaView.positioner.setNextLocation("", mochaView.screensGroup, "", edge, MochaCore.Types.NoneAlignment);
                        }
                    }
                }
            }
        }
        //! END: Location

        //! BEGIN: Alignment
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            MochaComponents.Header {
                text: i18n("Alignment")
            }

            RowLayout {
                id: alignmentRow
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                Layout.rightMargin: Kirigami.Units.smallSpacing * 2
                LayoutMirroring.enabled: false
                spacing: 2

                readonly property int configAlignment: plasmoid.configuration.alignment
                readonly property int buttonSize: (dialog.optionsWidth - (spacing * 3)) / 4

                ButtonGroup {
                    id: alignmentGroup
                }

                PlasmaComponents.Button {
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    text: panelIsVertical ? i18nc("top alignment", "Top") : i18nc("left alignment", "Left")
                    icon.name: panelIsVertical ? "format-align-vertical-top" : "format-justify-left"
                    checked: parent.configAlignment === alignment
                    checkable: false
                    ButtonGroup.group: alignmentGroup

                    property int alignment: panelIsVertical ? MochaCore.Types.Top : MochaCore.Types.Left

                    onPressedChanged: {
                        if (pressed) {
                            mochaView.positioner.setNextLocation("", mochaView.screensGroup, "", PlasmaCore.Types.Floating, alignment);
                        }
                    }
                }
                PlasmaComponents.Button {
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    text: i18nc("center alignment", "Center")
                    icon.name: panelIsVertical ? "format-align-vertical-center" : "format-justify-center"
                    checked: parent.configAlignment === alignment
                    checkable: false
                    ButtonGroup.group: alignmentGroup

                    property int alignment: MochaCore.Types.Center

                    onPressedChanged: {
                        if (pressed) {
                            mochaView.positioner.setNextLocation("", mochaView.screensGroup, "", PlasmaCore.Types.Floating, alignment);
                        }
                    }
                }
                PlasmaComponents.Button {
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    text: panelIsVertical ? i18nc("bottom alignment", "Bottom") : i18nc("right alignment", "Right")
                    icon.name: panelIsVertical ? "format-align-vertical-bottom" : "format-justify-right"
                    checked: parent.configAlignment === alignment
                    checkable: false
                    ButtonGroup.group: alignmentGroup

                    property int alignment: panelIsVertical ? MochaCore.Types.Bottom : MochaCore.Types.Right

                    onPressedChanged: {
                        if (pressed) {
                            mochaView.positioner.setNextLocation("", mochaView.screensGroup, "", PlasmaCore.Types.Floating, alignment);
                        }
                    }
                }

                PlasmaComponents.Button {
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    text: i18nc("justify alignment", "Justify")
                    icon.name: "format-justify-fill"
                    checked: parent.configAlignment === alignment
                    checkable: false
                    ButtonGroup.group: alignmentGroup

                    property int alignment: MochaCore.Types.Justify

                    onPressedChanged: {
                        if (pressed) {
                            mochaView.positioner.setNextLocation("", mochaView.screensGroup, "", PlasmaCore.Types.Floating, alignment);
                        }
                    }
                }
            }
        }
        //! END: Alignment

        //! BEGIN: Visibility
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            MochaComponents.Header {
                text: i18n("Visibility")
            }

            GridLayout {
                width: parent.width
                rowSpacing: 1
                columnSpacing: 2
                Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                Layout.rightMargin: Kirigami.Units.smallSpacing * 2

                columns: 2

                property int mode: mochaView.visibility.mode
                readonly property int buttonSize: (dialog.optionsWidth - (columnSpacing)) / 2

                ButtonGroup {
                    id: visibilityGroup
                }

                PlasmaComponents.Button {
                    id:alwaysVisibleBtn
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    text: i18n("Always Visible")
                    checked: parent.mode === mode
                    checkable: false
                    ButtonGroup.group: visibilityGroup

                    property int mode: MochaCore.Types.AlwaysVisible

                    onPressedChanged: {
                        if (pressed) {
                            mochaView.visibility.mode = mode;
                        }
                    }
                }
                PlasmaComponents.Button {
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    text: i18n("Auto Hide")
                    checked: parent.mode === mode
                    checkable: false
                    ButtonGroup.group: visibilityGroup

                    property int mode: MochaCore.Types.AutoHide

                    onPressedChanged: {
                        if (pressed) {
                            mochaView.visibility.mode = mode;
                        }
                    }
                }
                PlasmaComponents.Button {
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    text: i18n("Dodge Active")
                    checked: parent.mode === mode
                    checkable: false
                    ButtonGroup.group: visibilityGroup

                    property int mode: MochaCore.Types.DodgeActive

                    onPressedChanged: {
                        if (pressed) {
                            mochaView.visibility.mode = mode;
                        }
                    }
                }

                MochaExtraControls.CustomVisibilityModeButton {
                    id: dodgeModeBtn
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    implicitWidth: alwaysVisibleBtn.implicitWidth
                    implicitHeight: alwaysVisibleBtn.implicitHeight

                    checked: parent.mode === mode
                    ButtonGroup.group:  visibilityGroup

                    mode: plasmoid.configuration.lastDodgeVisibilityMode
                    modes: [
                        {
                            pluginId: MochaCore.Types.DodgeMaximized,
                            name: i18n("Dodge Maximized"),
                            tooltip: ""
                        },
                        {
                            pluginId: MochaCore.Types.DodgeAllWindows,
                            name: i18n("Dodge All Windows"),
                            tooltip: ""
                        }
                    ]

                    onViewRelevantVisibilityModeChanged: plasmoid.configuration.lastDodgeVisibilityMode = mochaView.visibility.mode;
                }

                MochaExtraControls.CustomVisibilityModeButton {
                    id: windowsModeBtn
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    implicitWidth: alwaysVisibleBtn.implicitWidth
                    implicitHeight: alwaysVisibleBtn.implicitHeight

                    checked: parent.mode === mode
                    ButtonGroup.group:  visibilityGroup

                    mode: plasmoid.configuration.lastWindowsVisibilityMode
                    modes: [
                        {
                            pluginId: MochaCore.Types.WindowsGoBelow,
                            name: i18n("Windows Go Below"),
                            tooltip: ""
                        },
                        {
                            pluginId: MochaCore.Types.WindowsCanCover,
                            name: i18n("Windows Can Cover"),
                            tooltip: ""
                        },
                        {
                            pluginId: MochaCore.Types.WindowsAlwaysCover,
                            name: i18n("Windows Always Cover"),
                            tooltip: ""
                        }
                    ]

                    onViewRelevantVisibilityModeChanged: plasmoid.configuration.lastWindowsVisibilityMode = mochaView.visibility.mode;
                }

                MochaExtraControls.CustomVisibilityModeButton {
                    id: sidebarModeBtn
                    Layout.minimumWidth: parent.buttonSize
                    Layout.maximumWidth: Layout.minimumWidth
                    implicitWidth: alwaysVisibleBtn.implicitWidth
                    implicitHeight: alwaysVisibleBtn.implicitHeight

                    checked: parent.mode === mode
                    ButtonGroup.group:  visibilityGroup

                    mode: plasmoid.configuration.lastSidebarVisibilityMode
                    modes: [
                        {
                            pluginId: MochaCore.Types.SidebarOnDemand,
                            name: i18n("On Demand Sidebar"),
                            tooltip: i18n("Sidebar can be shown and become hidden only through an external applet, shortcut or script")
                        },
                        {
                            pluginId: MochaCore.Types.SidebarAutoHide,
                            name: i18n("Auto Hide Sidebar"),
                            tooltip: i18n("Sidebar can be shown only through an external applet, shortcut or script but it can also autohide itself when it does not contain mouse")
                        }
                    ]

                    onViewRelevantVisibilityModeChanged: plasmoid.configuration.lastSidebarVisibilityMode = mochaView.visibility.mode;
                }

            }
        }
        //! END: Visibility

        //! BEGIN: Delay
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            enabled: !(mochaView.visibility.mode === MochaCore.Types.AlwaysVisible
                       || mochaView.visibility.mode === MochaCore.Types.WindowsGoBelow
                       || mochaView.visibility.mode === MochaCore.Types.WindowsAlwaysCover
                       || mochaView.visibility.mode === MochaCore.Types.SidebarOnDemand)

            MochaComponents.Header {
                text: i18n("Delay")
            }

            Flow {
                width: dialog.optionsWidth
                Layout.minimumWidth: dialog.optionsWidth
                Layout.maximumWidth: dialog.optionsWidth
                Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                Layout.rightMargin: Kirigami.Units.smallSpacing * 2
                Layout.topMargin: Kirigami.Units.smallSpacing

                spacing: 2

                readonly property bool overlap: showContainer.overlap || hideContainer.overlap

                Item {
                    id: showContainer
                    width: parent.overlap ? dialog.optionsWidth : oneLineWidth
                    height: childrenRect.height
                    implicitWidth: width
                    implicitHeight: height

                    readonly property bool overlap: oneLineWidth > alwaysVisibleBtn.width
                    readonly property int oneLineWidth: Math.max(alwaysVisibleBtn.width, showTimerRow.width)

                    RowLayout{
                        id: showTimerRow
                        anchors.horizontalCenter: parent.horizontalCenter
                        enabled: mochaView.visibility.mode !== MochaCore.Types.SidebarAutoHide
                        PlasmaComponents.Label {
                            Layout.leftMargin: Qt.application.layoutDirection === Qt.RightToLeft ? Kirigami.Units.smallSpacing : 0
                            Layout.rightMargin: Qt.application.layoutDirection === Qt.RightToLeft ? 0 : Kirigami.Units.smallSpacing
                            text: i18n("Show ")
                        }

                        MochaComponents.TextField {
                            Layout.preferredWidth: implicitWidth
                            text: mochaView.visibility.timerShow

                            onValueChanged: {
                                mochaView.visibility.timerShow = value
                            }
                        }
                    }
                }

                Item {
                    id: hideContainer
                    width: parent.overlap ? dialog.optionsWidth : oneLineWidth
                    height: childrenRect.height
                    implicitWidth: width
                    implicitHeight: height

                    readonly property bool overlap: oneLineWidth > alwaysVisibleBtn.width
                    readonly property int oneLineWidth: Math.max(alwaysVisibleBtn.width, hideTimerRow.width)

                    RowLayout {
                        id: hideTimerRow
                        anchors.horizontalCenter: parent.horizontalCenter

                        PlasmaComponents.Label {
                            Layout.leftMargin: Qt.application.layoutDirection === Qt.RightToLeft ? Kirigami.Units.smallSpacing : 0
                            Layout.rightMargin: Qt.application.layoutDirection === Qt.RightToLeft ? 0 : Kirigami.Units.smallSpacing
                            text: i18n("Hide")
                        }

                        MochaComponents.TextField{
                            Layout.preferredWidth: implicitWidth
                            text: mochaView.visibility.timerHide
                            maxValue: 5000

                            onValueChanged: {
                                mochaView.visibility.timerHide = value
                            }
                        }
                    }
                }
            }
        }
        //! END: Delay

        //! BEGIN: Actions
        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            visible: dialog.advancedLevel

            MochaComponents.Header {
                text: i18n("Actions")
            }

            ColumnLayout {
                id: actionsPropertiesColumn
                Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                Layout.rightMargin: Kirigami.Units.smallSpacing * 2
                spacing: 0

                readonly property int maxLabelWidth: Math.max(trackActiveLbl.implicitWidth,
                                                              mouseWheelLbl.implicitWidth,
                                                              leftBtnLbl.implicitWidth,
                                                              midBtnLbl.implicitWidth)

                ColumnLayout {
                    RowLayout {
                        Layout.topMargin: Kirigami.Units.smallSpacing

                        PlasmaComponents.Label {
                            id: trackActiveLbl
                            Layout.minimumWidth: actionsPropertiesColumn.maxLabelWidth
                            Layout.maximumWidth: actionsPropertiesColumn.maxLabelWidth
                            text: i18nc("track active window","Track")
                        }

                        MochaComponents.ComboBox {
                            id: activeWindowFilterCmb
                            Layout.fillWidth: true
                            model: [i18nc("track from current screen", "Active Window From Current Screen"),
                                i18nc("track from all screens", "Active Window From All Screens")]

                            currentIndex: plasmoid.configuration.activeWindowFilter

                            onCurrentIndexChanged: {
                                switch(currentIndex) {
                                case MochaContainment.Types.ActiveInCurrentScreen:
                                    plasmoid.configuration.activeWindowFilter = MochaContainment.Types.ActiveInCurrentScreen;
                                    break;
                                case MochaContainment.Types.ActiveFromAllScreens:
                                    plasmoid.configuration.activeWindowFilter = MochaContainment.Types.ActiveFromAllScreens;
                                    break;
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.topMargin: Kirigami.Units.smallSpacing
                    RowLayout {
                        PlasmaComponents.Label {
                            id: leftBtnLbl
                            Layout.minimumWidth: actionsPropertiesColumn.maxLabelWidth
                            Layout.maximumWidth: actionsPropertiesColumn.maxLabelWidth
                            text: i18n("Left Button")
                        }

                        PlasmaComponents.Button {
                            Layout.fillWidth: true
                            text: i18n("Drag Active Window")
                            checkable: true
                            tooltip: i18n("The user can use left mouse button to drag and maximized/restore last active window from empty areas")
                            iconName: "transform-move"

                            readonly property int dragActiveWindowEnabled: plasmoid.configuration.dragActiveWindowEnabled

                            onDragActiveWindowEnabledChanged: checked = dragActiveWindowEnabled

                            onClicked: {
                                plasmoid.configuration.dragActiveWindowEnabled = checked;
                            }
                        }
                    }

                    RowLayout {
                        PlasmaComponents.Label {
                            id: midBtnLbl
                            Layout.minimumWidth: actionsPropertiesColumn.maxLabelWidth
                            Layout.maximumWidth: actionsPropertiesColumn.maxLabelWidth
                            text: i18n("Middle Button")
                        }

                        PlasmaComponents.Button {
                            Layout.fillWidth: true
                            text: i18n("Close Active Window")
                            checkable: true
                            tooltip: i18n("The user can use middle mouse button to close last active window from empty areas")
                            iconName: "window-close"

                            readonly property int closeActiveWindowEnabled: plasmoid.configuration.closeActiveWindowEnabled

                            onCloseActiveWindowEnabledChanged: checked = closeActiveWindowEnabled;

                            onClicked: {
                                plasmoid.configuration.closeActiveWindowEnabled = checked;
                            }
                        }
                    }

                    RowLayout {
                       // Layout.topMargin: Kirigami.Units.smallSpacing

                        PlasmaComponents.Label {
                            id: mouseWheelLbl
                            Layout.minimumWidth: actionsPropertiesColumn.maxLabelWidth
                            Layout.maximumWidth: actionsPropertiesColumn.maxLabelWidth
                            text: i18n("Mouse wheel")
                        }

                        MochaComponents.ComboBox {
                            id: scrollAction
                            Layout.fillWidth: true
                            model: [i18nc("none scroll actions", "No Action"),
                                i18n("Cycle Through Desktops"),
                                i18n("Cycle Through Activities"),
                                i18n("Cycle Through Tasks"),
                                i18n("Cycle And Minimize Tasks")
                            ]

                            currentIndex: plasmoid.configuration.scrollAction

                            onCurrentIndexChanged: {
                                switch(currentIndex) {
                                case MochaContainment.Types.ScrollNone:
                                    plasmoid.configuration.scrollAction = MochaContainment.Types.ScrollNone;
                                    break;
                                case MochaContainment.Types.ScrollDesktops:
                                    plasmoid.configuration.scrollAction = MochaContainment.Types.ScrollDesktops;
                                    break;
                                case MochaContainment.Types.ScrollActivities:
                                    plasmoid.configuration.scrollAction = MochaContainment.Types.ScrollActivities;
                                    break;
                                case MochaContainment.Types.ScrollTasks:
                                    plasmoid.configuration.scrollAction = MochaContainment.Types.ScrollTasks;
                                    break;
                                case MochaContainment.Types.ScrollToggleMinimized:
                                    plasmoid.configuration.scrollAction = MochaContainment.Types.ScrollToggleMinimized;
                                    break;
                                }
                            }
                        }
                    }
                }

                MochaComponents.SubHeader {
                    text: i18n("Items")
                }

                MochaComponents.CheckBoxesColumn {
                    MochaComponents.CheckBox {
                        id: titleTooltipsChk
                        Layout.maximumWidth: dialog.optionsWidth
                        text: i18n("Thin title tooltips on hovering")
                        tooltip: i18n("Show narrow tooltips produced by Mocha for items.\nThese tooltips are not drawn when applets zoom effect is disabled");
                        value: plasmoid.configuration.titleTooltips

                        onClicked: {
                            plasmoid.configuration.titleTooltips = !plasmoid.configuration.titleTooltips;
                        }
                    }

                    MochaComponents.CheckBox {
                        id: mouseWheelChk
                        Layout.maximumWidth: dialog.optionsWidth
                        text: i18n("Expand popup through mouse wheel")
                        tooltip: i18n("Show or Hide applet popup through mouse wheel action")
                        value: plasmoid.configuration.mouseWheelActions
                        visible: dialog.advancedLevel

                        onClicked: {
                            plasmoid.configuration.mouseWheelActions = !plasmoid.configuration.mouseWheelActions;
                        }
                    }

                    MochaComponents.CheckBox {
                        id: autoSizeChk
                        Layout.maximumWidth: dialog.optionsWidth
                        text: i18n("Adjust size automatically when needed")
                        tooltip: i18n("Items decrease their size when exceed maximum length and increase it when they can fit in")
                        value: plasmoid.configuration.autoSizeEnabled
                        visible: dialog.advancedLevel

                        onClicked: {
                            plasmoid.configuration.autoSizeEnabled = !plasmoid.configuration.autoSizeEnabled;
                        }
                    }

                    MochaComponents.CheckBox {
                        Layout.maximumWidth: dialog.optionsWidth
                       // Layout.maximumHeight: mouseWheelChk.height
                        text: i18n("Activate based on position global shortcuts")
                        tooltip: i18n("This view is used for based on position global shortcuts. Take note that only one view can have that option enabled for each layout")
                        value: mochaView.isPreferredForShortcuts || (!mochaView.layout.preferredForShortcutsTouched && mochaView.isHighestPriorityView())

                        onClicked: {
                            mochaView.isPreferredForShortcuts = checked;
                            if (!mochaView.layout.preferredForShortcutsTouched) {
                                mochaView.layout.preferredForShortcutsTouched = true;
                            }
                        }
                    }
                }
            }

            MochaComponents.SubHeader {
                id: floatingSubCategory
                text: i18n("Floating")
                enabled: plasmoid.configuration.screenEdgeMargin >= 0
            }

            MochaComponents.CheckBoxesColumn {
                Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                Layout.rightMargin: Kirigami.Units.smallSpacing * 2
                enabled: floatingSubCategory.enabled

                MochaComponents.CheckBoxesColumn {
                    MochaComponents.CheckBox {
                        Layout.maximumWidth: dialog.optionsWidth
                        text: i18n("Always use floating gap for user interaction")
                        tooltip: i18n("Floating gap is always used for applets and window interaction")
                        value: plasmoid.configuration.floatingInternalGapIsForced
                        enabled: plasmoid.configuration.zoomLevel === 0

                        onClicked: {
                            plasmoid.configuration.floatingInternalGapIsForced = !plasmoid.configuration.floatingInternalGapIsForced;
                        }
                    }

                    MochaComponents.CheckBox {
                        Layout.maximumWidth: dialog.optionsWidth
                        text: i18n("Hide floating gap for maximized windows")
                        tooltip: i18n("Floating gap is disabled when there are maximized windows")
                        value: plasmoid.configuration.hideFloatingGapForMaximized

                        onClicked: {
                            plasmoid.configuration.hideFloatingGapForMaximized = !plasmoid.configuration.hideFloatingGapForMaximized;
                        }
                    }

                    MochaComponents.CheckBox {
                        Layout.maximumWidth: dialog.optionsWidth
                        enabled: plasmoid.configuration.hideFloatingGapForMaximized
                        text: i18n("Delay floating gap hiding until mouse leaves")
                        tooltip: i18n("to avoid clicking on adjacent items accidentally in some cases")
                        value: plasmoid.configuration.floatingGapHidingWaitsMouse

                        onClicked: {
                            plasmoid.configuration.floatingGapHidingWaitsMouse = !plasmoid.configuration.floatingGapHidingWaitsMouse;
                        }
                    }

                    MochaComponents.CheckBox {
                        Layout.maximumWidth: dialog.optionsWidth
                        enabled: mochaView.visibility.mode === MochaCore.Types.AlwaysVisible
                        text: i18n("Mirror floating gap when it is shown")
                        tooltip: i18n("Floating gap is mirrored when it is shown in Always Visible mode")
                        value: plasmoid.configuration.floatingGapIsMirrored

                        onClicked: {
                            plasmoid.configuration.floatingGapIsMirrored = !plasmoid.configuration.floatingGapIsMirrored;
                        }
                    }
                }
            }
        }
        //! END: Actions

        //! BEGIN: Adjust
        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            visible: dialog.advancedLevel
            enabled: !(mochaView.visibility.mode === MochaCore.Types.AlwaysVisible
                       || mochaView.visibility.mode === MochaCore.Types.WindowsGoBelow
                       || mochaView.visibility.mode === MochaCore.Types.WindowsCanCover
                       || mochaView.visibility.mode === MochaCore.Types.WindowsAlwaysCover)

            MochaComponents.Header {
                text: i18n("Environment")
            }

            MochaComponents.CheckBoxesColumn {
                Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                Layout.rightMargin: Kirigami.Units.smallSpacing * 2

                MochaComponents.CheckBox {
                    Layout.maximumWidth: dialog.optionsWidth
                    text: i18n("Activate KWin edge after hiding")
                    tooltip: i18n("After the view becomes hidden, KWin is informed to track user feedback. For example an edge visual hint is shown whenever the mouse approaches the hidden view")
                    enabled: !dialog.viewIsPanel
                             && !mochaView.byPassWM
                             && mochaView.visibility.mode !== MochaCore.Types.SidebarOnDemand
                             && mochaView.visibility.mode !== MochaCore.Types.SidebarAutoHide
                    value: mochaView.visibility.enableKWinEdges

                    onClicked: {
                        mochaView.visibility.enableKWinEdges = !mochaView.visibility.enableKWinEdges;
                    }
                }

                MochaComponents.CheckBox {
                    Layout.maximumWidth: dialog.optionsWidth
                    text: i18n("Can be above fullscreen windows")
                    tooltip: i18n("BypassWindowManagerHint flag for the window. The view will be above all windows even those set as 'Always On Top'")
                    value: mochaView.byPassWM

                    onClicked: {
                        mochaView.byPassWM = !mochaView.byPassWM;
                    }
                }

                MochaComponents.CheckBox {
                    Layout.maximumWidth: dialog.optionsWidth
                    text: i18n("Raise on desktop change")
                    value: mochaView.visibility.raiseOnDesktop

                    onClicked: {
                        mochaView.visibility.raiseOnDesktop = !mochaView.visibility.raiseOnDesktop;
                    }
                }

                MochaComponents.CheckBox {
                    Layout.maximumWidth: dialog.optionsWidth
                    text: i18n("Raise on activity change")
                    value: mochaView.visibility.raiseOnActivity

                    onClicked: {
                        mochaView.visibility.raiseOnActivity = !mochaView.visibility.raiseOnActivity;
                    }
                }
            }
        }
        //! END: Adjust

    }
}
