/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls 1.4
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore

T.ToolTip {
    id: control

    x: parent ? (parent.width - implicitWidth) / 2 : 0
    y: -implicitHeight - 3

    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    margins: units.gridUnit
    leftPadding: background.margins.left
    topPadding: background.margins.top
    rightPadding: background.margins.right
    bottomPadding: background.margins.bottom

    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    contentItem: Label {
        text: control.text
        font: control.font
        color: Kirigami.Theme.textColor
    }

    background: KSvg.FrameSvgItem {
        imagePath: "widgets/background"
        enabledBorders: KSvg.FrameSvg.AllBorders
    }
}
