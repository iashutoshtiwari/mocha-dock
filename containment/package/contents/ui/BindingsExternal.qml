/*
    SPDX-FileCopyrightText: 2021 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

import org.kde.mocha.core as MochaCore
import org.kde.mocha.private.containment as MochaContainment

Item {
    property bool updateIsEnabled: autosize.inCalculatedIconSize
                                   && !visibilityManager.inSlidingIn
                                   && !visibilityManager.inSlidingOut
                                   && !visibilityManager.inRelocationHiding

    //! Mocha::View Main Bindings 
    Binding{
        target: mochaView
        property:"maxThickness"
        restoreMode: Binding.RestoreNone
        //! prevents updating window geometry during closing window in wayland and such fixes a crash
        when: mochaView && !visibilityManager.inRelocationHiding && !visibilityManager.inClientSideScreenEdgeSliding //&& !inStartup
        value: root.behaveAsPlasmaPanel ? visibilityManager.thicknessAsPanel : metrics.maxThicknessForView
    }

    Binding{
        target: mochaView
        property:"normalThickness"
        restoreMode: Binding.RestoreNone
        when: mochaView && updateIsEnabled
        value: root.behaveAsPlasmaPanel ? visibilityManager.thicknessAsPanel : metrics.mask.screenEdge + metrics.mask.thickness.maxNormalForItemsWithoutScreenEdge
    }

    Binding{
        target: mochaView
        property:"maxNormalThickness"
        restoreMode: Binding.RestoreNone
        when: mochaView && updateIsEnabled
        value: metrics.mask.thickness.maxNormal
    }

    Binding {
        target: mochaView
        property: "headThicknessGap"
        restoreMode: Binding.RestoreNone
        when: mochaView && updateIsEnabled && !visibilityManager.inClientSideScreenEdgeSliding
        value: {
            if (root.behaveAsPlasmaPanel || root.viewType === MochaCore.Types.PanelView || (mochaView && mochaView.byPassWM)) {
                return 0;
            }

            return metrics.maxThicknessForView - metrics.mask.thickness.maxNormalForItems;
        }
    }

    Binding{
        target: mochaView
        property: "type"
        restoreMode: Binding.RestoreNone
        when: mochaView
        value: root.viewType
    }

    Binding{
        target: mochaView
        property: "behaveAsPlasmaPanel"
        restoreMode: Binding.RestoreNone
        when: mochaView
        value: root.behaveAsPlasmaPanel
    }

    Binding{
        target: mochaView
        property: "fontPixelSize"
        value: Kirigami.Theme.defaultFont.pixelSize
    }

    Binding{
        target: mochaView
        property: "maxLength"
        restoreMode: Binding.RestoreNone
        when: mochaView
        value: root.maxLengthPerCentage/100
    }

    Binding{
        target: mochaView
        property: "offset"
        restoreMode: Binding.RestoreNone
        when: mochaView
        value: plasmoid.configuration.offset/100
    }

    Binding{
        target: mochaView
        property: "screenEdgeMargin"
        restoreMode: Binding.RestoreNone
        when: mochaView
        value: Math.max(0, plasmoid.configuration.screenEdgeMargin)
    }

    Binding{
        target: mochaView
        property: "screenEdgeMarginEnabled"
        restoreMode: Binding.RestoreNone
        when: mochaView
        value: root.screenEdgeMarginEnabled && !root.hideThickScreenGap
    }

    Binding{
        target: mochaView
        property: "alignment"
        restoreMode: Binding.RestoreNone
        when: mochaView
        value: myView.alignment
    }

    Binding{
        target: mochaView
        property: "isTouchingTopViewAndIsBusy"
        restoreMode: Binding.RestoreNone
        when: root.viewIsAvailable
        value: {
            if (!root.viewIsAvailable) {
                return false;
            }

            var isTouchingTopScreenEdge = (mochaView.y === mochaView.screenGeometry.y);
            var isStickedOnTopBorder = (plasmoid.configuration.alignment === MochaCore.Types.Justify && plasmoid.configuration.maxLength===100)
                    || (plasmoid.configuration.alignment === MochaCore.Types.Top && plasmoid.configuration.offset===0);

            return root.isVertical && !mochaView.visibility.isHidden && !isTouchingTopScreenEdge && isStickedOnTopBorder && background.isShown;
        }
    }

    Binding{
        target: mochaView
        property: "isTouchingBottomViewAndIsBusy"
        restoreMode: Binding.RestoreNone
        when: mochaView
        value: {
            if (!root.viewIsAvailable) {
                return false;
            }

            var mochaBottom = mochaView.y + mochaView.height;
            var screenBottom = mochaView.screenGeometry.y + mochaView.screenGeometry.height;
            var isTouchingBottomScreenEdge = (mochaBottom === screenBottom);

            var isStickedOnBottomBorder = (plasmoid.configuration.alignment === MochaCore.Types.Justify && plasmoid.configuration.maxLength===100)
                    || (plasmoid.configuration.alignment === MochaCore.Types.Bottom && plasmoid.configuration.offset===0);

            return root.isVertical && !mochaView.visibility.isHidden && !isTouchingBottomScreenEdge && isStickedOnBottomBorder && background.isShown;
        }
    }

    Binding{
        target: mochaView
        property: "colorizer"
        restoreMode: Binding.RestoreNone
        when: mochaView
        value: colorizerManager
    }

    Binding{
        target: mochaView
        property: "metrics"
        restoreMode: Binding.RestoreNone
        when: mochaView
        value: metrics
    }

    //! View::Effects bindings
    Binding{
        target: mochaView && mochaView.effects ? mochaView.effects : null
        property: "backgroundAllCorners"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.effects
        value: plasmoid.configuration.backgroundAllCorners
               && (!root.screenEdgeMarginEnabled /*no-floating*/
                   || (root.screenEdgeMarginEnabled /*floating with justify alignment and 100% maxlength*/
                       && plasmoid.configuration.maxLength===100
                       && myView.alignment===MochaCore.Types.Justify
                       && !root.hideLengthScreenGaps))
    }

    Binding{
        target: mochaView && mochaView.effects ? mochaView.effects : null
        property: "backgroundRadius"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.effects
        value: background.customRadius
    }

    Binding{
        target: mochaView && mochaView.effects ? mochaView.effects : null
        property: "backgroundRadiusEnabled"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.effects
        value: background.customRadiusIsEnabled
    }

    Binding{
        target: mochaView && mochaView.effects ? mochaView.effects : null
        property: "backgroundOpacity"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.effects
        value: plasmoid.configuration.panelTransparency===-1 /*Default option*/ ? -1 : background.currentOpacity
    }

    Binding{
        target: mochaView && mochaView.effects ? mochaView.effects : null
        property: "drawEffects"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.effects && !root.inStartup
        value: MochaCore.WindowSystem.compositingActive
               && (((root.blurEnabled && root.useThemePanel) || (root.blurEnabled && root.forceSolidPanel))
                   && (!root.inStartup || visibilityManager.inRelocationHiding))
    }

    Binding{
        target: mochaView && mochaView.effects ? mochaView.effects : null
        property: "drawShadows"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.effects
        value: root.drawShadowsExternal && (!root.inStartup || visibilityManager.inRelocationHiding) && !(mochaView && mochaView.visibility.isHidden)
    }

    Binding{
        target: mochaView && mochaView.effects ? mochaView.effects : null
        property:"editShadow"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.effects
        value: root.editShadow
    }

    Binding{
        target: mochaView && mochaView.effects ? mochaView.effects : null
        property:"innerShadow"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.effects
        value: background.shadows.headThickness
    }

    Binding{
        target: mochaView && mochaView.effects ? mochaView.effects : null
        property: "panelBackgroundSvg"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.effects
        value: background.panelBackgroundSvg
    }

    Binding{
        target: mochaView && mochaView.effects ? mochaView.effects : null
        property:"appletsLayoutGeometry"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.effects && visibilityManager.inNormalState
        value: {
            if (root.behaveAsPlasmaPanel
                    || !MochaCore.WindowSystem.compositingActive
                    || (!parabolic.isEnabled && root.userShowPanelBackground && plasmoid.configuration.panelSize===100)) {
                var paddingtail = background.tailRoundness + background.tailRoundnessMargin;
                var paddinghead = background.headRoundness + background.headRoundnessMargin;

                if (root.isHorizontal) {
                    return Qt.rect(mochaView.localGeometry.x + paddingtail,
                                   mochaView.localGeometry.y,
                                   mochaView.localGeometry.width - paddingtail - paddinghead,
                                   mochaView.localGeometry.height);
                } else {
                    return Qt.rect(mochaView.localGeometry.x,
                                   mochaView.localGeometry.y + paddingtail,
                                   mochaView.localGeometry.width,
                                   mochaView.localGeometry.height - paddingtail - paddinghead);
                }
            }

            return Qt.rect(-1, -1, 0, 0);
        }
    }

    //! View::Positioner bindings
    Binding{
        target: mochaView && mochaView.positioner ? mochaView.positioner : null
        property: "isStickedOnTopEdge"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.positioner
        value: plasmoid.configuration.isStickedOnTopEdge
    }

    Binding{
        target: mochaView && mochaView.positioner ? mochaView.positioner : null
        property: "isStickedOnBottomEdge"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.positioner
        value: plasmoid.configuration.isStickedOnBottomEdge
    }

    //! View::VisibilityManager
    Binding{
        target: mochaView && mochaView.visibility ? mochaView.visibility : null
        property: "isShownFully"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.visibility
        value: myView.isShownFully
    }

    Binding{
        target: mochaView && mochaView.visibility ? mochaView.visibility : null
        property: "strutsThickness"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.visibility
        value: {
            var isCapableToHideScreenGap = root.screenEdgeMarginEnabled && plasmoid.configuration.hideFloatingGapForMaximized
            var mirrorGapFactor = root.mirrorScreenGap ? 2 : 1;

            //! Hide Thickness Screen Gap scenario provides two different struts thicknesses.
            //! [1] The first struts thickness is when there is no maximized window and is such case
            //!     the view is behaving as in normal AlwaysVisible visibility mode. This is very useful
            //!     when users tile windows. [bug #432122]
            //! [2] The second struts thickness is when there is a maximized window present and in such case
            //!     the view is hiding all of its screen edges. It is used mostly when the view is wanted
            //!     to act as a window titlebar.
            var thicknessForIsCapableToHideScreenGap = (root.hideThickScreenGap ? 0 : mirrorGapFactor * metrics.mask.screenEdge);

            if (root.behaveAsPlasmaPanel) {
                return isCapableToHideScreenGap ?
                            (visibilityManager.thicknessAsPanel + thicknessForIsCapableToHideScreenGap) :
                            (mirrorGapFactor*metrics.mask.screenEdge) + visibilityManager.thicknessAsPanel;
            }

            var edgeThickness = isCapableToHideScreenGap ? thicknessForIsCapableToHideScreenGap : metrics.mask.screenEdge * mirrorGapFactor;
            return edgeThickness + metrics.mask.thickness.maxNormalForItemsWithoutScreenEdge;
        }
    }

    Binding {
        target: mochaView && mochaView.visibility ? mochaView.visibility : null
        property: "isFloatingGapWindowEnabled"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.visibility
        value: root.hasFloatingGapInputEventsDisabled
               && (mochaView.visibility.mode === MochaCore.Types.AutoHide
                   || mochaView.visibility.mode === MochaCore.Types.DodgeActive
                   || mochaView.visibility.mode === MochaCore.Types.DodgeAllWindows
                   || mochaView.visibility.mode === MochaCore.Types.DodgeMaximized
                   || mochaView.visibility.mode === MochaCore.Types.SidebarAutoHide)
    }

    //! View::WindowsTracker bindings
    Binding{
        target: mochaView && mochaView.windowsTracker ? mochaView.windowsTracker : null
        property: "enabled"
        restoreMode: Binding.RestoreNone
        //! During startup phase windows tracking is not enabled and does not
        //! influence startup sequence at all. At the same time no windows tracking
        //! takes place during startup and as such startup time is reduced
        when: mochaView && mochaView.windowsTracker && mochaView.visibility && !root.inStartup
        value: (mochaView && mochaView.visibility
                && !(mochaView.visibility.mode === MochaCore.Types.AlwaysVisible /* Visibility */
                     || mochaView.visibility.mode === MochaCore.Types.WindowsGoBelow
                     || mochaView.visibility.mode === MochaCore.Types.AutoHide))
               || indexer.clientsTrackingWindowsCount  > 0                   /*Applets Need Windows Tracking */
               || root.dragActiveWindowEnabled                               /*Dragging Active Window(Empty Areas)*/
               || ((root.backgroundOnlyOnMaximized                           /*Dynamic Background */
                    || plasmoid.configuration.solidBackgroundForMaximized
                    || root.disablePanelShadowMaximized
                    || root.windowColors !== MochaContainment.Types.NoneWindowColors))
               || (root.screenEdgeMarginsEnabled                             /*Dynamic Screen Edge Margin*/
                   && plasmoid.configuration.hideFloatingGapForMaximized)
    }

    //! View::ExtendedInterface bindings
    Binding{
        target: mochaView && mochaView.extendedInterface ? mochaView.extendedInterface : null
        property: "plasmoid"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.extendedInterface
        value: plasmoid
    }

    Binding{
        target: mochaView && mochaView.extendedInterface ? mochaView.extendedInterface : null
        property: "layoutManager"
        restoreMode: Binding.RestoreNone
        when: mochaView && mochaView.extendedInterface
        value: fastLayoutManager
    }
}
