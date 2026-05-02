/*
    SPDX-FileCopyrightText: 2018 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

import org.kde.mocha.core as MochaCore
import org.kde.mocha.private.app as MochaApp
import org.kde.mocha.private.containment as MochaContainment

import "../../code/ColorizerTools.js" as ColorizerTools

Loader{
    id: manager

    //! In Plasma 6, the global `theme` context property was removed.
    //! This QtObject serves as a sentinel for "default plasma theme" comparisons
    //! and provides the same color properties that `theme` used to expose.
    readonly property QtObject _defaultTheme: QtObject {
        readonly property color textColor: Kirigami.Theme.textColor
        readonly property color backgroundColor: Kirigami.Theme.backgroundColor
        readonly property color highlightColor: Kirigami.Theme.highlightColor
        readonly property color highlightedTextColor: Kirigami.Theme.highlightedTextColor
        readonly property color positiveTextColor: Kirigami.Theme.positiveTextColor
        readonly property color neutralTextColor: Kirigami.Theme.neutralTextColor
        readonly property color negativeTextColor: Kirigami.Theme.negativeTextColor
        readonly property color buttonTextColor: Kirigami.Theme.textColor
        readonly property color buttonBackgroundColor: Kirigami.Theme.backgroundColor
        readonly property color buttonHoverColor: Kirigami.Theme.hoverColor
        readonly property color buttonFocusColor: Kirigami.Theme.focusColor
        readonly property color inactiveBackgroundColor: Kirigami.Theme.backgroundColor
        readonly property color inactiveTextColor: Kirigami.Theme.textColor
        readonly property string schemeFile: "kdeglobals"
    }

    //! the loader loads the backgroundTracker component
    active: root.themeColors === MochaContainment.Types.SmartThemeColors

    readonly property bool backgroundIsBusy: item ? item.isBusy : false

    readonly property real originalThemeTextColorBrightness: ColorizerTools.colorBrightness(Kirigami.Theme.textColor)
    readonly property color originalLightTextColor: originalThemeTextColorBrightness > 127.5 ? Kirigami.Theme.textColor : Kirigami.Theme.backgroundColor

    readonly property real themeTextColorBrightness: ColorizerTools.colorBrightness(textColor)
    readonly property real backgroundColorBrightness: ColorizerTools.colorBrightness(backgroundColor)

    readonly property color focusGlowColor: Qt.hsva(buttonFocusColor.h, buttonFocusColor.s, 1.0, 1.0)

    readonly property color outlineColorBase: backgroundColor
    readonly property real outlineColorBaseBrightness: ColorizerTools.colorBrightness(outlineColorBase)
    readonly property color outlineColor: {
        if (!root.panelOutline) {
            return backgroundColor;
        }

        if (outlineColorBaseBrightness > 127.5) {
            return Qt.darker(outlineColorBase, 1.5);
        } else {
            return Qt.lighter(outlineColorBase, 2.2);
        }
    }

    readonly property bool editModeTextColorIsBright: ColorizerTools.colorBrightness(editModeTextColor) > 127.5
    readonly property color editModeTextColor: mochaView && mochaView.layout ? mochaView.layout.textColor : "white"

    readonly property bool mustBeShown: (applyTheme && applyTheme !== _defaultTheme)
                                        || (root.inConfigureAppletsMode && (root.themeColors === MochaContainment.Types.SmartThemeColors))

    readonly property real currentBackgroundBrightness: item ? item.currentBrightness : -1000

    readonly property bool applyingWindowColors: (root.windowColors === MochaContainment.Types.ActiveWindowColors && mochaView && mochaView.windowsTracker
                                                  && selectedWindowsTracker.activeWindowScheme)
                                                 || (root.windowColors === MochaContainment.Types.TouchingWindowColors && mochaView && mochaView.windowsTracker
                                                     && mochaView.windowsTracker.currentScreen.touchingWindowScheme)

    property QtObject applyTheme: {
        if (!root.environment.isGraphicsSystemAccelerated) {
            return _defaultTheme;
        }

        if (mochaView && mochaView.windowsTracker && !(root.plasmaBackgroundForPopups && root.hasExpandedApplet)) {
            if (root.windowColors === MochaContainment.Types.ActiveWindowColors && selectedWindowsTracker.activeWindowScheme) {
                return selectedWindowsTracker.activeWindowScheme;
            }

            if (root.windowColors === MochaContainment.Types.TouchingWindowColors && mochaView.windowsTracker.currentScreen.touchingWindowScheme) {
                //! we must track touching windows and when they are not active
                //! the active window scheme is used for convenience
                if (mochaView.windowsTracker.currentScreen.existsWindowTouching || mochaView.windowsTracker.currentScreen.existsWindowTouchingEdge
                        && !(mochaView.windowsTracker.currentScreen.activeWindowTouching || mochaView.windowsTracker.currentScreen.activeWindowTouchingEdge)
                        && mochaView.windowsTracker.currentScreen.activeWindowScheme) {
                    return mochaView.windowsTracker.currentScreen.activeWindowScheme;
                }

                return mochaView.windowsTracker.currentScreen.touchingWindowScheme;
            }
        }

        if (themeExtended) {
            if (root.userShowPanelBackground && root.plasmaBackgroundForPopups && root.hasExpandedApplet /*for expanded popups when it is enabled*/
                    || root.plasmaStyleBusyForTouchingBusyVerticalView
                    || (root.themeColors === MochaContainment.Types.SmartThemeColors /*for Smart theming that Windows colors are not used and the user wants solidness at some cases*/
                        && root.windowColors === MochaContainment.Types.NoneWindowColors
                        && root.forceSolidPanel) ) {
                /* plasma style*/
                return _defaultTheme;
            }

            if (root.themeColors === MochaContainment.Types.DarkThemeColors) {
                return themeExtended.darkTheme;
            } else if (root.themeColors === MochaContainment.Types.LightThemeColors) {
                return themeExtended.lightTheme;
            } else if (root.themeColors === MochaContainment.Types.ReverseThemeColors) {
                return themeExtended.isLightTheme ? themeExtended.darkTheme : themeExtended.lightTheme;
            } else if (root.themeColors === MochaContainment.Types.LayoutThemeColors && mochaView && mochaView.layout) {
                return mochaView.layout.scheme;
            }

            if (root.themeColors === MochaContainment.Types.SmartThemeColors) {
                //! Smart Colors Case
                if (!root.forcePanelForBusyBackground) {
                    //! simple case that not a busy background is applied
                    return currentBackgroundBrightness > 127.5 ? themeExtended.lightTheme : themeExtended.darkTheme;
                } else {
                    //! Smart + Busy background case
                    var themeContrastedTextColor = currentBackgroundBrightness > 127.5 ? themeExtended.lightTheme : themeExtended.darkTheme;
                    var themeContrastedBackground = currentBackgroundBrightness > 127.5 ? themeExtended.darkTheme : themeExtended.lightTheme;

                    if (root.myView.backgroundStoredOpacity < 0.35) {
                        //! textColor should be better to provide the needed contrast
                        return themeContrastedTextColor;
                    } else if (root.myView.backgroundStoredOpacity >= 0.35 && root.myView.backgroundStoredOpacity <= 0.70) {
                        //! provide a dark case scenario at all cases
                        return themeExtended.darkTheme;
                    } else {
                        //! default plasma theme should be better for panel transparency > 70
                        return _defaultTheme;
                    }
                }
            }
        }

        return _defaultTheme;
    }

    property color applyColor: textColor

    readonly property color backgroundColor:applyTheme.backgroundColor
    readonly property color textColor: {
        if (mochaView && mochaView.layout
                && root.inConfigureAppletsMode
                && MochaCore.WindowSystem.compositingActive
                && root.myView.backgroundStoredOpacity<0.40
                && (root.themeColors === MochaContainment.Types.SmartThemeColors)) {
            return mochaView.layout.textColor;
        }

        return applyTheme.textColor;
    }

    readonly property color inactiveBackgroundColor: applyTheme === _defaultTheme ? Kirigami.Theme.backgroundColor : applyTheme.inactiveBackgroundColor
    readonly property color inactiveTextColor: applyTheme === _defaultTheme ? Kirigami.Theme.textColor : applyTheme.inactiveTextColor

    readonly property color highlightColor: applyTheme.highlightColor
    readonly property color highlightedTextColor: applyTheme.highlightedTextColor
    readonly property color positiveTextColor: applyTheme.positiveTextColor
    readonly property color neutralTextColor: applyTheme.neutralTextColor
    readonly property color negativeTextColor: applyTheme.negativeTextColor

    readonly property color buttonTextColor: applyTheme.buttonTextColor
    readonly property color buttonBackgroundColor: applyTheme.buttonBackgroundColor
    readonly property color buttonHoverColor: applyTheme.buttonHoverColor
    readonly property color buttonFocusColor: applyTheme.buttonFocusColor

    readonly property string scheme: {
        if (root.inConfigureAppletsMode && (root.themeColors === MochaContainment.Types.SmartThemeColors)) {
            if (!MochaCore.WindowSystem.compositingActive && applyTheme !== _defaultTheme) {
                return applyTheme.schemeFile;
            }

            //! in edit mode (that is shown the edit visual without opacity)
            //! take care the applets that need a proper color scheme to paint themselves
            if ((editModeTextColorIsBright && themeExtended.isLightTheme)
                    || (!editModeTextColorIsBright && !themeExtended.isLightTheme)) {
                if (themeExtended.darkTheme === themeExtended.defaultTheme) {
                    console.log("light theme... : " + themeExtended.isLightTheme);
                    return themeExtended.lightTheme.schemeFile;
                } else {
                    console.log("dark theme... : " + themeExtended.isDarkTheme);
                    return themeExtended.darkTheme.schemeFile;
                }
            } else {
                console.log("default theme... : " + themeExtended.isLightTheme);
                return themeExtended.defaultTheme.schemeFile;
            }
        }

        if (applyTheme===_defaultTheme || !mustBeShown) {
            if (themeExtended) {
                return themeExtended.defaultTheme.schemeFile;
            } else {
                return "kdeglobals";
            }
        }

        return applyTheme.schemeFile;
    }

    sourceComponent: MochaApp.BackgroundTracker {
        activity: root.myView.isReady ? root.myView.lastUsedActivity : ""
        location: plasmoid.location
        screenName: mochaView && mochaView.positioner ? mochaView.positioner.currentScreenName : ""
    }
}
