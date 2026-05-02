/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef WINDOWSYSTEMTRACKEDLAYOUTINFO_H
#define WINDOWSYSTEMTRACKEDLAYOUTINFO_H

// local
#include "trackedgeneralinfo.h"
#include "../windowinfowrap.h"

// Qt
#include <QObject>
#include <QRect>

namespace Mocha {
namespace Layout {
class GenericLayout;
}
namespace WindowSystem {
namespace Tracker {
class Windows;
}
}
}


namespace Mocha {
namespace WindowSystem {
namespace Tracker {

class TrackedLayoutInfo : public TrackedGeneralInfo {
    Q_OBJECT

public:
    TrackedLayoutInfo(Tracker::Windows *tracker, Mocha::Layout::GenericLayout *layout);
    ~TrackedLayoutInfo() override;

    Mocha::Layout::GenericLayout *layout() const;

private:
    Mocha::Layout::GenericLayout *m_layout{nullptr};
};

}
}
}

#endif
