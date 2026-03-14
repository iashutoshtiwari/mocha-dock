/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "primaryoutputwatcher.h"

#include <KWindowSystem>
#include <QDebug>
#include <QGuiApplication>
#include <QScreen>

#include "qwayland-kde-primary-output-v1.h"
#include <QtWaylandClient/QWaylandClientExtensionTemplate>

class WaylandPrimaryOutput : public QWaylandClientExtensionTemplate<WaylandPrimaryOutput>, public QtWayland::kde_primary_output_v1
{
    Q_OBJECT
public:
    WaylandPrimaryOutput()
        : QWaylandClientExtensionTemplate(1 /* version */)
    {
        initialize();
    }

    void kde_primary_output_v1_primary_output(const QString &outputName) override
    {
        Q_EMIT primaryOutputChanged(outputName);
    }

Q_SIGNALS:
    void primaryOutputChanged(const QString &outputName);
};

PrimaryOutputWatcher::PrimaryOutputWatcher(QObject *parent)
    : QObject(parent)
{
    setupRegistry();
}

void PrimaryOutputWatcher::setPrimaryOutputName(const QString &newOutputName)
{
    if (newOutputName != m_primaryOutputName) {
        const QString oldOutputName = m_primaryOutputName;
        m_primaryOutputName = newOutputName;
        Q_EMIT primaryOutputNameChanged(oldOutputName, newOutputName);
    }
}

void PrimaryOutputWatcher::setupRegistry()
{
    m_primaryOutputName = qGuiApp->primaryScreen()->name();

    auto *primaryOutput = new WaylandPrimaryOutput();

    connect(primaryOutput, &WaylandPrimaryOutput::primaryOutputChanged, this, [this](const QString &outputName) {
        m_primaryOutputWayland = outputName;
        if (screenForName(outputName)) {
            setPrimaryOutputName(outputName);
        }
    });

    // In case the outputName was received before Qt reported the screen
    connect(qGuiApp, &QGuiApplication::screenAdded, this, [this](QScreen *screen) {
        if (screen->name() == m_primaryOutputWayland) {
            setPrimaryOutputName(m_primaryOutputWayland);
        }
    });
}

bool PrimaryOutputWatcher::nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result)
{
    Q_UNUSED(result);
    Q_UNUSED(eventType);
    Q_UNUSED(message);
    return false;
}

QScreen *PrimaryOutputWatcher::screenForName(const QString &outputName) const
{
    const auto screens = qGuiApp->screens();
    for (auto screen : screens) {
        if (screen->name() == outputName) {
            return screen;
        }
    }
    return nullptr;
}

QScreen *PrimaryOutputWatcher::primaryScreen() const
{
    auto screen = screenForName(m_primaryOutputName);
    if (!screen) {
        qDebug() << "PrimaryOutputWatcher: Could not find primary screen:" << m_primaryOutputName;
        return qGuiApp->primaryScreen();
    }
    return screen;
}

#include "primaryoutputwatcher.moc"
