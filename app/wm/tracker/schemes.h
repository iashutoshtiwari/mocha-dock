/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef SCHEMESTRACKER_H
#define SCHEMESTRACKER_H

// local
#include "../windowinfowrap.h"

// Qt
#include <QObject>


namespace Mocha {
namespace WindowSystem {
class WindowManager;
class SchemeColors;
}
}

namespace Mocha {
namespace WindowSystem {
namespace Tracker {

class Schemes : public QObject {
    Q_OBJECT

public:
    Schemes(WindowManager *parent);
    ~Schemes() override;

    SchemeColors *schemeForWindow(WindowId wId);
    void setColorSchemeForWindow(WindowId wId, QString scheme);

    SchemeColors *schemeForFile(const QString &scheme);

signals:
    void colorSchemeChanged(const WindowId &wid);
    void defaultSchemeChanged();

private slots:
    void updateDefaultScheme();

private:
    void init();

private:
     WindowManager *m_wm;

     //! scheme file and its loaded colors
     QMap<QString, Mocha::WindowSystem::SchemeColors *> m_schemes;

     //! window id and its corresponding scheme file
     QHash<WindowId, QString> m_windowScheme;
};

}
}
}

#endif
