/*
    SPDX-FileCopyrightText: 2024 Mocha Dock Team
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef LAUNCHERHELPER_H
#define LAUNCHERHELPER_H

#include <QObject>
#include <QString>

namespace Mocha {
namespace Tasks {

class LauncherHelper : public QObject
{
    Q_OBJECT

public:
    explicit LauncherHelper(QObject *parent = nullptr);

    Q_INVOKABLE void launchDesktopFile(const QString &desktopFileName);
};

} // namespace Tasks
} // namespace Mocha

#endif
