/*
    SPDX-FileCopyrightText: 2016-2024 Smith AR <audoban@openmailbox.org>
    SPDX-FileCopyrightText: 2016-2024 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-FileCopyrightText: 2026 Ashutosh Tiwari <contact@ashutoshtiwari.dev>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "windowmanager.h"

// local
#include "tracker/schemes.h"
#include "tracker/windowstracker.h"
#include "../mochacorona.h"
#include "../view/positioner.h"
#include "../view/view.h"

// Qt
#include <QApplication>
#include <QDebug>
#include <QLatin1String>
#include <QQuickView>
#include <QTimer>
#include <QtDBus>

// KDE
#include <KWindowSystem>
#include <KWindowInfo>
#include <KWayland/Client/plasmavirtualdesktop.h>
#include <taskmanager/tasktools.h>
#include <PlasmaActivities/Controller>

// LayerShell
#include <LayerShellQt/Window>

using namespace KWayland::Client;

namespace Mocha {
namespace WindowSystem {

#define MAXPLASMAPANELTHICKNESS 96
#define MAXSIDEPANELTHICKNESS 512

WindowManager::WindowManager(QObject *parent)
    : QObject(parent)
{
    m_activities = new KActivities::Consumer(this);
    m_currentActivity = m_activities->currentActivity();

    m_corona = qobject_cast<Mocha::Corona *>(parent);
    m_windowsTracker = new Tracker::Windows(this);
    m_schemesTracker = new Tracker::Schemes(this);

    m_windowWaitingTimer.setInterval(150);
    m_windowWaitingTimer.setSingleShot(true);

    connect(&m_windowWaitingTimer, &QTimer::timeout, this, [this]() {
        WindowId wid = m_windowChangedWaiting;
        m_windowChangedWaiting = WindowId::nil();
        emit windowChanged(wid);
    });

    connect(this, &WindowManager::windowRemoved, this, &WindowManager::windowRemovedSlot);

    connect(m_activities.data(), &KActivities::Consumer::currentActivityChanged, this, [this](const QString &id) {
        m_currentActivity = id;
        emit currentActivityChanged();
    });

    connect(KWindowSystem::self(), &KWindowSystem::showingDesktopChanged, this, &WindowManager::setIsShowingDesktop);

    //! VirtualDesktopInfo self-initializes via Wayland protocols
    m_virtualDesktopInfo = new TaskManager::VirtualDesktopInfo(this);
    connect(m_virtualDesktopInfo, &TaskManager::VirtualDesktopInfo::currentDesktopChanged, this, [this]() {
        setCurrentDesktop(m_virtualDesktopInfo->currentDesktop().toString());
    });
}

WindowManager::~WindowManager()
{
    m_windowWaitingTimer.stop();
    m_schemesTracker->deleteLater();
    m_windowsTracker->deleteLater();
}

void WindowManager::initWindowManagement(KWayland::Client::PlasmaWindowManagement *windowManagement)
{
    if (m_windowManagement == windowManagement) {
        return;
    }

    m_windowManagement = windowManagement;

    connect(m_windowManagement, &PlasmaWindowManagement::windowCreated, this, &WindowManager::windowCreatedProxy);
    connect(m_windowManagement, &PlasmaWindowManagement::activeWindowChanged, this, [this]() noexcept {
        auto w = m_windowManagement->activeWindow();
        if (!w || (w && (!m_ignoredWindows.contains(w->uuid()))) ) {
            emit activeWindowChanged(w ? w->uuid() : WindowId::nil());
        }

    }, Qt::QueuedConnection);
}

bool WindowManager::isShowingDesktop() const
{
    return m_isShowingDesktop;
}

void WindowManager::setIsShowingDesktop(const bool &showing)
{
    if (m_isShowingDesktop == showing) {
        return;
    }

    m_isShowingDesktop = showing;
    emit isShowingDesktopChanged();
}

QString WindowManager::currentDesktop()
{
    return m_currentDesktop;
}

QString WindowManager::currentActivity()
{
    return m_currentActivity;
}

void WindowManager::setCurrentDesktop(QString desktop)
{
    if (m_currentDesktop == desktop) {
        return;
    }

    m_currentDesktop = desktop;
    emit currentDesktopChanged();
}

Mocha::Corona *WindowManager::corona()
{
    return m_corona;
}

Tracker::Schemes *WindowManager::schemesTracker()
{
    return m_schemesTracker;
}

Tracker::Windows *WindowManager::windowsTracker() const
{
    return m_windowsTracker;
}

bool WindowManager::isIgnored(const WindowId &wid) const
{
    return m_ignoredWindows.contains(wid);
}

bool WindowManager::isFullScreenWindow(const QRect &wGeometry) const
{
    if (wGeometry.isEmpty()) {
        return false;
    }

    for (const auto scr : qGuiApp->screens()) {
        auto screenGeometry = scr->geometry();

        if (wGeometry == screenGeometry) {
            return true;
        }
    }

    return false;
}

bool WindowManager::isPlasmaPanel(const QRect &wGeometry) const
{
    if (wGeometry.isEmpty()) {
        return false;
    }

    bool isTouchingHorizontalEdge{false};
    bool isTouchingVerticalEdge{false};

    for (const auto scr : qGuiApp->screens()) {
        auto screenGeometry = scr->geometry();

        if (screenGeometry.contains(wGeometry.center())) {
            if (wGeometry.y() == screenGeometry.y() || wGeometry.bottom() == screenGeometry.bottom()) {
                isTouchingHorizontalEdge = true;
            }

            if (wGeometry.left() == screenGeometry.left() || wGeometry.right() == screenGeometry.right()) {
                isTouchingVerticalEdge = true;
            }

            if (isTouchingVerticalEdge && isTouchingHorizontalEdge) {
                break;
            }
        }
    }

    if ((isTouchingHorizontalEdge && wGeometry.height() < MAXPLASMAPANELTHICKNESS)
            || (isTouchingVerticalEdge && wGeometry.width() < MAXPLASMAPANELTHICKNESS)) {
        return true;
    }

    return false;
}

bool WindowManager::isSidepanel(const QRect &wGeometry) const
{
    bool isVertical = wGeometry.height() > wGeometry.width();

    int thickness = qMin(wGeometry.width(), wGeometry.height());
    int length = qMax(wGeometry.width(), wGeometry.height());

    QRect screenGeometry;

    for (const auto scr : qGuiApp->screens()) {
        auto curScrGeometry = scr->geometry();

        if (curScrGeometry.contains(wGeometry.center())) {
            screenGeometry = curScrGeometry;
            break;
        }
    }

    bool thicknessIsAcccepted = isVertical && ((thickness > MAXPLASMAPANELTHICKNESS) && (thickness < MAXSIDEPANELTHICKNESS));
    bool lengthIsAccepted = isVertical && !screenGeometry.isEmpty() && (length > 0.6 * screenGeometry.height());
    float sideRatio = (float)wGeometry.width() / (float)wGeometry.height();

    return (thicknessIsAcccepted && lengthIsAccepted && sideRatio<0.4);
}

bool WindowManager::hasBlockedTracking(const WindowId &wid) const
{
    return (!isWhitelistedWindow(wid) && (isRegisteredPlasmaIgnoredWindow(wid) || isIgnored(wid)));
}

bool WindowManager::isRegisteredPlasmaIgnoredWindow(const WindowId &wid) const
{
    return m_plasmaIgnoredWindows.contains(wid);
}

bool WindowManager::isWhitelistedWindow(const WindowId &wid) const
{
    return m_whitelistedWindows.contains(wid);
}

bool WindowManager::inCurrentDesktopActivity(const WindowInfoWrap &winfo)
{
    return (winfo.isValid() && winfo.isOnDesktop(currentDesktop()) && winfo.isOnActivity(currentActivity()));
}

void WindowManager::registerIgnoredWindow(WindowId wid)
{
    if (!wid.isNull() && !m_ignoredWindows.contains(wid)) {
        m_ignoredWindows.append(wid);

        if (m_windowManagement) {
            KWayland::Client::PlasmaWindow *w = windowFor(wid);
            if (w) {
                untrackWindow(w);
            }
        }
        emit windowChanged(wid);
    }
}

void WindowManager::unregisterIgnoredWindow(WindowId wid)
{
    if (m_ignoredWindows.contains(wid)) {
        m_ignoredWindows.removeAll(wid);
        emit windowRemoved(wid);
    }
}

void WindowManager::registerPlasmaIgnoredWindow(WindowId wid)
{
    if (!wid.isNull() && !m_plasmaIgnoredWindows.contains(wid)) {
        m_plasmaIgnoredWindows.append(wid);
        emit windowChanged(wid);
    }
}

void WindowManager::unregisterPlasmaIgnoredWindow(WindowId wid)
{
    if (m_plasmaIgnoredWindows.contains(wid)) {
        m_plasmaIgnoredWindows.removeAll(wid);
    }
}

void WindowManager::registerWhitelistedWindow(WindowId wid)
{
    if (!wid.isNull() && !m_whitelistedWindows.contains(wid)) {
        m_whitelistedWindows.append(wid);
        emit windowChanged(wid);
    }
}

void WindowManager::unregisterWhitelistedWindow(WindowId wid)
{
    if (m_whitelistedWindows.contains(wid)) {
        m_whitelistedWindows.removeAll(wid);
    }
}

void WindowManager::windowRemovedSlot(WindowId wid)
{
    if (m_plasmaIgnoredWindows.contains(wid)) {
        unregisterPlasmaIgnoredWindow(wid);
    }

    if (m_ignoredWindows.contains(wid)) {
        unregisterIgnoredWindow(wid);
    }

    if (m_whitelistedWindows.contains(wid)) {
        unregisterWhitelistedWindow(wid);
    }
}

void WindowManager::switchToNextActivity()
{
    QStringList runningActivities = m_activities->activities();
    if (runningActivities.count() <= 1) {
        return;
    }

    int curPos = runningActivities.indexOf(m_currentActivity);
    int nextPos = curPos + 1;

    if (curPos == runningActivities.count() - 1) {
        nextPos = 0;
    }

    KActivities::Controller activitiesController;
    activitiesController.setCurrentActivity(runningActivities.at(nextPos));
}

void WindowManager::switchToPreviousActivity()
{
    QStringList runningActivities = m_activities->activities();
    if (runningActivities.count() <= 1) {
        return;
    }

    int curPos = runningActivities.indexOf(m_currentActivity);
    int nextPos = curPos - 1;

    if (curPos == 0) {
        nextPos = runningActivities.count() - 1;
    }

    KActivities::Controller activitiesController;
    activitiesController.setCurrentActivity(runningActivities.at(nextPos));
}

void WindowManager::switchToNextVirtualDesktop()
{
    QVariantList desktops = m_virtualDesktopInfo->desktopIds();
    if (desktops.count() <= 1) {
        return;
    }

    int curPos = desktops.indexOf(m_virtualDesktopInfo->currentDesktop());
    int nextPos = curPos + 1;

    if (curPos >= desktops.count() - 1) {
        if (m_virtualDesktopInfo->navigationWrappingAround()) {
            nextPos = 0;
        } else {
            return;
        }
    }

    m_virtualDesktopInfo->requestActivate(desktops[nextPos]);
}

void WindowManager::switchToPreviousVirtualDesktop()
{
    QVariantList desktops = m_virtualDesktopInfo->desktopIds();
    if (desktops.count() <= 1) {
        return;
    }

    int curPos = desktops.indexOf(m_virtualDesktopInfo->currentDesktop());
    int nextPos = curPos - 1;

    if (curPos <= 0) {
        if (m_virtualDesktopInfo->navigationWrappingAround()) {
            nextPos = desktops.count() - 1;
        } else {
            return;
        }
    }

    m_virtualDesktopInfo->requestActivate(desktops[nextPos]);
}

void WindowManager::considerWindowChanged(WindowId wid)
{
    if (m_windowChangedWaiting == wid && m_windowWaitingTimer.isActive()) {
        m_windowWaitingTimer.start();
        return;
    }

    if (m_windowChangedWaiting != wid && !m_windowWaitingTimer.isActive()) {
        m_windowChangedWaiting = wid;
        m_windowWaitingTimer.start();
    }

    if (m_windowChangedWaiting != wid && m_windowWaitingTimer.isActive()) {
        m_windowWaitingTimer.stop();
        emit windowChanged(m_windowChangedWaiting);
        m_windowChangedWaiting = wid;
        m_windowWaitingTimer.start();
    }
}

void WindowManager::setViewExtraFlags(QWindow *view, bool isPanelWindow, Mocha::Types::Visibility mode)
{
    if (!view) return;
    auto layerWindow = LayerShellQt::Window::get(view);
    if (!layerWindow) return;

    bool atBottom = !isPanelWindow && (mode == Mocha::Types::WindowsCanCover || mode == Mocha::Types::WindowsAlwaysCover);

    if (atBottom) {
        layerWindow->setLayer(LayerShellQt::Window::LayerBottom);
    } else {
        layerWindow->setLayer(LayerShellQt::Window::LayerTop);
    }

    layerWindow->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
}

void WindowManager::setViewStruts(QWindow *view, const QRect &rect, Plasma::Types::Location location)
{
    if (!view) return;
    auto layerWindow = LayerShellQt::Window::get(view);
    if (!layerWindow) return;

    LayerShellQt::Window::Anchors anchors;

    switch (location) {
    case Plasma::Types::TopEdge:
        anchors = {LayerShellQt::Window::AnchorTop | LayerShellQt::Window::AnchorLeft | LayerShellQt::Window::AnchorRight};
        layerWindow->setExclusiveZone(rect.height());
        break;
    case Plasma::Types::BottomEdge:
        anchors = {LayerShellQt::Window::AnchorBottom | LayerShellQt::Window::AnchorLeft | LayerShellQt::Window::AnchorRight};
        layerWindow->setExclusiveZone(rect.height());
        break;
    case Plasma::Types::LeftEdge:
        anchors = {LayerShellQt::Window::AnchorLeft | LayerShellQt::Window::AnchorTop | LayerShellQt::Window::AnchorBottom};
        layerWindow->setExclusiveZone(rect.width());
        break;
    case Plasma::Types::RightEdge:
        anchors = {LayerShellQt::Window::AnchorRight | LayerShellQt::Window::AnchorTop | LayerShellQt::Window::AnchorBottom};
        layerWindow->setExclusiveZone(rect.width());
        break;
    default:
        return;
    }

    layerWindow->setAnchors(anchors);
}

void WindowManager::setWindowPosition(QWindow *window, const Plasma::Types::Location &location, const QRect &geometry)
{
    if (!window) return;
    auto layerWindow = LayerShellQt::Window::get(window);
    if (!layerWindow) {
        window->setPosition(geometry.topLeft());
        return;
    }

    LayerShellQt::Window::Anchors anchors;
    QMargins margins(0, 0, 0, 0);

    switch (location) {
    case Plasma::Types::TopEdge:
        anchors = {LayerShellQt::Window::AnchorTop | LayerShellQt::Window::AnchorLeft};
        margins.setLeft(geometry.x());
        margins.setTop(geometry.y());
        break;
    case Plasma::Types::BottomEdge:
        anchors = {LayerShellQt::Window::AnchorBottom | LayerShellQt::Window::AnchorLeft};
        margins.setLeft(geometry.x());
        margins.setBottom(window->screen()->geometry().bottom() - geometry.bottom());
        break;
    case Plasma::Types::LeftEdge:
        anchors = {LayerShellQt::Window::AnchorLeft | LayerShellQt::Window::AnchorTop};
        margins.setLeft(geometry.x());
        margins.setTop(geometry.y());
        break;
    case Plasma::Types::RightEdge:
        anchors = {LayerShellQt::Window::AnchorRight | LayerShellQt::Window::AnchorTop};
        margins.setRight(window->screen()->geometry().right() - geometry.right());
        margins.setTop(geometry.y());
        break;
    default:
        break;
    }

    layerWindow->setAnchors(anchors);
    layerWindow->setMargins(margins);
}

void WindowManager::removeViewStruts(QWindow *view)
{
    if (!view) return;
    auto layerWindow = LayerShellQt::Window::get(view);
    if (layerWindow) {
        layerWindow->setExclusiveZone(-1);
    }
}

void WindowManager::setWindowOnActivities(const WindowId &wid, const QStringList &nextactivities)
{
    auto winfo = requestInfo(wid);
    auto w = windowFor(wid);
    if (!w) return;

    QStringList curactivities = winfo.activities();

    if (!winfo.isOnAllActivities() && nextactivities.isEmpty()) {
        for(int i=0; i<curactivities.count(); ++i) {
            w->requestLeaveActivity(curactivities[i]);
        }
    } else if (curactivities != nextactivities) {
        QStringList requestenter;
        QStringList requestleave;

        for (int i=0; i<nextactivities.count(); ++i) {
            if (!curactivities.contains(nextactivities[i])) {
                requestenter << nextactivities[i];
            }
        }

        for (int i=0; i<curactivities.count(); ++i) {
            if (!nextactivities.contains(curactivities[i])) {
                requestleave << curactivities[i];
            }
        }

        for (int i=0; i<requestleave.count(); ++i) {
            w->requestLeaveActivity(requestleave[i]);
        }

        for (int i=0; i<requestenter.count(); ++i) {
            w->requestEnterActivity(requestenter[i]);
        }
    }
}

WindowId WindowManager::activeWindow()
{
    if (!m_windowManagement) return WindowId::nil();
    auto wid = m_windowManagement->activeWindow();
    return wid ? wid->uuid() : WindowId::nil();
}

void WindowManager::skipTaskBar(const QDialog &dialog)
{
    // FIXME: Wayland skipTaskbar needs proper implementation
}

void WindowManager::slideWindow(QWindow &view, WindowManager::Slide location)
{
    auto slideLocation = KWindowEffects::NoEdge;
    switch (location) {
    case Slide::Top: slideLocation = KWindowEffects::TopEdge; break;
    case Slide::Bottom: slideLocation = KWindowEffects::BottomEdge; break;
    case Slide::Left: slideLocation = KWindowEffects::LeftEdge; break;
    case Slide::Right: slideLocation = KWindowEffects::RightEdge; break;
    default: break;
    }
    KWindowEffects::slideWindow(&view, slideLocation, -1);
}

void WindowManager::enableBlurBehind(QWindow &view)
{
    KWindowEffects::enableBlurBehind(&view);
}

void WindowManager::setActiveEdge(QWindow *view, bool active)
{
    // No-op for now
}

void WindowManager::setFrameExtents(QWindow *view, const QMargins &extents)
{
}

void WindowManager::setInputMask(QWindow *window, const QRect &rect)
{
}

WindowInfoWrap WindowManager::requestInfoActive()
{
    if (!m_windowManagement) return {};
    auto w = m_windowManagement->activeWindow();
    if (!w) return {};
    return requestInfo(w->uuid());
}

WindowInfoWrap WindowManager::requestInfo(WindowId wid)
{
    WindowInfoWrap winfoWrap;
    auto w = windowFor(wid);
    bool plasmaBlockedWindow = w && (w->appId() == QLatin1String("org.kde.plasmashell")) && !isAcceptableWindow(w);

    if (w) {
        winfoWrap.setIsValid(isValidWindow(w) && !plasmaBlockedWindow);
        winfoWrap.setWid(wid);
        winfoWrap.setParentId(w->parentWindow() ? w->parentWindow()->uuid() : WindowId::nil());
        winfoWrap.setIsActive(w->isActive());
        winfoWrap.setIsMinimized(w->isMinimized());
        winfoWrap.setIsMaxVert(w->isMaximized());
        winfoWrap.setIsMaxHoriz(w->isMaximized());
        winfoWrap.setIsFullscreen(w->isFullscreen());
        winfoWrap.setIsShaded(w->isShaded());
        winfoWrap.setIsOnAllDesktops(w->isOnAllDesktops());
        winfoWrap.setIsOnAllActivities(w->plasmaActivities().isEmpty());
        winfoWrap.setIsKeepAbove(w->isKeepAbove());
        winfoWrap.setIsKeepBelow(w->isKeepBelow());
        winfoWrap.setGeometry(w->geometry());
        winfoWrap.setHasSkipSwitcher(w->skipSwitcher());
        winfoWrap.setHasSkipTaskbar(w->skipTaskbar());

        winfoWrap.setIsClosable(w->isCloseable());
        winfoWrap.setIsFullScreenable(w->isFullscreenable());
        winfoWrap.setIsMaximizable(w->isMaximizeable());
        winfoWrap.setIsMinimizable(w->isMinimizeable());
        winfoWrap.setIsMovable(w->isMovable());
        winfoWrap.setIsResizable(w->isResizable());
        winfoWrap.setIsShadeable(w->isShadeable());
        winfoWrap.setIsVirtualDesktopsChangeable(w->isVirtualDesktopChangeable());

        winfoWrap.setDisplay(w->title());
        winfoWrap.setDesktops(w->plasmaVirtualDesktops());
        winfoWrap.setActivities(w->plasmaActivities());
    } else {
        winfoWrap.setIsValid(false);
    }

    if (plasmaBlockedWindow) {
        emit windowRemoved(w->uuid());
    }

    return winfoWrap;
}

TaskManager::AppData WindowManager::appDataFor(WindowId wid)
{
    auto window = windowFor(wid);
    if (window) {
        return TaskManager::appDataFromUrl(TaskManager::windowUrlFromMetadata(window->appId(), window->pid()));
    }
    return TaskManager::AppData();
}

KWayland::Client::PlasmaWindow *WindowManager::windowFor(WindowId wid)
{
    if (!m_windowManagement) return nullptr;
    auto it = std::find_if(m_windowManagement->windows().constBegin(), m_windowManagement->windows().constEnd(), [&wid](PlasmaWindow * w) noexcept {
            return w->isValid() && w->uuid() == wid;
    });
    return (it == m_windowManagement->windows().constEnd()) ? nullptr : *it;
}

QIcon WindowManager::iconFor(WindowId wid)
{
    auto window = windowFor(wid);
    return window ? window->icon() : QIcon();
}

WindowId WindowManager::winIdFor(QString appId, QString title)
{
    if (!m_windowManagement) return WindowId();
    auto it = std::find_if(m_windowManagement->windows().constBegin(), m_windowManagement->windows().constEnd(), [&appId, &title](PlasmaWindow * w) noexcept {
        return w->isValid() && w->appId() == appId && w->title().startsWith(title);
    });
    return (it == m_windowManagement->windows().constEnd()) ? WindowId() : (*it)->uuid();
}

WindowId WindowManager::winIdFor(QString appId, QRect geometry)
{
    if (!m_windowManagement) return WindowId();
    auto it = std::find_if(m_windowManagement->windows().constBegin(), m_windowManagement->windows().constEnd(), [&appId, &geometry](PlasmaWindow * w) noexcept {
        return w->isValid() && w->appId() == appId && w->geometry() == geometry;
    });
    return (it == m_windowManagement->windows().constEnd()) ? WindowId() : (*it)->uuid();
}

bool WindowManager::windowCanBeDragged(WindowId wid)
{
    auto w = windowFor(wid);
    if (w && isValidWindow(w)) {
        WindowInfoWrap winfo = requestInfo(wid);
        return (winfo.isValid() && w->isMovable() && !winfo.isMinimized() && inCurrentDesktopActivity(winfo));
    }
    return false;
}

bool WindowManager::windowCanBeMaximized(WindowId wid)
{
    auto w = windowFor(wid);
    if (w && isValidWindow(w)) {
        WindowInfoWrap winfo = requestInfo(wid);
        return (winfo.isValid() && w->isMaximizeable() && !winfo.isMinimized() && inCurrentDesktopActivity(winfo));
    }
    return false;
}

void WindowManager::requestActivate(WindowId wid)
{
    auto w = windowFor(wid);
    if (w) w->requestActivate();
}

void WindowManager::requestClose(WindowId wid)
{
    auto w = windowFor(wid);
    if (w) w->requestClose();
}

void WindowManager::requestMoveWindow(WindowId wid, QPoint from)
{
    WindowInfoWrap wInfo = requestInfo(wid);
    if (windowCanBeDragged(wid) && inCurrentDesktopActivity(wInfo)) {
        auto w = windowFor(wid);
        if (w && isValidWindow(w)) w->requestMove();
    }
}

void WindowManager::requestToggleIsOnAllDesktops(WindowId wid)
{
    auto w = windowFor(wid);
    if (w && isValidWindow(w) && m_virtualDesktopInfo->numberOfDesktops() > 1) {
        if (w->isOnAllDesktops()) {
            w->requestEnterVirtualDesktop(m_currentDesktop);
        } else {
            const QStringList &now = w->plasmaVirtualDesktops();
            foreach (const QString &desktop, now) w->requestLeaveVirtualDesktop(desktop);
        }
    }
}

void WindowManager::requestToggleKeepAbove(WindowId wid)
{
    auto w = windowFor(wid);
    if (w) w->requestToggleKeepAbove();
}

void WindowManager::setKeepAbove(WindowId wid, bool active)
{
    auto w = windowFor(wid);
    if (w) {
        if (active) setKeepBelow(wid, false);
        if ((w->isKeepAbove() && active) || (!w->isKeepAbove() && !active)) return;
        w->requestToggleKeepAbove();
    }
}

void WindowManager::setKeepBelow(WindowId wid, bool active)
{
    auto w = windowFor(wid);
    if (w) {
        if (active) setKeepAbove(wid, false);
        if ((w->isKeepBelow() && active) || (!w->isKeepBelow() && !active)) return;
        w->requestToggleKeepBelow();
    }
}

void WindowManager::requestToggleMinimized(WindowId wid)
{
    auto w = windowFor(wid);
    WindowInfoWrap wInfo = requestInfo(wid);
    if (w && isValidWindow(w) && inCurrentDesktopActivity(wInfo)) {
        if (!m_currentDesktop.isEmpty()) w->requestEnterVirtualDesktop(m_currentDesktop);
        w->requestToggleMinimized();
    }
}

void WindowManager::requestToggleMaximized(WindowId wid)
{
    auto w = windowFor(wid);
    WindowInfoWrap wInfo = requestInfo(wid);
    if (w && isValidWindow(w) && windowCanBeMaximized(wid) && inCurrentDesktopActivity(wInfo)) {
        if (!m_currentDesktop.isEmpty()) w->requestEnterVirtualDesktop(m_currentDesktop);
        w->requestToggleMaximized();
    }
}

bool WindowManager::isPlasmaPanel(const KWayland::Client::PlasmaWindow *w) const
{
    return (w && (w->appId() == QLatin1String("org.kde.plasmashell"))) && isPlasmaPanel(w->geometry());
}

bool WindowManager::isFullScreenWindow(const KWayland::Client::PlasmaWindow *w) const
{
    return w && (w->isFullscreen() || isFullScreenWindow(w->geometry()));
}

bool WindowManager::isSidepanel(const KWayland::Client::PlasmaWindow *w) const
{
    return w && isSidepanel(w->geometry());
}

bool WindowManager::isValidWindow(const KWayland::Client::PlasmaWindow *w)
{
    if (!w || !w->isValid()) return false;
    if (windowsTracker()->isValidFor(w->uuid())) return true;
    return isAcceptableWindow(w);
}

bool WindowManager::isAcceptableWindow(const KWayland::Client::PlasmaWindow *w)
{
    if (!w || !w->isValid()) return false;
    if (hasBlockedTracking(w->uuid())) return false;
    if (isWhitelistedWindow(w->uuid())) return true;

    bool hasSkipTaskbar = w->skipTaskbar();
    bool isSkipped = hasSkipTaskbar;
    bool hasSkipSwitcher = w->skipSwitcher();
    isSkipped = hasSkipTaskbar && hasSkipSwitcher;

    if (isSkipped && (w->appId() == QLatin1String("yakuake") || w->appId() == QLatin1String("krunner"))) {
        registerWhitelistedWindow(w->uuid());
    } else if (w->appId() == QLatin1String("org.kde.plasmashell")) {
        if (isSkipped && isSidepanel(w)) {
            registerWhitelistedWindow(w->uuid());
            return true;
        } else if (isPlasmaPanel(w) || isFullScreenWindow(w)) {
            registerPlasmaIgnoredWindow(w->uuid());
            return false;
        }
    } else if (w->appId() == QLatin1String("mocha-dock") || w->appId().startsWith(QLatin1String("ksmserver"))) {
        if (isFullScreenWindow(w)) {
            registerIgnoredWindow(w->uuid());
            return false;
        }
    }
    return !isSkipped;
}

void WindowManager::updateWindow()
{
    PlasmaWindow *pW = qobject_cast<PlasmaWindow*>(QObject::sender());
    if (isValidWindow(pW)) considerWindowChanged(pW->uuid());
}

void WindowManager::windowUnmapped()
{
    PlasmaWindow *pW = qobject_cast<PlasmaWindow*>(QObject::sender());
    if (pW) {
        untrackWindow(pW);
        emit windowRemoved(pW->uuid());
    }
}

void WindowManager::trackWindow(KWayland::Client::PlasmaWindow *w)
{
    if (!w) return;
    connect(w, &PlasmaWindow::activeChanged, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::titleChanged, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::fullscreenChanged, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::geometryChanged, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::maximizedChanged, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::minimizedChanged, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::shadedChanged, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::skipTaskbarChanged, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::onAllDesktopsChanged, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::parentWindowChanged, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::plasmaVirtualDesktopEntered, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::plasmaVirtualDesktopLeft, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::plasmaActivityEntered, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::plasmaActivityLeft, this, &WindowManager::updateWindow);
    connect(w, &PlasmaWindow::unmapped, this, &WindowManager::windowUnmapped);
}

void WindowManager::untrackWindow(KWayland::Client::PlasmaWindow *w)
{
    if (!w) return;
    disconnect(w, &PlasmaWindow::activeChanged, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::titleChanged, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::fullscreenChanged, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::geometryChanged, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::maximizedChanged, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::minimizedChanged, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::shadedChanged, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::skipTaskbarChanged, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::onAllDesktopsChanged, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::parentWindowChanged, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::plasmaVirtualDesktopEntered, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::plasmaVirtualDesktopLeft, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::plasmaActivityEntered, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::plasmaActivityLeft, this, &WindowManager::updateWindow);
    disconnect(w, &PlasmaWindow::unmapped, this, &WindowManager::windowUnmapped);
}

void WindowManager::windowCreatedProxy(KWayland::Client::PlasmaWindow *w)
{
    if (!isAcceptableWindow(w)) return;
    trackWindow(w);
    emit windowAdded(w->uuid());
    if (w->appId() == QLatin1String("mocha-dock")) emit mochaWindowAdded();
}

}
}

#include "moc_windowmanager.cpp"
