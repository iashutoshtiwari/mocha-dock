/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef WINDOWSALLSCREENSTRACKER_H
#define WINDOWSALLSCREENSTRACKER_H

// local
#include "../../wm/abstractwindowinterface.h"
#include "../../wm/tracker/lastactivewindow.h"

// Qt
#include <QObject>

namespace Mocha{
class View;

namespace ViewPart {
class WindowsTracker;
}

namespace WindowSystem {
class AbstractWindowInterface;
class SchemeColors;
}
}

namespace Mocha {
namespace ViewPart {
namespace TrackerPart {

class AllScreensTracker : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool activeWindowMaximized READ activeWindowMaximized NOTIFY activeWindowMaximizedChanged)
    Q_PROPERTY(bool existsWindowActive READ existsWindowActive NOTIFY existsWindowActiveChanged)
    Q_PROPERTY(bool existsWindowMaximized READ existsWindowMaximized NOTIFY existsWindowMaximizedChanged)
    Q_PROPERTY(Mocha::WindowSystem::SchemeColors *activeWindowScheme READ activeWindowScheme NOTIFY activeWindowSchemeChanged)

    Q_PROPERTY(Mocha::WindowSystem::Tracker::LastActiveWindow *lastActiveWindow READ lastActiveWindow NOTIFY lastActiveWindowChanged)

public:
    explicit AllScreensTracker(WindowsTracker *parent);
    virtual ~AllScreensTracker();

    bool activeWindowMaximized() const;
    bool existsWindowActive() const;
    bool existsWindowMaximized() const;

    WindowSystem::SchemeColors *activeWindowScheme() const;

    WindowSystem::Tracker::LastActiveWindow *lastActiveWindow();

public slots:
    Q_INVOKABLE void requestMoveLastWindow(int localX, int localY);

signals:
    void activeWindowMaximizedChanged();
    void existsWindowActiveChanged();
    void existsWindowMaximizedChanged();
    void activeWindowSchemeChanged();

    void lastActiveWindowChanged();

private slots:
    void initSignalsForInformation();

private:
    void init();

private:
    Mocha::WindowSystem::Tracker::LastActiveWindow *m_currentLastActiveWindow{nullptr};

    Mocha::View *m_mochaView{nullptr};
    WindowSystem::AbstractWindowInterface *m_wm{nullptr};
};

}
}
}

#endif
