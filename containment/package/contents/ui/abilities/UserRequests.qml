/*
    SPDX-FileCopyrightText: 2020 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.mocha.core as MochaCore
import org.kde.mocha.abilities.definition as AbilityDefinition

AbilityDefinition.UserRequests {
    id: containerUserRequests
    property QtObject view: null

    Connections {
        target: view
        onUserRequestedViewType: {
            containerUserRequests.sglViewType(type);
        }
    }
}
