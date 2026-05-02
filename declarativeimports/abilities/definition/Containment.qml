/*
    SPDX-FileCopyrightText: 2021 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.mocha.core as MochaCore

Item {
    property bool isFirstAppletInContainment: false
    property bool isLastAppletInContainment: false

    property int alignment: MochaCore.Types.Center
}
