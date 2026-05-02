/*
    SPDX-FileCopyrightText: 2026 Ashutosh Tiwari <contact@ashutoshtiwari.dev>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "settingswindow.h"

// local
#include "../mochacorona.h"
#include "../settings/universalsettings.h"
#include "../layouts/manager.h"

// Qt
#include <QQmlContext>
#include <QDebug>
#include <KLocalizedString>
#include <KLocalizedContext>
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

void SettingsWindow::show(int firstPage)
{
    qDebug() << "SettingsWindow::show() requested, page:" << firstPage;
    if (m_engine->rootObjects().isEmpty()) {
        const QString qmlPath = m_corona->kPackage().filePath("settingsui");
        qDebug() << "Loading settings QML from:" << qmlPath;
        if (qmlPath.isEmpty()) {
            qWarning() << "Could not find settingsui in package!";
            return;
        }

        //! Register KLocalizedContext so i18n()/i18nc() work in QML
        m_engine->rootContext()->setContextObject(new KLocalizedContext(m_engine));

        //! Expose backend objects to QML
        m_engine->rootContext()->setContextProperty(QStringLiteral("mochaCorona"), m_corona);
        m_engine->rootContext()->setContextProperty(QStringLiteral("universalSettings"), m_corona->universalSettings());
        m_engine->rootContext()->setContextProperty(QStringLiteral("layoutsManager"), m_corona->layoutsManager());
        m_engine->rootContext()->setContextProperty(QStringLiteral("initialPage"), firstPage);

        m_engine->load(QUrl::fromLocalFile(qmlPath));
    } else {
        QObject *rootObject = m_engine->rootObjects().first();
        if (rootObject) {
            rootObject->setProperty("visible", true);
            QMetaObject::invokeMethod(rootObject, "goToPage", Q_ARG(QVariant, firstPage));
        }
    }
}

}
}
