/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "windowstracker.h"

// local
#include "currentscreentracker.h"
#include "allscreenstracker.h"
#include "../positioner.h"
#include "../view.h"
#include "../../mochacorona.h"
#include "../../wm/tracker/windowstracker.h"


namespace Mocha {
namespace ViewPart {

WindowsTracker::WindowsTracker(Mocha::View *parent)
    : QObject(parent),
      m_mochaView(parent)
{
    qDebug() << "WindowsTracker creating...";

    auto corona = qobject_cast<Mocha::Corona *>(m_mochaView->corona());
    m_wm = corona->wm();

    m_allScreensTracker = new TrackerPart::AllScreensTracker(this);
    m_currentScreenTracker = new TrackerPart::CurrentScreenTracker(this);

    connect(m_wm->windowsTracker(), &WindowSystem::Tracker::Windows::enabledChanged, this, [&](const Mocha::View *view) {
        if (m_mochaView == view) {
            emit enabledChanged();
        }
    });

    m_wm->windowsTracker()->addView(m_mochaView);
    emit allScreensChanged();
    emit currentScreenChanged();
}

WindowsTracker::~WindowsTracker()
{
    qDebug() << "WindowsTracker removing...";

    if (m_allScreensTracker) {
        m_allScreensTracker->deleteLater();
    }

    if (m_currentScreenTracker) {
        m_currentScreenTracker->deleteLater();
    }
}

Mocha::View *WindowsTracker::view() const
{
    return m_mochaView;
}

WindowSystem::AbstractWindowInterface *WindowsTracker::wm() const
{
    return m_wm;
}

bool WindowsTracker::enabled() const
{
    return m_wm->windowsTracker()->enabled(m_mochaView);
}

void WindowsTracker::setEnabled(bool active)
{
    m_wm->windowsTracker()->setEnabled(m_mochaView, active);
}


TrackerPart::AllScreensTracker *WindowsTracker::allScreens() const
{
    return m_allScreensTracker;
}

TrackerPart::CurrentScreenTracker *WindowsTracker::currentScreen() const
{
    return m_currentScreenTracker;
}

//! Environment Functions
void WindowsTracker::switchToNextActivity()
{
    m_wm->switchToNextActivity();
}

void WindowsTracker::switchToPreviousActivity()
{
    m_wm->switchToPreviousActivity();
}

void WindowsTracker::switchToNextVirtualDesktop()
{
    m_wm->switchToNextVirtualDesktop();
}

void WindowsTracker::switchToPreviousVirtualDesktop()
{
    m_wm->switchToPreviousVirtualDesktop();
}

}
}
