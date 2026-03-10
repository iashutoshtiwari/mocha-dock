/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls 1.4 as Controls
import QtQuick.Controls.Styles.Plasma 2.0 as Styles
import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.core as PlasmaCore

Controls.SpinBox {
    implicitWidth: theme.mSize(theme.defaultFont).width * 10

    style: Styles.SpinBoxStyle {
        KSvg.Svg {
            id: arrowSvg
            imagePath: "widgets/arrows"
            colorGroup: Kirigami.Theme.ButtonColorGroup
        }
        incrementControl: KSvg.SvgItem {
            implicitWidth: theme.mSize(theme.defaultFont).width * 1.8
            anchors {
                centerIn: parent
                margins: 1
                leftMargin: 0
                rightMargin: 3
            }
            svg: arrowSvg
            elementId: "up-arrow"
            opacity: control.enabled ? (styleData.upPressed ? 1 : 0.6) : 0.5
        }
        decrementControl: KSvg.SvgItem {
            implicitWidth: theme.mSize(theme.defaultFont).width * 1.8
            anchors {
                centerIn: parent
                margins: 1
                leftMargin: 0
                rightMargin: 3
            }
            svg: arrowSvg
            elementId: "down-arrow"
            opacity: control.enabled ? (styleData.upPressed ? 1 : 0.6) : 0.5
        }
    }
}
