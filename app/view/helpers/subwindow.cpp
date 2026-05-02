/*
    SPDX-FileCopyrightText: 2020 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "subwindow.h"

// local
#include "../view.h"
#include "../visibilitymanager.h"

// Qt
#include <QDebug>
#include <QSurfaceFormat>
#include <QQuickView>
#include <QTimer>


namespace Mocha {
namespace ViewPart {

SubWindow::SubWindow(Mocha::View *view, QString debugType) :
    m_mochaView(view)
{
    m_corona = qobject_cast<Mocha::Corona *>(view->corona());

    m_debugMode = (qApp->arguments().contains("-d") && qApp->arguments().contains("--kwinedges"));
    m_debugType = debugType;

    m_showColor = QColor(Qt::transparent);
    m_hideColor = QColor(Qt::transparent);

    setTitle(validTitle());
    setColor(m_showColor);
    setDefaultAlphaBuffer(true);

    setFlags(Qt::FramelessWindowHint
             | Qt::WindowStaysOnTopHint
             | Qt::NoDropShadowWindowHint
             | Qt::WindowDoesNotAcceptFocus);

    m_fixGeometryTimer.setSingleShot(true);
    m_fixGeometryTimer.setInterval(500);
    connect(&m_fixGeometryTimer, &QTimer::timeout, this, &SubWindow::fixGeometry);

    connect(this, &QQuickView::xChanged, this, &SubWindow::startGeometryTimer);
    connect(this, &QQuickView::yChanged, this, &SubWindow::startGeometryTimer);
    connect(this, &QQuickView::widthChanged, this, &SubWindow::startGeometryTimer);
    connect(this, &QQuickView::heightChanged, this, &SubWindow::startGeometryTimer);

    connect(this, &SubWindow::calculatedGeometryChanged, this, &SubWindow::fixGeometry);

    connect(m_mochaView, &Mocha::View::absoluteGeometryChanged, this, &SubWindow::updateGeometry);
    connect(m_mochaView, &Mocha::View::screenGeometryChanged, this, &SubWindow::updateGeometry);
    connect(m_mochaView, &Mocha::View::locationChanged, this, &SubWindow::updateGeometry);
    connect(m_mochaView, &QQuickView::screenChanged, this, [this]() {
        setScreen(m_mochaView->screen());
        updateGeometry();
    });

    connect(m_corona->wm(), &WindowSystem::AbstractWindowInterface::mochaWindowAdded, this, &SubWindow::updateWaylandId);

    setScreen(m_mochaView->screen());

    //! Set up LayerShellQt before the first show() to avoid
    //! "already has a shell integration" warning on subsequent shows
    m_corona->wm()->setViewExtraFlags(this);

    show();
    hideWithMask();
}

SubWindow::~SubWindow()
{
    m_inDelete = true;

    m_corona->wm()->unregisterIgnoredWindow(m_trackedWindowId);

    m_mochaView = nullptr;

    // clear mode
    m_visibleHackTimer1.stop();
    m_visibleHackTimer2.stop();
    for (auto &c : connectionsHack) {
        disconnect(c);
    }
}

int SubWindow::location()
{
    return (int)m_mochaView->location();
}

int SubWindow::thickness() const
{
    return m_thickness;
}

QString SubWindow::validTitlePrefix() const
{
    return QString("#subwindow#");
}

QString SubWindow::validTitle() const
{
    return QString(validTitlePrefix() + QString::number(m_mochaView->containment()->id()));
}

Mocha::View *SubWindow::parentView()
{
    return m_mochaView;
}

Mocha::WindowSystem::WindowId SubWindow::trackedWindowId()
{
    if (m_trackedWindowId.toInt() <= 0) {
        updateWaylandId();
    }

    return m_trackedWindowId;
}

void SubWindow::fixGeometry()
{
    if (!m_calculatedGeometry.isEmpty()
            && (m_calculatedGeometry.x() != x() || m_calculatedGeometry.y() != y()
                || m_calculatedGeometry.width() != width() || m_calculatedGeometry.height() != height())) {
        setMinimumSize(m_calculatedGeometry.size());
        setMaximumSize(m_calculatedGeometry.size());
        resize(m_calculatedGeometry.size());
        setPosition(m_calculatedGeometry.x(), m_calculatedGeometry.y());
    }
}

void SubWindow::updateWaylandId()
{
    Mocha::WindowSystem::WindowId newId = m_corona->wm()->winIdFor("mocha-dock", validTitle());

    if (m_trackedWindowId != newId) {
        if (!m_trackedWindowId.isNull()) {
            m_corona->wm()->unregisterIgnoredWindow(m_trackedWindowId);
        }

        m_trackedWindowId = newId;
        m_corona->wm()->registerIgnoredWindow(m_trackedWindowId);
    }
}

void SubWindow::startGeometryTimer()
{
    m_fixGeometryTimer.start();
}

bool SubWindow::event(QEvent *e)
{
    //! LayerShellQt is configured once in the constructor before the first show().
    //! Calling setViewExtraFlags() again on subsequent Show events would trigger
    //! "already has a shell integration" warnings from LayerShellQt::Window::get().

    return QQuickView::event(e);
}


void SubWindow::hideWithMask()
{
    if (m_debugMode) {
        qDebug() << m_debugType + " :: MASK HIDE...";
    }

    setMask(VisibilityManager::ISHIDDENMASK);

    //! repaint in order to update mask immediately
    setColor(m_hideColor);
}

void SubWindow::showWithMask()
{
    if (m_debugMode) {
        qDebug() << m_debugType + " :: MASK SHOW...";
    }

    setMask(QRegion());

    //! repaint in order to update mask immediately
    setColor(m_showColor);
}

}
}
