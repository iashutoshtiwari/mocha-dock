/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.CheckBox {
    property int value: 0

    onValueChanged: {
        if (tristate) {
            checkState = value;
        } else {
            checked = value;
        }
    }
}

