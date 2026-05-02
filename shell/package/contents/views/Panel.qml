/*
    SPDX-FileCopyrightText: 2016 Smith AR <audoban@openmailbox.org>
    SPDX-FileCopyrightText: 2016 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore

Item {
    id: root

    property Item containment
    property Item viewLayout

    readonly property bool verticalPanel: containment && containment.formFactor === PlasmaCore.Types.Vertical

    function adjustPrefix() {
    }

    Component.onDestruction: {
        console.log("mocha view qml source deleting...");
    }

    onContainmentChanged: {
        if (!containment) {
            return;
        }

        containment.parent = containmentParent;
        containment.visible = true;
        containment.anchors.fill = containmentParent;

        for(var i=0; i<containment.children.length; ++i){
            if (containment.children[i].objectName === "containmentViewLayout") {
                viewLayout = containment.children[i];
            }
        }
    }

    Item {
        id: containmentParent
        anchors.fill: parent
    }

    function appletContainsPos(appletId, pos) {
        if (viewLayout) {
            return viewLayout.appletContainsPos(appletId, pos);
        }

        return false;
    }
}
