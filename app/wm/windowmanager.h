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

/**
 * @class WindowManager
 * @brief Handles window management tasks and tracking for Mocha Dock.
 * 
 * This class is responsible for interacting with the windowing system (Wayland)
 * to manage window states, positions, and tracking. It abstracts the underlying
 * KWayland and PlasmaWindowManagement interfaces.
 */
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

    /**
     * @brief Sets extra flags for a view window.
     * @param view The window to set flags for.
     * @param isPanelWindow Whether the window should be treated as a panel.
     * @param mode The visibility mode for the window.
     */
    void setViewExtraFlags(QWindow *view, bool isPanelWindow = true, Mocha::Types::Visibility mode = Mocha::Types::WindowsGoBelow);

    /**
     * @brief Sets struts for a view window to reserve space on the screen.
     * @param view The window to set struts for.
     * @param rect The geometry of the reserved area.
     * @param location The edge of the screen where space is reserved.
     */
    void setViewStruts(QWindow *view, const QRect &rect, Plasma::Types::Location location);

    /**
     * @brief Associates a window with specific activities.
     * @param wid The window ID.
     * @param activities List of activity IDs.
     */
    void setWindowOnActivities(const WindowId &wid, const QStringList &activities);

    /**
     * @brief Sets the position of a window on the screen.
     * @param window The window to position.
     * @param location The screen edge.
     * @param geometry The target geometry.
     */
    void setWindowPosition(QWindow *window, const Plasma::Types::Location &location, const QRect &geometry);

    /**
     * @brief Removes struts associated with a view window.
     * @param view The window to remove struts from.
     */
    void removeViewStruts(QWindow *view);

    /**
     * @brief Returns the currently active window ID.
     */
    WindowId activeWindow();

    /**
     * @brief Requests information for a specific window.
     * @param wid The window ID.
     * @return A wrapper containing window information.
     */
    WindowInfoWrap requestInfo(WindowId wid);

    /**
     * @brief Requests information for the currently active window.
     * @return A wrapper containing window information.
     */
    WindowInfoWrap requestInfoActive();

    /**
     * @brief Configures a dialog to be skipped by taskbars.
     * @param dialog The dialog to configure.
     */
    void skipTaskBar(const QDialog &dialog);

    /**
     * @brief Animates a window sliding from a specific location.
     * @param view The window to slide.
     * @param location The starting location of the slide.
     */
    void slideWindow(QWindow &view, Slide location);

    /**
     * @brief Enables blur-behind effect for a window.
     * @param view The window to enable blur for.
     */
    void enableBlurBehind(QWindow &view);

    /**
     * @brief Sets whether a window edge is active.
     * @param view The window.
     * @param active True to activate, false to deactivate.
     */
    void setActiveEdge(QWindow *view, bool active);

    /** @name Window Actions
     *  Methods to request changes to window states.
     * @{
     */
    void requestActivate(WindowId wid);
    void requestClose(WindowId wid);
    void requestMoveWindow(WindowId wid, QPoint from);
    void requestToggleIsOnAllDesktops(WindowId wid);
    void requestToggleKeepAbove(WindowId wid);
    void requestToggleMinimized(WindowId wid);
    void requestToggleMaximized(WindowId wid);
    void setKeepAbove(WindowId wid, bool active);
    void setKeepBelow(WindowId wid, bool active);
    /** @} */

    /**
     * @brief Checks if a window can be dragged.
     */
    bool windowCanBeDragged(WindowId wid);

    /**
     * @brief Checks if a window can be maximized.
     */
    bool windowCanBeMaximized(WindowId wid);

    /**
     * @brief Returns the icon for a specific window.
     */
    QIcon iconFor(WindowId wid);

    /**
     * @brief Finds a window ID based on app ID and geometry.
     */
    WindowId winIdFor(QString appId, QRect geometry);

    /**
     * @brief Finds a window ID based on app ID and title.
     */
    WindowId winIdFor(QString appId, QString title);

    /**
     * @brief Returns application data for a specific window.
     */
    TaskManager::AppData appDataFor(WindowId wid);

    /**
     * @brief Checks if KWin is the current window manager.
     */
    bool isKWinRunning() const;

    /**
     * @brief Checks if a window is in the current desktop and activity.
     */
    bool inCurrentDesktopActivity(const WindowInfoWrap &winfo);

    /**
     * @brief Checks if the desktop is currently being shown.
     */
    bool isShowingDesktop() const;

    /**
     * @brief Checks if tracking is blocked for a specific window.
     */
    bool hasBlockedTracking(const WindowId &wid) const;

    /**
     * @brief Returns the name of the current virtual desktop.
     */
    QString currentDesktop();

    /**
     * @brief Returns the ID of the current activity.
     */
    QString currentActivity();

    /** @name Window Registration
     *  Methods to register windows for special handling (ignored, whitelisted).
     * @{
     */
    void registerIgnoredWindow(WindowId wid);
    void unregisterIgnoredWindow(WindowId wid);

    void registerPlasmaIgnoredWindow(WindowId wid);
    void unregisterPlasmaIgnoredWindow(WindowId wid);

    void registerWhitelistedWindow(WindowId wid);
    void unregisterWhitelistedWindow(WindowId wid);
    /** @} */

    /** @name Desktop/Activity Navigation
     *  Methods to switch between activities and virtual desktops.
     * @{
     */
    void switchToNextActivity();
    void switchToPreviousActivity();

    void switchToNextVirtualDesktop();
    void switchToPreviousVirtualDesktop();
    /** @} */

    /**
     * @brief Sets frame extents for a window (CSD/Shadows).
     */
    void setFrameExtents(QWindow *view, const QMargins &margins);

    /**
     * @brief Sets an input mask for a window.
     */
    void setInputMask(QWindow *window, const QRect &rect);

    /**
     * @brief Returns the Corona instance.
     */
    Mocha::Corona *corona();

    /**
     * @brief Returns the schemes tracker.
     */
    Tracker::Schemes *schemesTracker();

    /**
     * @brief Returns the windows tracker.
     */
    Tracker::Windows *windowsTracker() const;

    /**
     * @brief Initializes window management with KWayland.
     * @param windowManagement The Wayland window management interface.
     */
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
