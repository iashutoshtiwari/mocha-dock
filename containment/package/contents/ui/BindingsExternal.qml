/*
    SPDX-FileCopyrightText: 2021 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

import org.kde.latte.core as LatteCore
import org.kde.latte.private.containment as LatteContainment

Item {
    property bool updateIsEnabled: autosize.inCalculatedIconSize
                                   && !visibilityManager.inSlidingIn
                                   && !visibilityManager.inSlidingOut
                                   && !visibilityManager.inRelocationHiding

    //! Latte::View Main Bindings 
    Binding{
        target: latteView
        property:"maxThickness"
        restoreMode: Binding.RestoreNone
        //! prevents updating window geometry during closing window in wayland and such fixes a crash
        when: latteView && !visibilityManager.inRelocationHiding && !visibilityManager.inClientSideScreenEdgeSliding //&& !inStartup
        value: root.behaveAsPlasmaPanel ? visibilityManager.thicknessAsPanel : metrics.maxThicknessForView
    }

    Binding{
        target: latteView
        property:"normalThickness"
        restoreMode: Binding.RestoreNone
        when: latteView && updateIsEnabled
        value: root.behaveAsPlasmaPanel ? visibilityManager.thicknessAsPanel : metrics.mask.screenEdge + metrics.mask.thickness.maxNormalForItemsWithoutScreenEdge
    }

    Binding{
        target: latteView
        property:"maxNormalThickness"
        restoreMode: Binding.RestoreNone
        when: latteView && updateIsEnabled
        value: metrics.mask.thickness.maxNormal
    }

    Binding {
        target: latteView
        property: "headThicknessGap"
        restoreMode: Binding.RestoreNone
        when: latteView && updateIsEnabled && !visibilityManager.inClientSideScreenEdgeSliding
        value: {
            if (root.behaveAsPlasmaPanel || root.viewType === LatteCore.Types.PanelView || (latteView && latteView.byPassWM)) {
                return 0;
            }

            return metrics.maxThicknessForView - metrics.mask.thickness.maxNormalForItems;
        }
    }

    Binding{
        target: latteView
        property: "type"
        restoreMode: Binding.RestoreNone
        when: latteView
        value: root.viewType
    }

    Binding{
        target: latteView
        property: "behaveAsPlasmaPanel"
        restoreMode: Binding.RestoreNone
        when: latteView
        value: root.behaveAsPlasmaPanel
    }

    Binding{
        target: latteView
        property: "fontPixelSize"
        value: Kirigami.Theme.defaultFont.pixelSize
    }

    Binding{
        target: latteView
        property: "maxLength"
        restoreMode: Binding.RestoreNone
        when: latteView
        value: root.maxLengthPerCentage/100
    }

    Binding{
        target: latteView
        property: "offset"
        restoreMode: Binding.RestoreNone
        when: latteView
        value: plasmoid.configuration.offset/100
    }

    Binding{
        target: latteView
        property: "screenEdgeMargin"
        restoreMode: Binding.RestoreNone
        when: latteView
        value: Math.max(0, plasmoid.configuration.screenEdgeMargin)
    }

    Binding{
        target: latteView
        property: "screenEdgeMarginEnabled"
        restoreMode: Binding.RestoreNone
        when: latteView
        value: root.screenEdgeMarginEnabled && !root.hideThickScreenGap
    }

    Binding{
        target: latteView
        property: "alignment"
        restoreMode: Binding.RestoreNone
        when: latteView
        value: myView.alignment
    }

    Binding{
        target: latteView
        property: "isTouchingTopViewAndIsBusy"
        restoreMode: Binding.RestoreNone
        when: root.viewIsAvailable
        value: {
            if (!root.viewIsAvailable) {
                return false;
            }

            var isTouchingTopScreenEdge = (latteView.y === latteView.screenGeometry.y);
            var isStickedOnTopBorder = (plasmoid.configuration.alignment === LatteCore.Types.Justify && plasmoid.configuration.maxLength===100)
                    || (plasmoid.configuration.alignment === LatteCore.Types.Top && plasmoid.configuration.offset===0);

            return root.isVertical && !latteView.visibility.isHidden && !isTouchingTopScreenEdge && isStickedOnTopBorder && background.isShown;
        }
    }

    Binding{
        target: latteView
        property: "isTouchingBottomViewAndIsBusy"
        restoreMode: Binding.RestoreNone
        when: latteView
        value: {
            if (!root.viewIsAvailable) {
                return false;
            }

            var latteBottom = latteView.y + latteView.height;
            var screenBottom = latteView.screenGeometry.y + latteView.screenGeometry.height;
            var isTouchingBottomScreenEdge = (latteBottom === screenBottom);

            var isStickedOnBottomBorder = (plasmoid.configuration.alignment === LatteCore.Types.Justify && plasmoid.configuration.maxLength===100)
                    || (plasmoid.configuration.alignment === LatteCore.Types.Bottom && plasmoid.configuration.offset===0);

            return root.isVertical && !latteView.visibility.isHidden && !isTouchingBottomScreenEdge && isStickedOnBottomBorder && background.isShown;
        }
    }

    Binding{
        target: latteView
        property: "colorizer"
        restoreMode: Binding.RestoreNone
        when: latteView
        value: colorizerManager
    }

    Binding{
        target: latteView
        property: "metrics"
        restoreMode: Binding.RestoreNone
        when: latteView
        value: metrics
    }

    //! View::Effects bindings
    Binding{
        target: latteView && latteView.effects ? latteView.effects : null
        property: "backgroundAllCorners"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.effects
        value: plasmoid.configuration.backgroundAllCorners
               && (!root.screenEdgeMarginEnabled /*no-floating*/
                   || (root.screenEdgeMarginEnabled /*floating with justify alignment and 100% maxlength*/
                       && plasmoid.configuration.maxLength===100
                       && myView.alignment===LatteCore.Types.Justify
                       && !root.hideLengthScreenGaps))
    }

    Binding{
        target: latteView && latteView.effects ? latteView.effects : null
        property: "backgroundRadius"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.effects
        value: background.customRadius
    }

    Binding{
        target: latteView && latteView.effects ? latteView.effects : null
        property: "backgroundRadiusEnabled"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.effects
        value: background.customRadiusIsEnabled
    }

    Binding{
        target: latteView && latteView.effects ? latteView.effects : null
        property: "backgroundOpacity"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.effects
        value: plasmoid.configuration.panelTransparency===-1 /*Default option*/ ? -1 : background.currentOpacity
    }

    Binding{
        target: latteView && latteView.effects ? latteView.effects : null
        property: "drawEffects"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.effects && !root.inStartup
        value: LatteCore.WindowSystem.compositingActive
               && (((root.blurEnabled && root.useThemePanel) || (root.blurEnabled && root.forceSolidPanel))
                   && (!root.inStartup || visibilityManager.inRelocationHiding))
    }

    Binding{
        target: latteView && latteView.effects ? latteView.effects : null
        property: "drawShadows"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.effects
        value: root.drawShadowsExternal && (!root.inStartup || visibilityManager.inRelocationHiding) && !(latteView && latteView.visibility.isHidden)
    }

    Binding{
        target: latteView && latteView.effects ? latteView.effects : null
        property:"editShadow"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.effects
        value: root.editShadow
    }

    Binding{
        target: latteView && latteView.effects ? latteView.effects : null
        property:"innerShadow"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.effects
        value: background.shadows.headThickness
    }

    Binding{
        target: latteView && latteView.effects ? latteView.effects : null
        property: "panelBackgroundSvg"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.effects
        value: background.panelBackgroundSvg
    }

    Binding{
        target: latteView && latteView.effects ? latteView.effects : null
        property:"appletsLayoutGeometry"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.effects && visibilityManager.inNormalState
        value: {
            if (root.behaveAsPlasmaPanel
                    || !LatteCore.WindowSystem.compositingActive
                    || (!parabolic.isEnabled && root.userShowPanelBackground && plasmoid.configuration.panelSize===100)) {
                var paddingtail = background.tailRoundness + background.tailRoundnessMargin;
                var paddinghead = background.headRoundness + background.headRoundnessMargin;

                if (root.isHorizontal) {
                    return Qt.rect(latteView.localGeometry.x + paddingtail,
                                   latteView.localGeometry.y,
                                   latteView.localGeometry.width - paddingtail - paddinghead,
                                   latteView.localGeometry.height);
                } else {
                    return Qt.rect(latteView.localGeometry.x,
                                   latteView.localGeometry.y + paddingtail,
                                   latteView.localGeometry.width,
                                   latteView.localGeometry.height - paddingtail - paddinghead);
                }
            }

            return Qt.rect(-1, -1, 0, 0);
        }
    }

    //! View::Positioner bindings
    Binding{
        target: latteView && latteView.positioner ? latteView.positioner : null
        property: "isStickedOnTopEdge"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.positioner
        value: plasmoid.configuration.isStickedOnTopEdge
    }

    Binding{
        target: latteView && latteView.positioner ? latteView.positioner : null
        property: "isStickedOnBottomEdge"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.positioner
        value: plasmoid.configuration.isStickedOnBottomEdge
    }

    //! View::VisibilityManager
    Binding{
        target: latteView && latteView.visibility ? latteView.visibility : null
        property: "isShownFully"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.visibility
        value: myView.isShownFully
    }

    Binding{
        target: latteView && latteView.visibility ? latteView.visibility : null
        property: "strutsThickness"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.visibility
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
        target: latteView && latteView.visibility ? latteView.visibility : null
        property: "isFloatingGapWindowEnabled"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.visibility
        value: root.hasFloatingGapInputEventsDisabled
               && (latteView.visibility.mode === LatteCore.Types.AutoHide
                   || latteView.visibility.mode === LatteCore.Types.DodgeActive
                   || latteView.visibility.mode === LatteCore.Types.DodgeAllWindows
                   || latteView.visibility.mode === LatteCore.Types.DodgeMaximized
                   || latteView.visibility.mode === LatteCore.Types.SidebarAutoHide)
    }

    //! View::WindowsTracker bindings
    Binding{
        target: latteView && latteView.windowsTracker ? latteView.windowsTracker : null
        property: "enabled"
        restoreMode: Binding.RestoreNone
        //! During startup phase windows tracking is not enabled and does not
        //! influence startup sequence at all. At the same time no windows tracking
        //! takes place during startup and as such startup time is reduced
        when: latteView && latteView.windowsTracker && latteView.visibility && !root.inStartup
        value: (latteView && latteView.visibility
                && !(latteView.visibility.mode === LatteCore.Types.AlwaysVisible /* Visibility */
                     || latteView.visibility.mode === LatteCore.Types.WindowsGoBelow
                     || latteView.visibility.mode === LatteCore.Types.AutoHide))
               || indexer.clientsTrackingWindowsCount  > 0                   /*Applets Need Windows Tracking */
               || root.dragActiveWindowEnabled                               /*Dragging Active Window(Empty Areas)*/
               || ((root.backgroundOnlyOnMaximized                           /*Dynamic Background */
                    || plasmoid.configuration.solidBackgroundForMaximized
                    || root.disablePanelShadowMaximized
                    || root.windowColors !== LatteContainment.Types.NoneWindowColors))
               || (root.screenEdgeMarginsEnabled                             /*Dynamic Screen Edge Margin*/
                   && plasmoid.configuration.hideFloatingGapForMaximized)
    }

    //! View::ExtendedInterface bindings
    Binding{
        target: latteView && latteView.extendedInterface ? latteView.extendedInterface : null
        property: "plasmoid"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.extendedInterface
        value: plasmoid
    }

    Binding{
        target: latteView && latteView.extendedInterface ? latteView.extendedInterface : null
        property: "layoutManager"
        restoreMode: Binding.RestoreNone
        when: latteView && latteView.extendedInterface
        value: fastLayoutManager
    }
}
