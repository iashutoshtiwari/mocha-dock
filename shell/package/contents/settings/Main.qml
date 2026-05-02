/*
    SPDX-FileCopyrightText: 2026 Ashutosh Tiwari <contact@ashutoshtiwari.dev>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Window

Window {
    id: root
    title: i18n("Mocha Dock Settings")
    width: 580
    height: 480
    minimumWidth: 460
    minimumHeight: 380
    visible: true
    color: palette.window

    function goToPage(pageIndex) {
        if (pageIndex >= 0 && pageIndex < navModel.count) {
            navList.currentIndex = pageIndex;
        }
    }

    SystemPalette { id: palette; colorGroup: SystemPalette.Active }

    ListModel {
        id: navModel
        ListElement { label: "Behavior"; iconName: "configure" }
        ListElement { label: "Preferences"; iconName: "preferences-system" }
        ListElement { label: "About"; iconName: "help-about" }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // --- Sidebar ---
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 160
            color: Qt.darker(palette.window, 1.05)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 0

                // App title
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        spacing: 8

                        Controls.Label {
                            text: "Mocha Dock"
                            font.bold: true
                            font.pointSize: 13
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Qt.darker(palette.window, 1.15)
                }

                // Nav items
                ListView {
                    id: navList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 4
                    model: navModel
                    currentIndex: 0
                    clip: true

                    delegate: Rectangle {
                        width: navList.width
                        height: 40
                        color: navList.currentIndex === index
                               ? palette.highlight
                               : navHover.containsMouse ? Qt.darker(palette.window, 1.1) : "transparent"
                        radius: 4

                        anchors.leftMargin: 4
                        anchors.rightMargin: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            spacing: 10

                            Controls.Label {
                                text: model.label
                                color: navList.currentIndex === index ? palette.highlightedText : palette.windowText
                                font.pointSize: 10
                            }
                        }

                        MouseArea {
                            id: navHover
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: navList.currentIndex = index
                        }
                    }
                }

                // Quit button at bottom
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Qt.darker(palette.window, 1.15)
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: quitHover.containsMouse ? Qt.darker(palette.window, 1.1) : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        spacing: 10

                        Controls.Label {
                            text: i18n("Quit Mocha")
                            color: palette.windowText
                            font.pointSize: 10
                        }
                    }

                    MouseArea {
                        id: quitHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (typeof mochaCorona !== "undefined") {
                                mochaCorona.quitApplication();
                            }
                        }
                    }
                }
            }
        }

        // --- Vertical separator ---
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Qt.darker(palette.window, 1.15)
        }

        // --- Content ---
        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: navList.currentIndex

            // ======== Page: Behavior ========
            Controls.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Flickable {
                    contentHeight: behaviorColumn.implicitHeight + 40
                    clip: true

                    ColumnLayout {
                        id: behaviorColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 24
                        anchors.topMargin: 20
                        spacing: 6

                        Controls.Label {
                            text: i18n("Behavior")
                            font.bold: true
                            font.pointSize: 16
                            Layout.bottomMargin: 12
                        }

                        // --- Startup ---
                        Controls.Label {
                            text: i18n("Startup")
                            font.bold: true
                            font.pointSize: 11
                            Layout.topMargin: 8
                        }

                        Controls.CheckBox {
                            text: i18n("Launch Mocha Dock on login")
                            checked: typeof universalSettings !== "undefined" ? universalSettings.autostart : false
                            onToggled: {
                                if (typeof universalSettings !== "undefined") {
                                    universalSettings.autostart = checked;
                                }
                            }
                        }

                        // --- Shortcuts ---
                        Controls.Label {
                            text: i18n("Shortcuts")
                            font.bold: true
                            font.pointSize: 11
                            Layout.topMargin: 16
                        }

                        Controls.CheckBox {
                            text: i18n("Enable application launcher via Meta key press-and-hold")
                            checked: typeof universalSettings !== "undefined" ? universalSettings.metaPressAndHoldEnabled : true
                            onToggled: {
                                if (typeof universalSettings !== "undefined") {
                                    universalSettings.metaPressAndHoldEnabled = checked;
                                }
                            }
                        }

                        // --- Information ---
                        Controls.Label {
                            text: i18n("Information")
                            font.bold: true
                            font.pointSize: 11
                            Layout.topMargin: 16
                        }

                        Controls.CheckBox {
                            text: i18n("Show info window on layout changes")
                            checked: typeof universalSettings !== "undefined" ? universalSettings.showInfoWindow : true
                            onToggled: {
                                if (typeof universalSettings !== "undefined") {
                                    universalSettings.showInfoWindow = checked;
                                }
                            }
                        }
                    }
                }
            }

            // ======== Page: Preferences ========
            Controls.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Flickable {
                    contentHeight: prefsColumn.implicitHeight + 40
                    clip: true

                    ColumnLayout {
                        id: prefsColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 24
                        anchors.topMargin: 20
                        spacing: 6

                        Controls.Label {
                            text: i18n("Preferences")
                            font.bold: true
                            font.pointSize: 16
                            Layout.bottomMargin: 12
                        }

                        // --- Appearance ---
                        Controls.Label {
                            text: i18n("Appearance")
                            font.bold: true
                            font.pointSize: 11
                            Layout.topMargin: 8
                        }

                        Controls.CheckBox {
                            text: i18n("Use 3D style for badges")
                            checked: typeof universalSettings !== "undefined" ? universalSettings.badges3DStyle : false
                            onToggled: {
                                if (typeof universalSettings !== "undefined") {
                                    universalSettings.badges3DStyle = checked;
                                }
                            }
                        }

                        // --- Editing ---
                        Controls.Label {
                            text: i18n("Editing")
                            font.bold: true
                            font.pointSize: 11
                            Layout.topMargin: 16
                        }

                        Controls.CheckBox {
                            text: i18n("Show advanced options in dock edit mode")
                            checked: typeof universalSettings !== "undefined" ? universalSettings.inAdvancedModeForEditSettings : false
                            onToggled: {
                                if (typeof universalSettings !== "undefined") {
                                    universalSettings.inAdvancedModeForEditSettings = checked;
                                }
                            }
                        }

                        Controls.CheckBox {
                            text: i18n("Enable applet configuration mode")
                            checked: typeof universalSettings !== "undefined" ? universalSettings.inConfigureAppletsMode : false
                            onToggled: {
                                if (typeof universalSettings !== "undefined") {
                                    universalSettings.inConfigureAppletsMode = checked;
                                }
                            }
                        }

                        // --- Parabolic Effect ---
                        Controls.Label {
                            text: i18n("Parabolic Effect")
                            font.bold: true
                            font.pointSize: 11
                            Layout.topMargin: 16
                        }

                        RowLayout {
                            spacing: 12
                            Controls.Label { text: i18n("Spread:") }
                            Controls.SpinBox {
                                from: 0
                                to: 20
                                value: typeof universalSettings !== "undefined" ? universalSettings.parabolicSpread : 3
                                onValueModified: {
                                    if (typeof universalSettings !== "undefined") {
                                        universalSettings.parabolicSpread = value;
                                    }
                                }
                            }
                        }

                        // --- Layout ---
                        Controls.Label {
                            text: i18n("Layout")
                            font.bold: true
                            font.pointSize: 11
                            Layout.topMargin: 16
                        }

                        RowLayout {
                            spacing: 12
                            Controls.Label { text: i18n("Current layout:") }
                            Controls.Label {
                                text: typeof universalSettings !== "undefined" ? universalSettings.singleModeLayoutName : "N/A"
                                font.italic: true
                            }
                        }
                    }
                }
            }

            // ======== Page: About ========
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Controls.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "☕"
                        font.pointSize: 48
                    }

                    Controls.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Mocha Dock"
                        font.bold: true
                        font.pointSize: 20
                    }

                    Controls.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: i18n("A Wayland-native dock for KDE Plasma 6")
                        opacity: 0.7
                    }

                    Controls.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "v0.1.0"
                        opacity: 0.5
                    }

                    Item { height: 12; width: 1 }

                    Controls.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: i18n("Based on Latte Dock by Michail Vourlakos & Smith AR")
                        opacity: 0.4
                        font.pointSize: 9
                    }

                    Controls.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "© 2026 Ashutosh Tiwari"
                        opacity: 0.4
                        font.pointSize: 9
                    }

                    Item { height: 20; width: 1 }

                    Controls.Button {
                        Layout.alignment: Qt.AlignHCenter
                        text: i18n("Quit Mocha Dock")
                        icon.name: "application-exit"
                        onClicked: {
                            if (typeof mochaCorona !== "undefined") {
                                mochaCorona.quitApplication();
                            }
                        }
                    }
                }
            }
        }
    }
}
