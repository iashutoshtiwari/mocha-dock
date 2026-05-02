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

class SettingsWindow : public QObject
{
    Q_OBJECT
public:
    explicit SettingsWindow(Mocha::Corona *corona, QObject *parent = nullptr);
    ~SettingsWindow() override;

    void show();

private:
    Mocha::Corona *m_corona;
    QQmlApplicationEngine *m_engine;
};

}
}

#endif
