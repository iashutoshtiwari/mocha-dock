/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

import org.kde.mocha.components as MochaComponents


MochaComponents.ComboBoxButton{
    id: custom
    checkable: true

    buttonToolTip:  custom.type === "install:" ? i18n("Install indicators from KDE Online Store or local files") :
                                                 i18n("Use %1 style for your indicators", buttonText)

    buttonIsTransparent: true
    buttonIsTriggeringMenu: custom.type === "install:"
    comboBoxButtonIsTransparent: true
    comboBoxButtonIsVisible: mochaView.indicator.customPluginsCount > 0

    comboBoxTextRole: "name"
    comboBoxIconRole: "icon"
    comboBoxIconToolTipRole: "iconToolTip"
    comboBoxIconOnlyWhenHoveredRole: "iconOnlyWhenHovered"
    comboBoxBlankSpaceForEmptyIcons: true
    comboBoxForcePressed: mochaView.indicator.type === type
    comboBoxPopUpAlignRight: Qt.application.layoutDirection !== Qt.RightToLeft

    property string type: ""

    Component.onCompleted: {
        reloadModel();
        updateButtonInformation();
    }

    ListModel {
        id: actionsModel
    }

    Connections{
        target: mochaView.indicator
        onCustomPluginsCountChanged: {
            custom.reloadModel();
            custom.updateButtonInformation();
        }
    }

    Connections {
        target: viewConfig
        onIsReadyChanged: {
            if (viewConfig.isReady) {
                custom.updateButtonInformation();
            }
        }
    }

    Connections{
        target: custom.button
        onClicked: onButtonIsPressed();
    }

    Connections{
        target: custom.comboBox

        onActivated: {
            if (index>=0) {
                var item = actionsModel.get(index);
                if (item.pluginId === "add:") {
                    viewConfig.indicatorUiManager.addIndicator();
                } else if (item.pluginId === "download:") {
                    viewConfig.indicatorUiManager.downloadIndicator();
                } else {
                    mochaView.indicator.type = item.pluginId;
                }
            }

            custom.updateButtonInformation();
        }

        onIconClicked: {
            if (index>=0) {
                var item = actionsModel.get(index);
                var pluginId = item.pluginId;
                if (mochaView.indicator.customLocalPluginIds.indexOf(pluginId)>=0) {
                    viewConfig.indicatorUiManager.removeIndicator(pluginId);
                    custom.comboBox.popup.close();
                }
            }
        }
    }

    Connections{
        target: custom.comboBox.popup
        onVisibleChanged: {
            if (visible) {
                custom.selectChosenType();
            }
        }
    }

    function onButtonIsPressed() {
        if (custom.type !== "install:") {
            mochaView.indicator.type = custom.type;
        }
    }

    function updateButtonInformation() {
        if (mochaView.indicator.customPluginsCount === 0) {
            custom.buttonText = i18n("Install...");
            custom.type = "install:";
            custom.checkable = false;
        } else {
            custom.checkable = true;

            var curCustomIndex = mochaView.indicator.customPluginIds.indexOf(mochaView.indicator.customType);

            if (curCustomIndex>=0) {
                custom.buttonText = actionsModel.get(curCustomIndex).name;
                custom.type = actionsModel.get(curCustomIndex).pluginId;
            } else {
                custom.buttonText = actionsModel.get(0).name;
                custom.type = actionsModel.get(0).pluginId;
            }
        }
    }

    function reloadModel() {
        actionsModel.clear();

        if (mochaView.indicator.customPluginsCount > 0) {
            var pluginIds = mochaView.indicator.customPluginIds;
            var pluginNames = mochaView.indicator.customPluginNames;
            var localPluginIds = mochaView.indicator.customLocalPluginIds;

            for(var i=0; i<pluginIds.length; ++i) {
                var canBeRemoved = localPluginIds.indexOf(pluginIds[i])>=0;
                var iconString = canBeRemoved ? 'remove' : '';
                var iconTip = canBeRemoved ? i18n("Remove indicator") : '';
                var iconOnlyForHovered = canBeRemoved ? true : false;

                var element = {
                    pluginId: pluginIds[i],
                    name: pluginNames[i],
                    icon: iconString,
                    iconToolTip: iconTip,
                    iconOnlyWhenHovered: iconOnlyForHovered
                };

                actionsModel.append(element);
            }
        }

        appendDefaults();

        comboBox.model = actionsModel;

        if (custom.type === mochaView.indicator.type) {
            selectChosenType();
        } else {
            comboBox.currentIndex = -1;
        }
    }

    function selectChosenType() {
        var found = false;

        for (var i=0; i<actionsModel.count; ++i) {
            if (actionsModel.get(i).pluginId === custom.type) {
                found = true;
                custom.comboBox.currentIndex = i;
                break;
            }
        }

        if (!found) {
            custom.comboBox.currentIndex = -1;
        }
    }

    function emptyModel() {
        actionsModel.clear();
        appendDefaults();

        comboBox.model = actionsModel;
        comboBox.currentIndex = -1;
    }

    function appendDefaults() {
        //! add
        var addElement = {
            pluginId: 'add:',
            name: i18n("Add Indicator..."),
            icon: 'document-import',
            iconToolTip: '',
            iconOnlyWhenHovered: false
        };
        actionsModel.append(addElement);

        //! download
        var downloadElement = {
            pluginId: 'download:',
            name: i18n("Get New Indicators..."),
            icon: 'get-hot-new-stuff',
            iconToolTip: '',
            iconOnlyWhenHovered: false
        };
        actionsModel.append(downloadElement);
    }

}
