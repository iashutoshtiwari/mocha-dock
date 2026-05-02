/*
    SPDX-FileCopyrightText: 2016 Smith AR <audoban@openmailbox.org>
    SPDX-FileCopyrightText: 2016 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

import org.kde.plasma.plasmoid

import org.kde.mocha.core as MochaCore
import org.kde.mocha.private.containment as MochaContainment

Grid {
    id: typeRow

    width: horizontal ? content.width - 4*Kirigami.Units.smallSpacing : 9 * Kirigami.Theme.defaultFont.pixelSize
    anchors.leftMargin: horizontal ? Kirigami.Units.smallSpacing : 0
    anchors.rightMargin: horizontal ? Kirigami.Units.smallSpacing : 0

    Layout.minimumWidth: width
    Layout.maximumWidth: width
    Layout.minimumHeight: height
    Layout.maximumHeight: height

    Layout.leftMargin: Kirigami.Units.smallSpacing * 2
    Layout.rightMargin: Kirigami.Units.smallSpacing * 2

    rows: horizontal ? 1 : 0
    columns: horizontal ? 0 : 1

    spacing: 1

    verticalItemAlignment: Grid.AlignVCenter

    property bool horizontal: false

    ButtonGroup {
        id: viewTypeGroup
    }

    PlasmaComponents.Button {
        id: dockTypeButton
        width: horizontal ? (parent.width - parent.spacing)/ 2 : parent.width
        enabled: MochaCore.WindowSystem.compositingActive

        checkable: true
        checked: mochaView.type === MochaCore.Types.DockView
        text: i18nc("dock type","Dock")
        ButtonGroup.group: viewTypeGroup
        tooltip: i18n("Change the behavior and appearance to Dock type")

        onPressedChanged: {
            if (pressed && !checked) {
                mochaView.userRequestedViewType(MochaCore.Types.DockView);

                mochaView.visibility.mode = MochaCore.Types.DodgeActive;
                plasmoid.configuration.alignment = MochaCore.Types.Center;
                plasmoid.configuration.useThemePanel = true;
                plasmoid.configuration.solidPanel = false;
                plasmoid.configuration.panelSize = 5;
                plasmoid.configuration.appletShadowsEnabled = true;
                plasmoid.configuration.zoomLevel = 16;
                //plasmoid.configuration.autoDecreaseIconSize = true;

                //! Empty Areas
                plasmoid.configuration.dragActiveWindowEnabled = false;
                plasmoid.configuration.scrollAction = MochaContainment.Types.ScrollNone;

                //! Items
                plasmoid.configuration.autoSizeEnabled = true;

                //! Dynamic Background
                plasmoid.configuration.solidBackgroundForMaximized = false;
                plasmoid.configuration.colorizeTransparentPanels = false;
                plasmoid.configuration.backgroundOnlyOnMaximized = false;
                plasmoid.configuration.disablePanelShadowForMaximized = false;
                plasmoid.configuration.plasmaBackgroundForPopups = false;

                //! Floating
                plasmoid.configuration.floatingInternalGapIsForced = true;
            }
        }
    }

    PlasmaComponents.Button {
        id: panelTypeButton
        width: dockTypeButton.width
        enabled: MochaCore.WindowSystem.compositingActive

        checkable: true
        checked: mochaView.type === MochaCore.Types.PanelView
        text: i18nc("panel type","Panel")
        ButtonGroup.group: viewTypeGroup
        tooltip: i18n("Change the behavior and appearance to Panel type")

        onPressedChanged: {
            if (pressed && !checked) {
                mochaView.userRequestedViewType(MochaCore.Types.PanelView);

                mochaView.visibility.mode = MochaCore.Types.AlwaysVisible;
                plasmoid.configuration.alignment = MochaCore.Types.Justify;
                plasmoid.configuration.useThemePanel = true;
                plasmoid.configuration.solidPanel = false;
                plasmoid.configuration.panelSize = 100;
                plasmoid.configuration.panelShadows = true;
                plasmoid.configuration.appletShadowsEnabled = false;
                plasmoid.configuration.zoomLevel = 0;
                plasmoid.configuration.titleTooltips = false;
                //plasmoid.configuration.autoDecreaseIconSize = false;

                //! Empty Areas
                plasmoid.configuration.dragActiveWindowEnabled = true;

                //! Items
                plasmoid.configuration.autoSizeEnabled = false;

                //! Dynamic Background
                plasmoid.configuration.colorizeTransparentPanels = false;
                plasmoid.configuration.backgroundOnlyOnMaximized = false;
                plasmoid.configuration.disablePanelShadowForMaximized = false;
                plasmoid.configuration.plasmaBackgroundForPopups = true;

                //! Floating
                plasmoid.configuration.floatingInternalGapIsForced = false;

                //! Custom Background that overrides Plasma Theme metrics
                plasmoid.configuration.backgroundRadius = -1;
                plasmoid.configuration.backgroundShadowSize = -1;
            }
        }
    }
}

