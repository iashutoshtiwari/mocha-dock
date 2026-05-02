/*
    SPDX-FileCopyrightText: 2016 Smith AR <audoban@openmailbox.org>
    SPDX-FileCopyrightText: 2016 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Window

import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
//! QtQuick.Controls.Styles.Plasma removed in Plasma 6

import org.kde.kquickcontrolsaddons as KQuickControlAddons

import org.kde.mocha.core as MochaCore

import "../controls" as MochaExtraControls

Loader {
    active: plasmoid && plasmoid.configuration && mochaView

    sourceComponent: FocusScope {
        id: dialog

        width: typeSettings.width + Kirigami.Units.smallSpacing * 4
        height: typeSettings.height + Kirigami.Units.smallSpacing * 4
        Layout.minimumWidth: width
        Layout.minimumHeight: height
        LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
        LayoutMirroring.childrenInherit: true

        property bool panelIsVertical: plasmoid.formFactor === PlasmaCore.Types.Vertical

        KSvg.FrameSvgItem{
            id: backgroundFrameSvgItem
            anchors.fill: parent
            imagePath: "dialogs/background"
            enabledBorders: viewConfig.enabledBorders

            onEnabledBordersChanged: viewConfig.updateEffects()
            Component.onCompleted: viewConfig.updateEffects()
        }

        MochaExtraControls.TypeSelection{
            id: typeSettings
            anchors.centerIn: parent

            Component.onCompleted: forceActiveFocus();

            Keys.onPressed: {
                if (event.key === Qt.Key_Escape) {
                    primaryConfigView.hideConfigWindow();
                }
            }
        }
    }
}
