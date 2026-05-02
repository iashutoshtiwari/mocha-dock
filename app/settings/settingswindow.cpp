/*
    SPDX-FileCopyrightText: 2026 Ashutosh Tiwari <contact@ashutoshtiwari.dev>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "settingswindow.h"

// local
#include "../mochacorona.h"

// Qt
#include <QQmlContext>
#include <QDebug>
#include <KLocalizedString>
#include <KPackage/Package>

namespace Mocha {
namespace Settings {

SettingsWindow::SettingsWindow(Mocha::Corona *corona, QObject *parent)
    : QObject(parent),
      m_corona(corona),
      m_engine(new QQmlApplicationEngine(this))
{
}

SettingsWindow::~SettingsWindow()
{
}

void SettingsWindow::show()
{
    qDebug() << "SettingsWindow::show() requested...";
    if (m_engine->rootObjects().isEmpty()) {
        const QString qmlPath = m_corona->kPackage().filePath("settingsui");
        qDebug() << "Loading settings QML from:" << qmlPath;
        if (qmlPath.isEmpty()) {
            qWarning() << "Could not find settingsui in package!";
            return;
        }

        m_engine->rootContext()->setContextProperty(QStringLiteral("mochaCorona"), m_corona);
        m_engine->load(QUrl::fromLocalFile(qmlPath));
    } else {
        QObject *rootObject = m_engine->rootObjects().first();
        if (rootObject) {
            rootObject->setProperty("visible", true);
            // On Wayland, we might need to call raise() or requestActivate()
            // but for QQuickWindow it is usually done via visible: true
        }
    }
}

}
}
