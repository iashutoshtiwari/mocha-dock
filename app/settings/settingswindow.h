/*
    SPDX-FileCopyrightText: 2026 Ashutosh Tiwari <contact@ashutoshtiwari.dev>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef SETTINGSWINDOW_H
#define SETTINGSWINDOW_H

#include <QObject>
#include <QPointer>
#include <QQmlApplicationEngine>

namespace Mocha {
class Corona;

namespace Settings {

/**
 * @class SettingsWindow
 * @brief The main entry point for the Kirigami-based settings UI.
 * 
 * This class is responsible for loading the QML engine and showing the 
 * modernized settings interface. It replaces the legacy QWidget-based 
 * settings dialogs to ensure compatibility with Wayland and Plasma 6.
 */
class SettingsWindow : public QObject
{
    Q_OBJECT
public:
    /**
     * @brief Constructs a SettingsWindow.
     * @param corona The Corona instance.
     * @param parent The parent QObject.
     */
    explicit SettingsWindow(Mocha::Corona *corona, QObject *parent = nullptr);
    ~SettingsWindow() override;

    /**
     * @brief Shows the settings window.
     */
    void show(int firstPage = 0);

private:
    Mocha::Corona *m_corona;
    QQmlApplicationEngine *m_engine;
};

}
}

#endif
