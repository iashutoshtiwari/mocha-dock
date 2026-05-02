/*
    SPDX-FileCopyrightText: 2016-2024 Smith AR <audoban@openmailbox.org>
    SPDX-FileCopyrightText: 2016-2024 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-FileCopyrightText: 2026 Ashutosh Tiwari <contact@ashutoshtiwari.dev>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef WINDOWMANAGER_H
#define WINDOWMANAGER_H

// local
#include <config-mocha.h>
#include <coretypes.h>
#include "schemecolors.h"
#include <taskmanager/tasktools.h>
#include "windowinfowrap.h"
#include "tracker/windowstracker.h"

// C++
#include <unordered_map>
#include <list>

// Qt
#include <QObject>
#include <QWindow>
#include <QDBusServiceWatcher>
#include <QDialog>
#include <QMap>
#include <QRect>
#include <QPoint>
#include <QPointer>
#include <QScreen>
#include <QTimer>
#include <QHash>
#include <QIcon>

// KDE
#include <KWayland/Client/registry.h>
#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWindowInfo>
#include <KWindowEffects>
#include <taskmanager/virtualdesktopinfo.h>
#include <PlasmaActivities/Consumer>

// Plasma
#include <Plasma/Plasma>


namespace Mocha {
class Corona;
namespace WindowSystem {
namespace Tracker {
class Schemes;
class Windows;
}
}
}

namespace Mocha {
namespace WindowSystem {

class WindowManager : public QObject
{
    Q_OBJECT

public:
    enum class Slide
    {
        None,
        Top,
        Left,
        Bottom,
        Right,
    };

    explicit WindowManager(QObject *parent = nullptr);
    ~WindowManager() override;

    void setViewExtraFlags(QWindow *view, bool isPanelWindow = true, Mocha::Types::Visibility mode = Mocha::Types::WindowsGoBelow);
    void setViewStruts(QWindow *view, const QRect &rect, Plasma::Types::Location location);
    void setWindowOnActivities(const WindowId &wid, const QStringList &activities);

    void setWindowPosition(QWindow *window, const Plasma::Types::Location &location, const QRect &geometry);
    void removeViewStruts(QWindow *view);

    WindowId activeWindow();
    WindowInfoWrap requestInfo(WindowId wid);
    WindowInfoWrap requestInfoActive();

    void skipTaskBar(const QDialog &dialog);
    void slideWindow(QWindow &view, Slide location);
    void enableBlurBehind(QWindow &view);
    void setActiveEdge(QWindow *view, bool active);

    void requestActivate(WindowId wid);
    void requestClose(WindowId wid);
    void requestMoveWindow(WindowId wid, QPoint from);
    void requestToggleIsOnAllDesktops(WindowId wid);
    void requestToggleKeepAbove(WindowId wid);
    void requestToggleMinimized(WindowId wid);
    void requestToggleMaximized(WindowId wid);
    void setKeepAbove(WindowId wid, bool active);
    void setKeepBelow(WindowId wid, bool active);

    bool windowCanBeDragged(WindowId wid);
    bool windowCanBeMaximized(WindowId wid);

    QIcon iconFor(WindowId wid);
    WindowId winIdFor(QString appId, QRect geometry);
    WindowId winIdFor(QString appId, QString title);
    TaskManager::AppData appDataFor(WindowId wid);

    bool isKWinRunning() const;
    bool inCurrentDesktopActivity(const WindowInfoWrap &winfo);
    bool isShowingDesktop() const;
    bool hasBlockedTracking(const WindowId &wid) const;

    QString currentDesktop();
    QString currentActivity();

    void registerIgnoredWindow(WindowId wid);
    void unregisterIgnoredWindow(WindowId wid);

    void registerPlasmaIgnoredWindow(WindowId wid);
    void unregisterPlasmaIgnoredWindow(WindowId wid);

    void registerWhitelistedWindow(WindowId wid);
    void unregisterWhitelistedWindow(WindowId wid);

    void switchToNextActivity();
    void switchToPreviousActivity();

    void switchToNextVirtualDesktop();
    void switchToPreviousVirtualDesktop();

    void setFrameExtents(QWindow *view, const QMargins &margins);
    void setInputMask(QWindow *window, const QRect &rect);

    Mocha::Corona *corona();
    Tracker::Schemes *schemesTracker();
    Tracker::Windows *windowsTracker() const;

    void initWindowManagement(KWayland::Client::PlasmaWindowManagement *windowManagement);

signals:
    void activeWindowChanged(WindowId wid);
    void windowChanged(WindowId winfo);
    void windowAdded(WindowId wid);
    void windowRemoved(WindowId wid);
    void currentDesktopChanged();
    void currentActivityChanged();
    void isShowingDesktopChanged();
    void mochaWindowAdded();

protected:
    QString m_currentDesktop;
    QString m_currentActivity;

    //! windows that must be ignored from tracking, a good example are Mocha::Views and
    //! their Configuration windows
    QList<WindowId> m_ignoredWindows;
    //! identified plasma panels
    QList<WindowId> m_plasmaIgnoredWindows;
    //! identified whitelisted windows that can be tracked e.g. plasma widgets explorer and activities
    QList<WindowId> m_whitelistedWindows;

    QPointer<KActivities::Consumer> m_activities;

    //! Sending too fast plenty of signals for the same window
    //! has no reason and can create HIGH CPU usage. This Timer
    //! can delay the batch sending of signals for the same window
    WindowId m_windowChangedWaiting;
    QTimer m_windowWaitingTimer;

    void considerWindowChanged(WindowId wid);

    bool isIgnored(const WindowId &wid) const;
    bool isRegisteredPlasmaIgnoredWindow(const WindowId &wid) const;
    bool isWhitelistedWindow(const WindowId &wid) const;

    bool isFullScreenWindow(const QRect &wGeometry) const;
    bool isPlasmaPanel(const QRect &wGeometry) const;
    bool isSidepanel(const QRect &wGeometry) const;

private slots:
    void windowRemovedSlot(WindowId wid);
    void setIsShowingDesktop(const bool &showing);

    void updateWindow();
    void windowUnmapped();

private:
    void trackWindow(KWayland::Client::PlasmaWindow *w);
    void untrackWindow(KWayland::Client::PlasmaWindow *w);
    void windowCreatedProxy(KWayland::Client::PlasmaWindow *w);
    KWayland::Client::PlasmaWindow *windowFor(WindowId wid);

    bool isAcceptableWindow(const KWayland::Client::PlasmaWindow *w);
    bool isValidWindow(const KWayland::Client::PlasmaWindow *w);
    bool isFullScreenWindow(const KWayland::Client::PlasmaWindow *w) const;
    bool isPlasmaPanel(const KWayland::Client::PlasmaWindow *w) const;
    bool isSidepanel(const KWayland::Client::PlasmaWindow *w) const;

    void setCurrentDesktop(QString desktop);

private:
    bool m_isShowingDesktop{false};

    Mocha::Corona *m_corona{nullptr};
    Tracker::Schemes *m_schemesTracker{nullptr};
    Tracker::Windows *m_windowsTracker{nullptr};

    KWayland::Client::PlasmaWindowManagement *m_windowManagement{nullptr};
    TaskManager::VirtualDesktopInfo *m_virtualDesktopInfo{nullptr};
};

}
}

#endif // WINDOWMANAGER_H
