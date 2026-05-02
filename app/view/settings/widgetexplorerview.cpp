/*


    SPDX-FileCopyrightText: 2021 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "widgetexplorerview.h"

// local
#include "../panelshadows_p.h"
#include "../view.h"
#include "../../mochacorona.h"
#include "../../wm/abstractwindowinterface.h"

// Qt
#include <QQuickItem>
#include <QScreen>

// KDE
#include <KSvg/Svg>
#include <KWindowEffects>
#include <KWindowSystem>
#include <KPackage/Package>

namespace Mocha {
namespace ViewPart {

WidgetExplorerView::WidgetExplorerView(Mocha::View *view)
    : SubConfigView(view, QString("#widgetexplorerview#"), true)
{
    setResizeMode(QQuickView::SizeRootObjectToView);
    //!set flags early in order for wayland to initialize properly
    setFlags(wFlags());

    connect(this, &QQuickView::widthChanged, this, &WidgetExplorerView::updateEffects);
    connect(this, &QQuickView::heightChanged, this, &WidgetExplorerView::updateEffects);

    connect(this, &QQuickView::statusChanged, [&](QQuickView::Status status) {
        if (status == QQuickView::Ready) {
            updateEffects();
        }
    });

    setParentView(view);
    init();
}

void WidgetExplorerView::init()
{
    SubConfigView::init();

    QByteArray tempFilePath = "widgetexplorerui";

    updateEnabledBorders();

    auto source = QUrl::fromLocalFile(m_mochaView->containment()->corona()->kPackage().filePath(tempFilePath));
    setSource(source);
    syncGeometry();
}

bool WidgetExplorerView::hideOnWindowDeactivate() const
{
    return m_hideOnWindowDeactivate;
}

void WidgetExplorerView::setHideOnWindowDeactivate(bool hide)
{
    if (m_hideOnWindowDeactivate == hide) {
        return;
    }

    m_hideOnWindowDeactivate = hide;
    emit hideOnWindowDeactivateChanged();
}

Qt::WindowFlags WidgetExplorerView::wFlags() const
{
    return (flags() | Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
}

QRect WidgetExplorerView::geometryWhenVisible() const
{
    return m_geometryWhenVisible;
}

void WidgetExplorerView::initParentView(Mocha::View *view)
{
    SubConfigView::initParentView(view);

    rootContext()->setContextProperty(QStringLiteral("containmentFromView"), m_mochaView->containment());
    rootContext()->setContextProperty(QStringLiteral("mochaView"), m_mochaView);

    updateEnabledBorders();
    syncGeometry();
}

QRect WidgetExplorerView::availableScreenGeometry() const
{
    int currentScrId = m_mochaView->positioner()->currentScreenId();

    QList<Mocha::Types::Visibility> ignoreModes{Mocha::Types::SidebarOnDemand,Mocha::Types::SidebarAutoHide};

    if (m_mochaView->visibility() && m_mochaView->visibility()->isSidebar()) {
        ignoreModes.removeAll(Mocha::Types::SidebarOnDemand);
        ignoreModes.removeAll(Mocha::Types::SidebarAutoHide);
    }

    QString activityid = m_mochaView->layout()->lastUsedActivity();

    return m_corona->availableScreenRectWithCriteria(currentScrId, activityid, ignoreModes, {}, false, true);
}

void WidgetExplorerView::syncGeometry()
{
    if (!m_mochaView || !m_mochaView->layout() || !m_mochaView->containment() || !rootObject()) {
        return;
    }
    const QSize size(rootObject()->width(), rootObject()->height());
    auto availGeometry = availableScreenGeometry();

    int margin = availGeometry.height() == m_mochaView->screenGeometry().height() ? 100 : 0;
    auto geometry = QRect(availGeometry.x(), availGeometry.y(), size.width(), availGeometry.height()-margin);

    updateEnabledBorders();

    if (m_geometryWhenVisible == geometry) {
        return;
    }

    m_geometryWhenVisible = geometry;

    setPosition(geometry.topLeft());

    setMaximumSize(geometry.size());
    setMinimumSize(geometry.size());
    resize(geometry.size());
}

void WidgetExplorerView::showEvent(QShowEvent *ev)
{
    SubConfigView::showEvent(ev);

    if (!m_mochaView) {
        return;
    }

    syncGeometry();

    requestActivate();

    m_screenSyncTimer.start();
    QTimer::singleShot(400, this, &WidgetExplorerView::syncGeometry);

    emit showSignal();
}

void WidgetExplorerView::focusOutEvent(QFocusEvent *ev)
{
    Q_UNUSED(ev);

    if (!m_mochaView) {
        return;
    }

    hideConfigWindow();
}

void WidgetExplorerView::updateEffects()
{
    if (!m_background) {
        m_background = new KSvg::FrameSvg(this);
    }

    if (m_background->imagePath() != "dialogs/background") {
        m_background->setImagePath(QStringLiteral("dialogs/background"));
    }

    m_background->setEnabledBorders(m_enabledBorders);
    m_background->resizeFrame(size());

    QRegion mask = m_background->mask();

    QRegion fixedMask = mask.isNull() ? QRegion(QRect(0,0,width(),height())) : mask;

    if (!fixedMask.isEmpty()) {
        setMask(fixedMask);
    } else {
        setMask(QRegion());
    }

    KWindowEffects::enableBlurBehind(this, true, fixedMask);
}

void WidgetExplorerView::hideConfigWindow()
{
    if (!m_hideOnWindowDeactivate) {
        return;
    }

    deleteLater();
}

void WidgetExplorerView::syncSlideEffect()
{
    if (!m_mochaView || !m_mochaView->containment()) {
        return;
    }

    auto slideLocation = WindowSystem::AbstractWindowInterface::Slide::Left;

    m_corona->wm()->slideWindow(*this, slideLocation);
}

//!BEGIN borders
void WidgetExplorerView::updateEnabledBorders()
{
    if (!this->screen()) {
        return;
    }

    KSvg::FrameSvg::EnabledBorders borders = KSvg::FrameSvg::AllBorders;

    if (!m_geometryWhenVisible.isEmpty()) {
        if (m_geometryWhenVisible.x() == m_mochaView->screenGeometry().x()) {
            borders &= ~KSvg::FrameSvg::LeftBorder;
        }

        if (m_geometryWhenVisible.y() == m_mochaView->screenGeometry().y()) {
            borders &= ~KSvg::FrameSvg::TopBorder;
        }

        if (m_geometryWhenVisible.height() == m_mochaView->screenGeometry().height()) {
            borders &= ~KSvg::FrameSvg::BottomBorder;
        }
    }

    if (m_enabledBorders != borders) {
        if (isVisible()) {
            m_enabledBorders = borders;
        }
        m_corona->dialogShadows()->addWindow(this, m_enabledBorders);

        emit enabledBordersChanged();
    }
}

//!END borders

}
}

