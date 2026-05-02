/*
    SPDX-FileCopyrightText: 2021 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.mocha.abilities.definition as AbilityDefinition

import "./indicators" as LocalIndicator

AbilityDefinition.Indicators {
    property Item bridge: null

    isEnabled: ref.indicators.isEnabled
    type: ref.indicators.type
    info: ref.indicators.info
    configuration: ref.indicators.configuration
    resources: ref.indicators.resources
    indicatorComponent: ref.indicators.indicatorComponent

    Item {
        id: ref
        readonly property Item indicators: bridge ? bridge.indicators : local
    }

    readonly property AbilityDefinition.Indicators local: AbilityDefinition.Indicators {
        isEnabled: false
        type: "org.kde.mocha.default"

        info.needsIconColors: false
        info.needsMouseEventCoordinates: false
        info.providesFrontLayer: false
        info.providesHoveredAnimation: false
        info.providesClickedAnimation: false
        info.providesTaskLauncherAnimation: false
        info.providesInAttentionAnimation: false
        info.providesGroupedWindowAddedAnimation: false
        info.providesGroupedWindowRemovedAnimation: false        
        info.extraMaskThickness: 0
        info.backgroundCornerMargin: 1.00
        info.lengthPadding: 0.08
        info.minThicknessPadding: 0
        info.minLengthPadding:0

        configuration: localMochaConfiguration
        resources: null

        indicatorComponent: isEnabled ? mochaLocalIndicator : null

        //! Local Mocha Indicator Configuration
        LocalIndicator.MochaConfiguration{
            id: localMochaConfiguration
        }

        //! Local Mocha Indicator implementation
        Component {
            id: mochaLocalIndicator
            LocalIndicator.MochaIndicator{}
        }
    }
}
