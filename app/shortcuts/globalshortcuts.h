/*
    SPDX-FileCopyrightText: 2016 Smith AR <audoban@openmailbox.org>
    SPDX-FileCopyrightText: 2016 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GLOBALSHORTCUTS_H
#define GLOBALSHORTCUTS_H

// local
#include <coretypes.h>

// Qt
#include <QAction>
#include <QPointer>
#include <QTimer>

// KDE
#include <kmodifierkeyinfo.h>


namespace Plasma {
class Containment;
}

namespace Mocha {
class Corona;
class View;
namespace ShortcutsPart{
class ModifierTracker;
class ShortcutsTracker;
}
}

namespace Mocha {

class GlobalShortcuts : public QObject
{
    Q_OBJECT

public:
    static constexpr const char* SHORTCUTBLOCKHIDINGTYPE  = "globalshortcuts::blockHiding()";

    GlobalShortcuts(QObject *parent = nullptr);
    ~GlobalShortcuts() override;

    void activateLauncherMenu();
    void updateViewItemBadge(QString identifier, QString value);

    ShortcutsPart::ShortcutsTracker *shortcutsTracker() const;

signals:
    void modifiersChanged();

private slots:
    void hideViewsTimerSlot();

private:
    void init();
    void initModifiers();
    void activateEntry(int index, Qt::Key modifier);
    void showViews();
    void showSettings();

    bool activateMochaEntry(Mocha::View *view, int index, Qt::Key modifier, bool *delayedExecution);
    bool activatePlasmaTaskManager(const Mocha::View *view, int index, Qt::Key modifier, bool *delayedExecution);
    bool activateEntryForView(Mocha::View *view, int index, Qt::Key modifier);
    bool viewAtLowerEdgePriority(Mocha::View *test, Mocha::View *base);
    bool viewAtLowerScreenPriority(Mocha::View *test, Mocha::View *base);
    bool viewsToHideAreValid();

    //! highest priority application launcher view
    Mocha::View *highestApplicationLauncherView(const QList<Mocha::View *> &views) const;

    QList<Mocha::View *> sortedViewsList(QHash<const Plasma::Containment *, Mocha::View *> *views);

private:
    bool m_metaShowedViews{false};

    //! last action that was triggered from the user
    QAction *m_lastInvokedAction;
    //! it is used for code compatibility reasons in order to replicate a single Meta action
    QAction *m_singleMetaAction;

    //! delayer for hiding the shown mocha views
    QTimer m_hideViewsTimer;
    QList<Mocha::View *> m_hideViews;

    QPointer<ShortcutsPart::ModifierTracker> m_modifierTracker;
    QPointer<ShortcutsPart::ShortcutsTracker> m_shortcutsTracker;
    QPointer<Mocha::Corona> m_corona;
};

}

#endif // GLOBALSHORTCUTS_H
