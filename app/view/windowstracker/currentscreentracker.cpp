/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "currentscreentracker.h"

// local
#include "../view.h"
#include "../../wm/schemecolors.h"
#include "../../wm/tracker/lastactivewindow.h"
#include "../../wm/tracker/windowstracker.h"

namespace Mocha {
namespace ViewPart {
namespace TrackerPart {

CurrentScreenTracker::CurrentScreenTracker(WindowsTracker *parent)
    : QObject(parent),
      m_mochaView(parent->view()),
      m_wm(parent->wm())
{
    init();
}

CurrentScreenTracker::~CurrentScreenTracker()
{
    m_wm->windowsTracker()->removeView(m_mochaView);
}

void  CurrentScreenTracker::init()
{
    if (lastActiveWindow()) {
        initSignalsForInformation();
    }

    connect(m_mochaView, &Mocha::View::layoutChanged, this, [&]() {
        if (m_mochaView->layout()) {
            initSignalsForInformation();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::informationAnnounced, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            initSignalsForInformation();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::activeWindowMaximizedChanged, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            emit activeWindowMaximizedChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::activeWindowTouchingChanged, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            emit activeWindowTouchingChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::activeWindowTouchingEdgeChanged, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            emit activeWindowTouchingEdgeChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::existsWindowActiveChanged, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            emit existsWindowActiveChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::existsWindowMaximizedChanged, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            emit existsWindowMaximizedChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::existsWindowTouchingChanged, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            emit existsWindowTouchingChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::existsWindowTouchingEdgeChanged, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            emit existsWindowTouchingEdgeChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::isTouchingBusyVerticalViewChanged, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            emit isTouchingBusyVerticalViewChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::activeWindowSchemeChanged, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            emit activeWindowSchemeChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::touchingWindowSchemeChanged, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            emit touchingWindowSchemeChanged();
        }
    });
}

void CurrentScreenTracker::initSignalsForInformation()
{
    emit lastActiveWindowChanged();
    emit activeWindowMaximizedChanged();
    emit activeWindowTouchingChanged();
    emit activeWindowTouchingEdgeChanged();
    emit existsWindowActiveChanged();
    emit existsWindowMaximizedChanged();
    emit existsWindowTouchingChanged();
    emit existsWindowTouchingEdgeChanged();
    emit activeWindowSchemeChanged();
    emit touchingWindowSchemeChanged();
}

bool CurrentScreenTracker::activeWindowMaximized() const
{
    return m_wm->windowsTracker()->activeWindowMaximized(m_mochaView);
}

bool CurrentScreenTracker::activeWindowTouching() const
{
    return m_wm->windowsTracker()->activeWindowTouching(m_mochaView);
}

bool CurrentScreenTracker::activeWindowTouchingEdge() const
{
    return m_wm->windowsTracker()->activeWindowTouchingEdge(m_mochaView);
}

bool CurrentScreenTracker::existsWindowActive() const
{
    return m_wm->windowsTracker()->existsWindowActive(m_mochaView);
}

bool CurrentScreenTracker::existsWindowMaximized() const
{
    return m_wm->windowsTracker()->existsWindowMaximized(m_mochaView);
}

bool CurrentScreenTracker::existsWindowTouching() const
{
    return m_wm->windowsTracker()->existsWindowTouching(m_mochaView);
}

bool CurrentScreenTracker::existsWindowTouchingEdge() const
{
    return m_wm->windowsTracker()->existsWindowTouchingEdge(m_mochaView);
}

bool CurrentScreenTracker::isTouchingBusyVerticalView() const
{
    return m_wm->windowsTracker()->isTouchingBusyVerticalView(m_mochaView);
}

WindowSystem::SchemeColors *CurrentScreenTracker::activeWindowScheme() const
{
    return m_wm->windowsTracker()->activeWindowScheme(m_mochaView);
}

WindowSystem::SchemeColors *CurrentScreenTracker::touchingWindowScheme() const
{
    return m_wm->windowsTracker()->touchingWindowScheme(m_mochaView);
}

WindowSystem::Tracker::LastActiveWindow *CurrentScreenTracker::lastActiveWindow()
{
    return m_wm->windowsTracker()->lastActiveWindow(m_mochaView);
}


//! Window Functions
void CurrentScreenTracker::requestMoveLastWindow(int localX, int localY)
{
    m_wm->windowsTracker()->lastActiveWindow(m_mochaView)->requestMove(m_mochaView, localX, localY);
}

}
}
}
