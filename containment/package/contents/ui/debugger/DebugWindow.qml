/*
    SPDX-FileCopyrightText: 2016 Smith AR <audoban@openmailbox.org>
    SPDX-FileCopyrightText: 2016 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

import org.kde.mocha.core as MochaCore

Window{
    width: mainGrid.width + 10
    height: Math.min(mainGrid.height+10, Screen.height - metrics.mask.thickness.maxNormalForItems)
    visible: true
    title: "#debugwindow#"

    property string space:" :   "

    PlasmaComponents.ScrollView {
        id: scrollView

        anchors.fill: parent
        //verticalScrollBarPolicy: Qt.ScrollBarAsNeeded
        //horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

        //flickableItem.flickableDirection: Flickable.VerticalFlick

        Grid{
            id:mainGrid
            columns: 2

            Text{
                text: "Name"+space
            }

            Text{
                text: mochaView && mochaView.name.length > 0 ? mochaView.name : "___"
            }

            Text{
                text: "Screen id"+space
            }

            Text{
                text: mochaView && mochaView.positioner ? mochaView.positioner.currentScreenName : "___"
            }

            Text{
                text: "Screen Geometry"+space
            }

            Text{
                text: {
                    if (mochaView && mochaView.screenGeometry){
                        return mochaView.screenGeometry.x+","+mochaView.screenGeometry.y+ " "+mochaView.screenGeometry.width+"x"+mochaView.screenGeometry.height;
                    } else {
                        return "_,_ _x_";
                    }
                }
            }

            Text{
                text: "Window Geometry"+space
            }

            Text{
                text: {
                    if (mochaView) {
                        return  mochaView.x + "," + mochaView.y + " "+mochaView.width+ "x"+mochaView.height;
                    } else {
                        return "_,_ _x_";
                    }
                }
            }

            Text{
                text: "On Primary"+space
            }

            Text{
                text: {
                    if (mochaView && mochaView.onPrimary)
                        return "Yes";
                    else
                        return "No";
                }
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "Contents Width"+space
            }

            Text{
                text: layoutsContainer.contentsWidth
            }

            Text{
                text: "Contents Height"+space
            }

            Text{
                text: layoutsContainer.contentsHeight
            }

            Text{
                text: "Max Length"+space
            }

            Text{
                text: root.maxLengthPerCentage +"%"
            }

            Text{
                text: "Max Length (pixels)"+space
            }

            Text{
                text: root.maxLength
            }

            Text{
                text: "Min Length"+space
            }

            Text{
                text: root.minLengthPerCentage +"%"
            }

            Text{
                text: "Min Length (pixels)"+space
            }

            Text{
                text: root.minLength
            }

            Text{
                text: "Offset (pixels)"+space
            }

            Text{
                text: root.offset
            }

            Text{
                text: "Mask"+space
            }

            Text{
                text: {
                    if (mochaView && mochaView.effects && mochaView.effects.mask) {
                        return mochaView.effects.mask.x +", "+ mochaView.effects.mask.y+"  "+mochaView.effects.mask.width+"x"+mochaView.effects.mask.height;
                    } else {
                        return "_,_ _x_";
                    }
                }
            }

            Text{
                text: "Input "+space
            }

            Text{
                text: {
                    if (mochaView && mochaView.effects && mochaView.effects.inputMask) {
                        return mochaView.effects.inputMask.x +", "+ mochaView.effects.inputMask.y+"  "+mochaView.effects.inputMask.width+"x"+mochaView.effects.inputMask.height;
                    } else {
                        return "_,_ _x_";
                    }
                }
            }

            Text{
                text: "Local Geometry"+space
            }

            Text{
                text: {
                    if (mochaView && mochaView.localGeometry) {
                        return mochaView.localGeometry.x + ", " + mochaView.localGeometry.y + "  " + mochaView.localGeometry.width + "x" + mochaView.localGeometry.height;
                    } else {
                        return "_,_ _x_";
                    }
                }
            }

            Text{
                text: "Absolute Geometry"+space
            }

            Text{
                text: {
                    if (mochaView && mochaView.absoluteGeometry) {
                        return mochaView.absoluteGeometry.x + ", " + mochaView.absoluteGeometry.y + "  " + mochaView.absoluteGeometry.width + "x" + mochaView.absoluteGeometry.height;
                    } else {
                        return "_,_ _x_";
                    }
                }
            }


            Text{
                text: "Draw Effects"+space
            }

            Text{
                text: {
                    if (mochaView && mochaView.effects && mochaView.effects.drawEffects)
                        return "Yes";
                    else
                        return "No";
                }
            }

            Text{
                text: "Effects Area"+space
            }

            Text{
                text: {
                    if (mochaView && mochaView.effects && mochaView.effects.rect) {
                        return mochaView.effects.rect.x + ", " + mochaView.effects.rect.y + "  " +mochaView.effects.rect.width + "x" + mochaView.effects.rect.height;
                    } else {
                        return "_,_ _x_";
                    }
                }
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "Is Hidden (flag)"+space
            }

            Text{
                text: {
                    if (mochaView && mochaView.visibility && mochaView.visibility.isHidden)
                        return "Yes";
                    else
                        return "No";
                }
            }

            Text{
                text: "Contains Mouse (flag)"+space
            }

            Text{
                text: {
                    if (mochaView && mochaView.visibility && mochaView.visibility.containsMouse)
                        return "Yes";
                    else
                        return "No";
                }
            }

            Text{
                text: "Edit Mode"+space
            }

            Text{
                text: {
                    if (root.editMode)
                        return "Yes";
                    else
                        return "No";
                }
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "Location"+space
            }

            Text{
                text: {
                    switch(plasmoid.location){
                    case PlasmaCore.Types.LeftEdge:
                        return "Left Edge";
                        break;
                    case PlasmaCore.Types.RightEdge:
                        return "Right Edge";
                        break;
                    case PlasmaCore.Types.TopEdge:
                        return "Top Edge";
                        break;
                    case PlasmaCore.Types.BottomEdge:
                        return "Bottom Edge";
                        break;
                    }

                    return " <unknown> : " + plasmoid.location;
                }
            }

            Text{
                text: "Alignment"+space
            }

            Text{
                text: {
                    switch(plasmoid.configuration.alignment){
                    case MochaCore.Types.Left:
                        return "Left";
                        break;
                    case MochaCore.Types.Right:
                        return "Right";
                        break;
                    case MochaCore.Types.Center:
                        return "Center";
                        break;
                    case MochaCore.Types.Top:
                        return "Top";
                        break;
                    case MochaCore.Types.Bottom:
                        return "Bottom";
                        break;
                    case MochaCore.Types.Justify:
                        return "Justify";
                        break;
                    }

                    return "<unknown> : " + plasmoid.configuration.alignment;
                }
            }

            Text{
                text: "Visibility"+space
            }

            Text{
                text: {
                    if (!mochaView || !mochaView.visibility)
                        return "";

                    switch(mochaView.visibility.mode){
                    case MochaCore.Types.AlwaysVisible:
                        return "Always Visible";
                        break;
                    case MochaCore.Types.AutoHide:
                        return "Auto Hide";
                        break;
                    case MochaCore.Types.DodgeActive:
                        return "Dodge Active";
                        break;
                    case MochaCore.Types.DodgeMaximized:
                        return "Dodge Maximized";
                        break;
                    case MochaCore.Types.DodgeAllWindows:
                        return "Dodge All Windows";
                        break;
                    case MochaCore.Types.DodgeAllWindows:
                        return "Dodge All Windows";
                        break;
                    case MochaCore.Types.WindowsGoBelow:
                        return "Windows Go Below";
                        break;
                    case MochaCore.Types.WindowsCanCover:
                        return "Windows Can Cover";
                        break;
                    case MochaCore.Types.WindowsAlwaysCover:
                        return "Windows Always Cover";
                        break;
                    case MochaCore.Types.SidebarOnDemand:
                        return "OnDemand Sidebar";
                        break;
                    case MochaCore.Types.SidebarAutoHide:
                        return "AutoHide Sidebar";
                    break;
                    case MochaCore.Types.NormalWindow:
                        return "Normal Window";
                        break;
                    case MochaCore.Types.None:
                        return "None";
                        break;
                    }

                    return "<unknown> : " + mochaView.visibility.mode;
                }
            }

            Text{
                text: "Zoom Factor"+space
            }

            Text{
                text: parabolic.factor.zoom
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "Icon Size (current)"+space
            }

            Text{
                text: metrics.iconSize
            }

            Text{
                text: "Icon Size (user)"+space
            }

            Text{
                text: plasmoid.configuration.iconSize
            }

            Text{
                text: "Icon Size (portion)"+space
            }

            Text{
                text: metrics.portionIconSize
            }

            Text{
                text: "Icon Size (auto decrease), Enabled"+space
            }

            Text{
                text: {
                    if (autosize.isActive)
                        return "Yes";
                    else
                        return "No";
                }
            }

            Text{
                text: "Icon Size (auto decrease)"+space
            }

            Text{
                text: autosize.iconSize
            }

            Text{
                text: "Length Padding (pixels)"+space
            }

            Text{
                text: metrics.padding.length
            }

            Text{
                text: "Length Margin (pixels)"+space
            }

            Text{
                text: metrics.margin.length
            }

            Text{
                text: "Head Thickness Margin"+space
            }

            Text{
                text: metrics.margin.headThickness
            }

            Text{
                text: "Tail Thickness Margin"+space
            }

            Text{
                text: metrics.margin.tailThickness
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "Show Panel Background (user)"+space
            }

            Text{
                text: {
                    if (plasmoid.configuration.useThemePanel)
                        return "Yes";
                    else
                        return "No";
                }
            }

            Text{
                text: "Force Transparent Panel (auto)"+space
            }

            Text{
                text: {
                    if (root.forceTransparentPanel)
                        return "Yes";
                    else
                        return "No";
                }
            }

            Text{
                text: "Background Length"+space
            }

            Text{
                text: background.totals.visualLength
            }

            Text{
                text: "Background Thickness(user)"+space
            }

            Text{
                text: plasmoid.configuration.panelSize + "%"
            }

            Text{
                text: "Background Thickness(auto)"+space
            }

            Text{
                text: background.totals.visualThickness
            }

            Text{
                text: "Background Opacity"+space
            }

            Text{
                text: (root.myView.backgroundOpacity * 100) + "%"
            }

            Text{
                text: "Background Shadows Active"+space
            }

            Text{
                text: {
                    if (root.panelShadowsActive)
                        return "Yes";
                    else
                        return "No";
                }
            }

            Text{
                text: "Background Shadow"+space
            }

            Text{
                text: background.shadows.headThickness
            }

            Text{
                text: "Background Head Thickness Padding"+space
            }

            Text{
                text: background.paddings.headThickness
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "Mask - Normal Thickness"+space
            }

            Text{
                text: metrics.mask.thickness.normal
            }

            Text{
                text: "Thickness Uses Panel Size"+space
            }

            Text{
                text: background.isGreaterThanItemThickness
            }

            Text{
                text: "Behave As Plasma Panel"+space
            }

            Text{
                text: {
                    if (root.behaveAsPlasmaPanel)
                        return "Yes";
                    else
                        return "No";
                }
            }

            Text{
                text: "Draw Shadows (external)"+space
            }

            Text{
                text: {
                    if (root.drawShadowsExternal)
                        return "Yes";
                    else
                        return "No";
                }
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "Applet Hovered"+space
            }

            Text{
                text: "--"//layoutsContainer.hoveredIndex
            }

            Text{
                text: "In Normal State"+space
            }

            Text{
                text: visibilityManager.inNormalState
            }

            Text{
                text: "Animations Both Axis"+space
            }

            Text{
                text: animations.needBothAxis.count
            }

            Text{
                text: "Animations Only Length"+space
            }

            Text{
                text: animations.needLength.count
            }

            Text{
                text: "Animations Need Thickness"+space
            }

            Text{
                text: animations.needThickness.count
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "Start Layout Shown Applets"+space
            }

            Text{
                text: layouter.startLayout.shownApplets
            }

            Text{
                text: "Start Layout Applets (with fill)"+space
            }

            Text{
                text: layouter.startLayout.fillApplets
            }

            Text{
                text: "Start Layout Size (no fill applets)"+space
            }

            Text{
                text: layouter.startLayout.sizeWithNoFillApplets+" px."
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "Main Layout Shown Applets"+space
            }

            Text{
                text: layouter.mainLayout.shownApplets
            }

            Text{
                text: "Main Layout Applets (with fill)"+space
            }

            Text{
                text: layouter.mainLayout.fillApplets
            }

            Text{
                text: "Main Layout Size (no fill applets)"+space
            }

            Text{
                text: layouter.mainLayout.sizeWithNoFillApplets+" px."
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "End Layout Shown Applets"+space
            }

            Text{
                text: layouter.endLayout.shownApplets
            }

            Text{
                text: "End Layout Applets (with fill)"+space
            }

            Text{
                text: layouter.endLayout.fillApplets
            }

            Text{
                text: "End Layout Size (no fill applets)"+space
            }

            Text{
                text: layouter.endLayout.sizeWithNoFillApplets+" px."
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "Animations ZoomFactor" + space
            }

            Text{
                text: animations.requirements.zoomFactor
            }

            Text{
                text: "   -----------   "
            }

            Text{
                text: " -----------   "
            }

            Text{
                text: "Applets need Windows Tracking"+space
            }

            Text{
                text: indexer.clientsTrackingWindowsCount
            }

            Text{
                text: "Last Active Window Current Screen (id)"+space
            }

            Text{
                text: mochaView && mochaView.windowsTracker && mochaView.windowsTracker.currentScreen.lastActiveWindow && mochaView.windowsTracker.currentScreen.lastActiveWindow.isValid ?
                          mochaView.windowsTracker.currentScreen.lastActiveWindow.winId : "--"
            }

            Text{
                text: "Last Active Window Current Screen (title)"+space
            }

            Text{
                text: mochaView && mochaView.windowsTracker && mochaView.windowsTracker.currentScreen.lastActiveWindow && mochaView.windowsTracker.currentScreen.lastActiveWindow.isValid ?
                          mochaView.windowsTracker.currentScreen.lastActiveWindow.display : "--"
                elide: Text.ElideRight
            }

            Text{
                text: "Last Active Window All Screens (id)"+space
            }

            Text{
                text: mochaView && mochaView.windowsTracker && mochaView.windowsTracker.allScreens.lastActiveWindow && mochaView.windowsTracker.allScreens.lastActiveWindow.isValid ?
                          mochaView.windowsTracker.allScreens.lastActiveWindow.winId : "--"
            }

            Text{
                text: "Last Active Window All Screens (title)"+space
            }

            Text{
                text: mochaView && mochaView.windowsTracker && mochaView.windowsTracker.allScreens.lastActiveWindow && mochaView.windowsTracker.allScreens.lastActiveWindow.isValid ?
                          mochaView.windowsTracker.allScreens.lastActiveWindow.display : "--"
                elide: Text.ElideRight
            }
        }

    }
}
