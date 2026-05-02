/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "allscreenstracker.h"

// local
#include "../view.h"
#include "../../layout/genericlayout.h"
#include "../../wm/schemecolors.h"
#include "../../wm/tracker/lastactivewindow.h"
#include "../../wm/tracker/windowstracker.h"

namespace Mocha {
namespace ViewPart {
namespace TrackerPart {

AllScreensTracker::AllScreensTracker(WindowsTracker *parent)
    : QObject(parent),
      m_mochaView(parent->view()),
      m_wm(parent->wm())
{
    init();
}

AllScreensTracker::~AllScreensTracker()
{
}

void  AllScreensTracker::init()
{
    if (!m_currentLastActiveWindow && lastActiveWindow()) {
        initSignalsForInformation();
    }

    connect(m_mochaView, &Mocha::View::layoutChanged, this, [&]() {
        if (m_mochaView->layout()) {
            initSignalsForInformation();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::informationAnnouncedForLayout, this, [&](const Mocha::Layout::GenericLayout *layout) {
        if (m_mochaView->layout() == layout) {
            initSignalsForInformation();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::activeWindowMaximizedChangedForLayout, this, [&](const Mocha::Layout::GenericLayout *layout) {
        if (m_mochaView->layout() == layout) {
            emit activeWindowMaximizedChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::existsWindowActiveChangedForLayout, this, [&](const Mocha::Layout::GenericLayout *layout) {
        if (m_mochaView->layout() == layout) {
            emit existsWindowActiveChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::existsWindowMaximizedChangedForLayout, this, [&](const Mocha::Layout::GenericLayout *layout) {
        if (m_mochaView->layout() == layout) {
            emit existsWindowMaximizedChanged();
        }
    });

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::activeWindowSchemeChangedForLayout, this, [&](const Mocha::Layout::GenericLayout *layout) {
        if (m_mochaView->layout() == layout) {
            emit activeWindowSchemeChanged();
        }
    });
}

void AllScreensTracker::initSignalsForInformation()
{
    m_currentLastActiveWindow = lastActiveWindow();

    emit lastActiveWindowChanged();
    emit activeWindowMaximizedChanged();
    emit existsWindowActiveChanged();
    emit existsWindowMaximizedChanged();
    emit activeWindowSchemeChanged();
}

bool AllScreensTracker::activeWindowMaximized() const
{
    return m_wm->windowsTracker()->activeWindowMaximized(m_mochaView->layout());
}

bool AllScreensTracker::existsWindowActive() const
{
    return m_wm->windowsTracker()->existsWindowActive(m_mochaView->layout());
}

bool AllScreensTracker::existsWindowMaximized() const
{
    return m_wm->windowsTracker()->existsWindowMaximized(m_mochaView->layout());
}

WindowSystem::SchemeColors *AllScreensTracker::activeWindowScheme() const
{
    return m_wm->windowsTracker()->activeWindowScheme(m_mochaView->layout());
}

WindowSystem::Tracker::LastActiveWindow *AllScreensTracker::lastActiveWindow()
{
    return m_wm->windowsTracker()->lastActiveWindow(m_mochaView->layout());
}


//! Window Functions
void AllScreensTracker::requestMoveLastWindow(int localX, int localY)
{
    m_wm->windowsTracker()->lastActiveWindow(m_mochaView->layout())->requestMove(m_mochaView, localX, localY);
}

}
}
}
