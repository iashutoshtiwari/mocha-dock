/*
    SPDX-FileCopyrightText: 2018 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "screenedgeghostwindow.h"

// local
#include "../view.h"
#include "../positioner.h"

// Qt
#include <QDebug>
#include <QSurfaceFormat>
#include <QQuickView>
#include <QTimer>

// KDE
#include <KWindowSystem>

namespace Mocha {
namespace ViewPart {

ScreenEdgeGhostWindow::ScreenEdgeGhostWindow(Mocha::View *view) :
    SubWindow(view, QString("Screen Ghost Window"))
{
    if (m_debugMode) {
        m_showColor = QColor("purple");
        m_hideColor = QColor("blue");
    } else {
        m_showColor = QColor(Qt::transparent);
        m_hideColor = QColor(Qt::transparent);

        m_showColor.setAlpha(0);
        m_hideColor.setAlpha(1);
    }

    setColor(m_showColor);

    connect(m_mochaView->positioner(), &Mocha::ViewPart::Positioner::slideOffsetChanged, this, &ScreenEdgeGhostWindow::updateGeometry);

    //! this timer is used in order to avoid fast enter/exit signals during first
    //! appearing after edge activation
    m_delayedMouseTimer.setSingleShot(true);
    m_delayedMouseTimer.setInterval(50);
    connect(&m_delayedMouseTimer, &QTimer::timeout, this, [this]() {
        if (m_delayedContainsMouse) {
            setContainsMouse(true);
        } else {
            setContainsMouse(false);
        }
    });

    updateGeometry();
    hideWithMask();
}

ScreenEdgeGhostWindow::~ScreenEdgeGhostWindow()
{
}

QString ScreenEdgeGhostWindow::validTitlePrefix() const
{
    return QString("#subghostedge#");
}

void ScreenEdgeGhostWindow::updateGeometry()
{
    if (m_mochaView->positioner()->slideOffset() != 0) {
        return;
    }

    QRect newGeometry = m_mochaView->absoluteGeometry();

    m_thickness = 6;

    int length{30};
    int lengthDifference{0};

    if (m_mochaView->formFactor() == Plasma::Types::Horizontal) {
        //! set minimum length to be 25% of screen width
        length = qMax(m_mochaView->screenGeometry().width()/4,qMin(m_mochaView->absoluteGeometry().width(), m_mochaView->screenGeometry().width() - 1));
        lengthDifference = qMax(0,length - m_mochaView->absoluteGeometry().width()) / 2;
    } else {
        //! set minimum length to be 25% of screen height
        length = qMax(m_mochaView->screenGeometry().height()/4,qMin(m_mochaView->absoluteGeometry().height(), m_mochaView->screenGeometry().height() - 1));
        lengthDifference = qMax(0,length - m_mochaView->absoluteGeometry().height()) / 2;
    }

    if (m_mochaView->formFactor() == Plasma::Types::Horizontal) {
        int leftF = qMax(m_mochaView->screenGeometry().left(), m_mochaView->absoluteGeometry().left() - lengthDifference);
        int rightF = qMax(m_mochaView->screenGeometry().left(), qMin(m_mochaView->screenGeometry().right(), m_mochaView->absoluteGeometry().right() + lengthDifference));
        newGeometry.setLeft(leftF);
        newGeometry.setRight(rightF);
    } else {
        int topF = qMax(m_mochaView->screenGeometry().top(), m_mochaView->absoluteGeometry().top() - lengthDifference);
        int bottomF = qMax(m_mochaView->screenGeometry().top(), qMin(m_mochaView->screenGeometry().bottom(), m_mochaView->absoluteGeometry().bottom() + lengthDifference));
        newGeometry.setTop(topF);
        newGeometry.setBottom(bottomF);
    }

    if (m_mochaView->location() == Plasma::Types::BottomEdge) {
        newGeometry.moveTop(m_mochaView->screenGeometry().bottom() - m_thickness);
    } else if (m_mochaView->location() == Plasma::Types::TopEdge) {
        newGeometry.moveTop(m_mochaView->screenGeometry().top());
    } else if (m_mochaView->location() == Plasma::Types::LeftEdge) {
        newGeometry.moveLeft(m_mochaView->screenGeometry().left());
    } else if (m_mochaView->location() == Plasma::Types::RightEdge) {        
        newGeometry.moveLeft(m_mochaView->screenGeometry().right() - m_thickness);
    }

    if (m_mochaView->formFactor() == Plasma::Types::Horizontal) {
        newGeometry.setHeight(m_thickness + 1);
    } else {
        newGeometry.setWidth(m_thickness + 1);
    }

    m_calculatedGeometry = newGeometry;
    emit calculatedGeometryChanged();
}

bool ScreenEdgeGhostWindow::containsMouse() const
{
    return m_containsMouse;
}

void ScreenEdgeGhostWindow::setContainsMouse(bool contains)
{
    if (m_containsMouse == contains) {
        return;
    }

    m_containsMouse = contains;
    emit containsMouseChanged(contains);
}

bool ScreenEdgeGhostWindow::event(QEvent *e)
{
    if (e->type() == QEvent::DragEnter || e->type() == QEvent::DragMove) {
        if (!m_containsMouse) {
            m_delayedContainsMouse = false;
            m_delayedMouseTimer.stop();
            setContainsMouse(true);
            emit dragEntered();
        }
    } else if (e->type() == QEvent::Enter) {
        m_delayedContainsMouse = true;
        if (!m_delayedMouseTimer.isActive()) {
            m_delayedMouseTimer.start();
        }
    } else if (e->type() == QEvent::Leave || e->type() == QEvent::DragLeave) {
        m_delayedContainsMouse = false;
        if (!m_delayedMouseTimer.isActive()) {
            m_delayedMouseTimer.start();
        }
    }

    return SubWindow::event(e);
}

}
}
