/*
    SPDX-FileCopyrightText: 2021 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

import org.kde.latte.core as LatteCore

import "./myview" as MyViewTypes

Item {
    property int groupId: -1

    property bool isReady: false

    property bool inNormalState: true

    property bool isHidden: false
    property bool isShownPartially: false
    property bool isShownFully: false

    property bool isHidingBlocked: false

    property bool inEditMode: false
    property bool inConfigureAppletsMode: false

    property bool inSlidingIn: false
    property bool inSlidingOut: false
    property bool inRelocationAnimation: false
    property bool inRelocationHiding: false

    property bool badgesIn3DStyle: true

    property int alignment: LatteCore.Types.Center
    property int visibilityMode: LatteCore.Types.None

    property real backgroundOpacity: 1.0

    property string lastUsedActivity: ""

    property rect appletsLayoutGeometry: Qt.rect(-1, -1, 0, 0)
    property rect screenGeometry: Qt.rect(0, 0, 1600, 1080)

    property var containmentActions: []

    property QtObject palette: _defaultPaletteObj
    readonly property QtObject defaultPalette: _defaultPaletteObj

    QtObject {
        id: _defaultPaletteObj
        readonly property color textColor: Kirigami.Theme.textColor
        readonly property color backgroundColor: Kirigami.Theme.backgroundColor
        readonly property color highlightColor: Kirigami.Theme.highlightColor
        readonly property color highlightedTextColor: Kirigami.Theme.highlightedTextColor
        readonly property color positiveTextColor: Kirigami.Theme.positiveTextColor
        readonly property color neutralTextColor: Kirigami.Theme.neutralTextColor
        readonly property color negativeTextColor: Kirigami.Theme.negativeTextColor
    }

    property MyViewTypes.ItemShadow itemShadow: MyViewTypes.ItemShadow {
        isEnabled: true
        size: 6
        shadowColor: "#ff080808"
        shadowSolidColor: "#ff080808"
    }

    //function inCurrentLayout();
}
