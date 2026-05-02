/*
    SPDX-FileCopyrightText: 2018 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef SECONDARYCONFIGVIEW_H
#define SECONDARYCONFIGVIEW_H

// local
#include <coretypes.h>
#include "subconfigview.h"
#include "../../wm/windowinfowrap.h"

//Qt
#include <QObject>
#include <QQuickView>
#include <QPointer>
#include <QTimer>

// Plasma
#include <Plasma/Plasma>
#include <KSvg/FrameSvg>


namespace Plasma {
class Applet;
class Containment;
class Types;
}

namespace Mocha {
class Corona;
class View;
}

namespace Mocha {
namespace ViewPart {
class PrimaryConfigView;
}
}

namespace Mocha {
namespace ViewPart {

class SecondaryConfigView : public SubConfigView
{
    Q_OBJECT

public:
    SecondaryConfigView(Mocha::View *view, PrimaryConfigView *parent);

    QRect geometryWhenVisible() const;

    void hideConfigWindow();

public slots:
    Q_INVOKABLE void syncGeometry() override;
    Q_INVOKABLE void updateEffects();

signals:
    void showSignal();

protected:
    void showEvent(QShowEvent *ev) override;
    void focusOutEvent(QFocusEvent *ev) override;

    void init() override;
    void initParentView(Mocha::View *view) override;
    void updateEnabledBorders() override;

private:
    QRect m_geometryWhenVisible;

    QPointer<PrimaryConfigView> m_parent;

    //only for the mask on disabled compositing, not to actually paint
    KSvg::FrameSvg *m_background{nullptr};
};

}
}
#endif //SECONDARYCONFIGVIEW_H

