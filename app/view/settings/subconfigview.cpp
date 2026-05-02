/*
    SPDX-FileCopyrightText: 2020 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "subconfigview.h"

//local
#include "../view.h"
#include "../../mochacorona.h"
#include "../../layouts/manager.h"
#include "../../plasma/extended/theme.h"
#include "../../settings/universalsettings.h"
#include "../../shortcuts/globalshortcuts.h"
#include "../../shortcuts/shortcutstracker.h"
#include "../../wm/windowmanager.h"

// Qt
#include <QQmlEngine>

// KDE
#include <KLocalizedContext>
#include <KWindowSystem>

// Plasma
#include <PlasmaQuick/AppletQuickItem>

namespace Mocha {
namespace ViewPart {

SubConfigView::SubConfigView(Mocha::View *view, const QString &title, const bool &isNormalWindow)
    : QQuickView(nullptr),
      m_isNormalWindow(isNormalWindow)
{
    m_corona = qobject_cast<Mocha::Corona *>(view->containment()->corona());

    connect(this, &QWindow::windowTitleChanged, this, &SubConfigView::updateWaylandId);
    connect(m_corona->wm(), &WindowSystem::WindowManager::mochaWindowAdded, this, &SubConfigView::updateWaylandId);

    m_validTitle = title;
    setTitle(m_validTitle);

    setScreen(view->screen());
    setIcon(qGuiApp->windowIcon());

    if (!m_isNormalWindow) {
        setFlags(wFlags());
        m_corona->wm()->setViewExtraFlags(this, true);
    }

    m_screenSyncTimer.setSingleShot(true);
    m_screenSyncTimer.setInterval(100);

    connections << connect(&m_screenSyncTimer, &QTimer::timeout, this, [this]() {
        if (!m_mochaView) {
            return;
        }

        setScreen(m_mochaView->screen());

        syncGeometry();
    });

    m_showTimer.setSingleShot(true);
    m_showTimer.setInterval(0);

    connections << connect(&m_showTimer, &QTimer::timeout, this, [this]() {
        syncSlideEffect();
        show();
    });
}

SubConfigView::~SubConfigView()
{
    qDebug() << validTitle() << " deleting...";

    m_corona->dialogShadows()->removeWindow(this);

    m_corona->wm()->unregisterIgnoredWindow(m_waylandWindowId);

    for (const auto &var : connections) {
        QObject::disconnect(var);
    }

    for (const auto &var : viewconnections) {
        QObject::disconnect(var);
    }
}

void SubConfigView::init()
{
    qDebug() << validTitle() << " : initialization started...";

    setDefaultAlphaBuffer(true);
    setColor(Qt::transparent);

    rootContext()->setContextProperty(QStringLiteral("viewConfig"), this);
    rootContext()->setContextProperty(QStringLiteral("shortcutsEngine"), m_corona->globalShortcuts()->shortcutsTracker());

    if (m_corona) {
        rootContext()->setContextProperty(QStringLiteral("universalSettings"), m_corona->universalSettings());
        rootContext()->setContextProperty(QStringLiteral("layoutsManager"), m_corona->layoutsManager());
        rootContext()->setContextProperty(QStringLiteral("themeExtended"), m_corona->themeExtended());
    }

    KLocalizedContext *context = new KLocalizedContext(engine());
    context->setTranslationDomain(QStringLiteral("mocha-dock"));
    engine()->rootContext()->setContextObject(context);
}

Qt::WindowFlags SubConfigView::wFlags() const
{
    return (flags() | Qt::FramelessWindowHint) & ~Qt::WindowDoesNotAcceptFocus;
}

QString SubConfigView::validTitle() const
{
    return m_validTitle;
}

Mocha::WindowSystem::WindowId SubConfigView::trackedWindowId()
{
    if (m_waylandWindowId.toInt() <= 0) {
        updateWaylandId();
    }

    return m_waylandWindowId;
}

Mocha::Corona *SubConfigView::corona() const
{
    return m_corona;
}

Mocha::View *SubConfigView::parentView() const
{
    return m_mochaView;
}

void SubConfigView::setParentView(Mocha::View *view, const bool &immediate)
{
    if (m_mochaView == view) {
        return;
    }

    initParentView(view);
}

void SubConfigView::initParentView(Mocha::View *view)
{
    for (const auto &var : viewconnections) {
        QObject::disconnect(var);
    }

    m_mochaView = view;

    viewconnections << connect(m_mochaView->positioner(), &ViewPart::Positioner::canvasGeometryChanged, this, &SubConfigView::syncGeometry);

    //! Assign app interfaces in be accessible through containment graphic item
    QQuickItem *containmentGraphicItem = PlasmaQuick::AppletQuickItem::itemForApplet(m_mochaView->containment());
    rootContext()->setContextProperty(QStringLiteral("plasmoid"), containmentGraphicItem);
    rootContext()->setContextProperty(QStringLiteral("mochaView"), m_mochaView);
}

void SubConfigView::requestActivate()
{
    updateWaylandId();
    m_corona->wm()->requestActivate(m_waylandWindowId);
}

void SubConfigView::showAfter(int msecs)
{
    if (isVisible()) {
        return;
    }

    m_showTimer.setInterval(msecs);
    m_showTimer.start();

}

void SubConfigView::syncSlideEffect()
{
    if (!m_mochaView || !m_mochaView->containment()) {
        return;
    }

    auto slideLocation = WindowSystem::WindowManager::Slide::None;

    switch (m_mochaView->containment()->location()) {
    case Plasma::Types::TopEdge:
        slideLocation = WindowSystem::WindowManager::Slide::Top;
        break;

    case Plasma::Types::RightEdge:
        slideLocation = WindowSystem::WindowManager::Slide::Right;
        break;

    case Plasma::Types::BottomEdge:
        slideLocation = WindowSystem::WindowManager::Slide::Bottom;
        break;

    case Plasma::Types::LeftEdge:
        slideLocation = WindowSystem::WindowManager::Slide::Left;
        break;

    default:
        qDebug() << staticMetaObject.className() << "wrong location";
        break;
    }

    m_corona->wm()->slideWindow(*this, slideLocation);
}

void SubConfigView::showEvent(QShowEvent *ev)
{
    QQuickView::showEvent(ev);

    //! readd shadows after hiding because the window shadows are not shown again after first showing
    m_corona->dialogShadows()->addWindow(this, m_enabledBorders);
}

bool SubConfigView::event(QEvent *e)
{
    return QQuickView::event(e);
}

void SubConfigView::updateWaylandId()
{
    Mocha::WindowSystem::WindowId newId = m_corona->wm()->winIdFor("mocha-dock", validTitle());

    if (m_waylandWindowId != newId) {
        if (!m_waylandWindowId.isNull()) {
            m_corona->wm()->unregisterIgnoredWindow(m_waylandWindowId);
        }

        m_waylandWindowId = newId;
        m_corona->wm()->registerIgnoredWindow(m_waylandWindowId);
    }
}

KSvg::FrameSvg::EnabledBorders SubConfigView::enabledBorders() const
{
    return m_enabledBorders;
}

}
}
