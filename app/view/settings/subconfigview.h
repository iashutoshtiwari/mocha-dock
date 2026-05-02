/*
    SPDX-FileCopyrightText: 2020 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef SUBCONFIGVIEW_H
#define SUBCONFIGVIEW_H

// local
#include <coretypes.h>
#include "../../wm/windowinfowrap.h"

//Qt
#include <QObject>
#include <QPointer>
#include <QQuickView>
#include <QTimer>

//KF
#include <KSvg/FrameSvg>

namespace Mocha {
class Corona;
class View;
}


namespace Mocha {
namespace ViewPart {

class SubConfigView : public QQuickView
{
    Q_OBJECT
    Q_PROPERTY(KSvg::FrameSvg::EnabledBorders enabledBorders READ enabledBorders NOTIFY enabledBordersChanged)

public:
    SubConfigView(Mocha::View *view, const QString &title, const bool &isNormalWindow = true);
    ~SubConfigView() override;

    virtual void requestActivate();

    QString validTitle() const;

    KSvg::FrameSvg::EnabledBorders enabledBorders() const;

    Mocha::Corona *corona() const;
    Mocha::View *parentView() const;
    virtual void setParentView(Mocha::View *view, const bool &immediate = false);
    virtual void showAfter(int msecs = 0);

    Mocha::WindowSystem::WindowId trackedWindowId();

public slots:
    virtual void syncGeometry() = 0;

signals:
    void enabledBordersChanged();

protected:
    virtual void syncSlideEffect();

    virtual void init();
    virtual void initParentView(Mocha::View *view);
    virtual void updateEnabledBorders() = 0;

    void showEvent(QShowEvent *ev) override;
    bool event(QEvent *e) override;

    virtual Qt::WindowFlags wFlags() const;

protected:
    bool m_isNormalWindow{true};
    QTimer m_screenSyncTimer;

    QPointer<Mocha::View> m_latteView;

    QList<QMetaObject::Connection> connections;
    QList<QMetaObject::Connection> viewconnections;

    KSvg::FrameSvg::EnabledBorders m_enabledBorders{KSvg::FrameSvg::AllBorders};

    Mocha::Corona *m_corona{nullptr};

private slots:
    void updateWaylandId();

private:
    QString m_validTitle;

    QTimer m_showTimer;

    Mocha::WindowSystem::WindowId m_waylandWindowId;
};

}
}
#endif //SUBCONFIGVIEW_H
