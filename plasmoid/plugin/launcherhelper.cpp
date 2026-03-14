/*
    SPDX-FileCopyrightText: 2024 Latte Dock Team
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "launcherhelper.h"

#include <QDebug>
#include <QProcess>
#include <QProcessEnvironment>
#include <QStandardPaths>

namespace Latte {
namespace Tasks {

LauncherHelper::LauncherHelper(QObject *parent)
    : QObject(parent)
{
}

void LauncherHelper::launchDesktopFile(const QString &desktopFileName)
{
    qDebug() << "LauncherHelper::launchDesktopFile" << desktopFileName;

    // Ensure we have the .desktop extension
    QString fullName = desktopFileName;
    if (!fullName.endsWith(QLatin1String(".desktop"))) {
        fullName += QLatin1String(".desktop");
    }

    // Find the desktop file
    QString desktopFilePath = QStandardPaths::locate(QStandardPaths::ApplicationsLocation, fullName);
    if (desktopFilePath.isEmpty()) {
        qWarning() << "LauncherHelper: could not find desktop file for" << fullName;
        return;
    }

    qDebug() << "LauncherHelper: launching via gio:" << desktopFilePath;

    //! Launch via "gio launch" with a clean environment that removes
    //! QT_WAYLAND_SHELL_INTEGRATION=layer-shell (set by LayerShellQt).
    //! Without this, child processes inherit layer-shell and lose decorations.
    auto *process = new QProcess();
    process->setProgram(QStringLiteral("gio"));
    process->setArguments({QStringLiteral("launch"), desktopFilePath});

    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.remove(QStringLiteral("QT_WAYLAND_SHELL_INTEGRATION"));
    process->setProcessEnvironment(env);

    process->startDetached();
    delete process;
}

} // namespace Tasks
} // namespace Latte
