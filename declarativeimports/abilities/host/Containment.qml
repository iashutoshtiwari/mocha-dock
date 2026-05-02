/*
    SPDX-FileCopyrightText: 2021 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

import org.kde.mocha.core as MochaCore
import org.kde.mocha.abilities.definition as AbilityDefinition

AbilityDefinition.Containment {
    id: apis

    property int appletIndex: -1
    property Item myView: null

    alignment: {
        if (!myView) {
            return MochaCore.Types.Center;
        }

        if (myView.alignment === MochaCore.Types.Justify) {
            if (appletIndex>=0 && appletIndex<100) {
                return plasmoid.formFactor === PlasmaCore.Types.Horizontal ? MochaCore.Types.Left : MochaCore.Types.Top;
            } else if (appletIndex>=100 && appletIndex<200) {
                return MochaCore.Types.Center;
            } else if (appletIndex>=200) {
                return plasmoid.formFactor === PlasmaCore.Types.Horizontal ? MochaCore.Types.Right : MochaCore.Types.Bottom;
            }

            return MochaCore.Types.Center;
        }

        return myView.alignment;
    }

    readonly property Item publicApi: Item {
        readonly property alias isFirstAppletInContainment: apis.isFirstAppletInContainment
        readonly property alias isLastAppletInContainment: apis.isLastAppletInContainment

        readonly property alias alignment: apis.alignment
    }
}
