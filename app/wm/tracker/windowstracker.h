/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef WINDOWSYSTEMWINDOWSTRACKER_H
#define WINDOWSYSTEMWINDOWSTRACKER_H

// local
#include <coretypes.h>
#include "../windowinfowrap.h"

// Qt
#include <QObject>

#include <QHash>
#include <QMap>
#include <QTimer>


namespace Mocha {
class View;
namespace Layout {
class GenericLayout;
}
namespace WindowSystem {
class WindowManager;
class SchemeColors;
namespace Tracker {
class LastActiveWindow;
class TrackedLayoutInfo;
class TrackedViewInfo;
}
}
}

namespace Mocha {
namespace WindowSystem {
namespace Tracker {

class Windows : public QObject {
    Q_OBJECT

public:
    Windows(WindowManager *parent);
    ~Windows() override;

    void addView(Mocha::View *view);
    void removeView(Mocha::View *view);

    //! Views Tracking (current screen specific)
    bool enabled(Mocha::View *view);
    void setEnabled(Mocha::View *view, const bool enabled);

    bool activeWindowMaximized(Mocha::View *view) const;
    bool activeWindowTouching(Mocha::View *view) const;
    bool activeWindowTouchingEdge(Mocha::View *view) const;
    bool existsWindowActive(Mocha::View *view) const;
    bool existsWindowMaximized(Mocha::View *view) const;
    bool existsWindowTouching(Mocha::View *view) const;
    bool existsWindowTouchingEdge(Mocha::View *view) const;
    bool isTouchingBusyVerticalView(Mocha::View *view) const;
    SchemeColors *activeWindowScheme(Mocha::View *view) const;
    SchemeColors *touchingWindowScheme(Mocha::View *view) const;
    LastActiveWindow *lastActiveWindow(Mocha::View *view);

    //! Layouts Tracking (all screens)
    bool enabled(Mocha::Layout::GenericLayout *layout);
    bool activeWindowMaximized(Mocha::Layout::GenericLayout *layout) const;
    bool existsWindowActive(Mocha::Layout::GenericLayout *layout) const;
    bool existsWindowMaximized(Mocha::Layout::GenericLayout *layout) const;
    SchemeColors *activeWindowScheme(Mocha::Layout::GenericLayout *layout) const;
    LastActiveWindow *lastActiveWindow(Mocha::Layout::GenericLayout *layout);

    //! Windows management
    bool isValidFor(const WindowId &wid) const;
    QIcon iconFor(const WindowId &wid);
    QString appNameFor(const WindowId &wid);
    WindowInfoWrap infoFor(const WindowId &wid) const;

    WindowManager *wm();

signals:
    //! Views
    void enabledChanged(const Mocha::View *view);
    void activeWindowMaximizedChanged(const Mocha::View *view);
    void activeWindowTouchingChanged(const Mocha::View *view);
    void activeWindowTouchingEdgeChanged(const Mocha::View *view);
    void existsWindowActiveChanged(const Mocha::View *view);
    void existsWindowMaximizedChanged(const Mocha::View *view);
    void existsWindowTouchingChanged(const Mocha::View *view);
    void existsWindowTouchingEdgeChanged(const Mocha::View *view);
    void isTouchingBusyVerticalViewChanged(const Mocha::View *view);
    void activeWindowSchemeChanged(const Mocha::View *view);
    void touchingWindowSchemeChanged(const Mocha::View *view);
    void informationAnnounced(const Mocha::View *view);

    //! Layouts
    void enabledChangedForLayout(const Mocha::Layout::GenericLayout *layout);
    void activeWindowMaximizedChangedForLayout(const Mocha::Layout::GenericLayout *layout);
    void existsWindowActiveChangedForLayout(const Mocha::Layout::GenericLayout *layout);
    void existsWindowMaximizedChangedForLayout(const Mocha::Layout::GenericLayout *layout);
    void activeWindowSchemeChangedForLayout(const Mocha::Layout::GenericLayout *layout);
    void informationAnnouncedForLayout(const Mocha::Layout::GenericLayout *layout);

    //! overloading WM signals in order to update first m_windows and afterwards
    //! inform consumers for window changes
    void activeWindowChanged(const WindowId &wid);
    void windowChanged(const WindowId &wid);
    void windowRemoved(const WindowId &wid);

    void applicationDataChanged(const WindowId &wid);

private slots:
    void updateScreenGeometries();

    void addRelevantLayout(Mocha::View *view);

    void updateApplicationData();
    void updateRelevantLayouts();
    void updateExtraViewHints();

private:
    void init();
    void initLayoutHints(Mocha::Layout::GenericLayout *layout);
    void initViewHints(Mocha::View *view);
    void cleanupFaultyWindows();

    void updateAllHints();
    void updateAllHintsAfterTimer();

    //! Views
    void updateHints(Mocha::View *view);
    void updateHints(Mocha::Layout::GenericLayout *layout);

    void setActiveWindowMaximized(Mocha::View *view, bool activeMaximized);
    void setActiveWindowTouching(Mocha::View *view, bool activeTouching);
    void setActiveWindowTouchingEdge(Mocha::View *view, bool activeTouchingEdge);
    void setExistsWindowActive(Mocha::View *view, bool windowActive);
    void setExistsWindowMaximized(Mocha::View *view, bool windowMaximized);
    void setExistsWindowTouching(Mocha::View *view, bool windowTouching);
    void setExistsWindowTouchingEdge(Mocha::View *view, bool windowTouchingEdge);
    void setIsTouchingBusyVerticalView(Mocha::View *view, bool viewTouching);
    void setActiveWindowScheme(Mocha::View *view, WindowSystem::SchemeColors *scheme);
    void setTouchingWindowScheme(Mocha::View *view, WindowSystem::SchemeColors *scheme);

    //! Layouts
    void setActiveWindowMaximized(Mocha::Layout::GenericLayout *layout, bool activeMaximized);
    void setExistsWindowActive(Mocha::Layout::GenericLayout *layout, bool windowActive);
    void setExistsWindowMaximized(Mocha::Layout::GenericLayout *layout, bool windowMaximized);
    void setActiveWindowScheme(Mocha::Layout::GenericLayout *layout, WindowSystem::SchemeColors *scheme);

    //! Windows
    bool intersects(Mocha::View *view, const WindowInfoWrap &winfo);
    bool isActive(const WindowInfoWrap &winfo);
    bool isActiveInViewScreen(Mocha::View *view, const WindowInfoWrap &winfo);
    bool isMaximizedInViewScreen(Mocha::View *view, const WindowInfoWrap &winfo);
    bool isTouchingView(Mocha::View *view, const WindowSystem::WindowInfoWrap &winfo);
    bool isTouchingViewEdge(Mocha::View *view, const WindowInfoWrap &winfo);
    bool isTouchingViewEdge(Mocha::View *view, const QRect &windowgeometry);

private:
    //! a timer in order to not overload the views extra hints checking because it is not
    //! really needed that often
    QTimer m_extraViewHintsTimer;

    WindowManager *m_wm;
    QHash<Mocha::View *, TrackedViewInfo *> m_views;
    QHash<Mocha::Layout::GenericLayout *, TrackedLayoutInfo *> m_layouts;

    //! Accept only ALWAYSVISIBLE visibility mode
    QList<Mocha::Types::Visibility> m_ignoreModes{
        Mocha::Types::AutoHide,
        Mocha::Types::DodgeActive,
        Mocha::Types::DodgeMaximized,
        Mocha::Types::DodgeAllWindows,
        Mocha::Types::WindowsGoBelow,
        Mocha::Types::WindowsCanCover,
        Mocha::Types::WindowsAlwaysCover,
        Mocha::Types::SidebarOnDemand,
        Mocha::Types::SidebarAutoHide
    };

    QHash<WindowId, WindowInfoWrap> m_windows;

    QTimer m_updateAllHintsTimer;
    //! Some applications delay their application name/icon identification
    //! such as Libreoffice that updates its StartupWMClass after
    //! its startup
    QTimer m_updateApplicationDataTimer;
    QList<WindowId> m_delayedApplicationData;
    QList<WindowId> m_initializedApplicationData;
};

}
}
}

#endif
