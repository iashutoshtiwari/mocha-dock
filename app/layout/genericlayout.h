/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GENERICLAYOUT_H
#define GENERICLAYOUT_H

// local
#include <coretypes.h>
#include "abstractlayout.h"
#include "../data/errordata.h"
#include "../data/viewdata.h"
#include "../data/viewstable.h"

// Qt
#include <QObject>
#include <QQuickView>
#include <QPointer>
#include <QScreen>

// Plasma
#include <Plasma/Plasma>

namespace Plasma {
class Applet;
class Containment;
class Types;
}

namespace Mocha {
class Corona;
class ScreenPool;
class View;
}

namespace Mocha {
namespace Layout {

//! This is  views map in the following structure:
//! SCREEN_NAME -> EDGE -> VIEWID
typedef QHash<QString, QHash<Plasma::Types::Location, QList<uint>>> ViewsMap;

class GenericLayout : public AbstractLayout
{
    Q_OBJECT
    Q_PROPERTY(int viewsCount READ viewsCount NOTIFY viewsCountChanged)

public:   
    GenericLayout(QObject *parent, QString layoutFile, QString assignedName = QString());
    ~GenericLayout() override;

    QString background() const override;
    QString textColor() const override;

    virtual const QStringList appliedActivities() = 0; // to move at an interface

    virtual bool initCorona();
    void importToCorona();
    bool initContainments();
    void setCorona(Mocha::Corona *corona);

    bool isActive() const; //! is loaded and running
    virtual bool isCurrent();
    bool isWritable() const;
    bool hasCorona() const;

    virtual int viewsCount(int screen) const;
    virtual int viewsCount(QScreen *screen) const;
    virtual int viewsCount() const;

    Type type() const override;

    Mocha::Corona *corona() const;

    QStringList unloadedContainmentsIds();

    virtual Types::ViewType mochaViewType(uint containmentId) const;
    const QList<Plasma::Containment *> *containments() const;

    bool contains(Plasma::Containment *containment) const;
    bool containsView(const int &containmentId) const;
    int screenForContainment(Plasma::Containment *containment);

    Mocha::View *highestPriorityView();
    Mocha::View *viewForContainment(uint id) const;
    Mocha::View *viewForContainment(Plasma::Containment *containment) const;
    Plasma::Containment *containmentForId(uint id) const;
    QList<Plasma::Containment *> subContainmentsOf(uint id) const;

    static bool viewAtLowerScreenPriority(Mocha::View *test, Mocha::View *base, QScreen *primaryScreen);
    static bool viewAtLowerEdgePriority(Mocha::View *test, Mocha::View *base);
    static QList<Mocha::View *> sortedMochaViews(QList<Mocha::View *> views, QScreen *primaryScreen);

    QList<Mocha::View *> sortedMochaViews();
    virtual QList<Mocha::View *> viewsWithPlasmaShortcuts();
    virtual QList<Mocha::View *> mochaViews();
    virtual QList<Mocha::View *> onlyOriginalViews();
    ViewsMap validViewsMap();
    virtual void syncMochaViewsToScreens();

    void syncToLayoutFile(bool removeLayoutId = false);

    void lock(); //! make it only read-only
    void renameLayout(QString newName);
    virtual void unloadContainments();
    void unloadMochaViews();
    void unlock(); //! make it writable which it should be the default

    virtual void setLastConfigViewFor(Mocha::View *view);
    virtual Mocha::View *lastConfigViewFor();

    //! this function needs the layout to have first set the corona through setCorona() function
    virtual void addView(Plasma::Containment *containment);
    void recreateView(Plasma::Containment *containment, bool delayed = true);
    bool hasMochaView(Plasma::Containment *containment);

    bool newView(const QString &templateName);
    Data::View newView(const Mocha::Data::View &nextViewData);
    void removeView(const Mocha::Data::View &viewData);
    void updateView(const Mocha::Data::View &viewData);    
    QString storedView(const int &containmentId); //returns temp filepath containing all view data
    void removeOrphanedSubContainment(const int &containmentId);

    //! Available edges for specific view in that screen
    virtual QList<Plasma::Types::Location> availableEdgesForView(QScreen *scr, Mocha::View *forView) const;
    //! All free edges in that screen
    virtual QList<Plasma::Types::Location> freeEdges(QScreen *scr) const;
    virtual QList<Plasma::Types::Location> freeEdges(int screen) const;

    //! Bind this mochaView and its relevant containments(including subcontainments)
    //! to this layout. It is used for moving a Mocha::View from layout to layout)
    void assignToLayout(Mocha::View *mochaView, QList<Plasma::Containment *> containments);
    //! Unassign that mochaView from this layout (this is used for moving a mochaView
    //! from layout to layout) and returns all the containments relevant to
    //! that mochaView
    QList<Plasma::Containment *> unassignFromLayout(Plasma::Containment *mochaContainment);

    QList<int> viewsExplicitScreens();

    Mocha::Data::ViewsTable viewsTable() const;

    //! errors/warnings
    Data::ErrorsList errors() const;
    Data::WarningsList warnings() const;

public slots:
    Q_INVOKABLE int viewsWithTasks() const;
    virtual Q_INVOKABLE QList<int> qmlFreeEdges(int screen) const;  //change <Plasma::Types::Location> to <int> types

    void toggleHiddenState(QString viewName, QString screenName, Plasma::Types::Location edge);

signals:
    void activitiesChanged(); // to move at an interface
    void viewsCountChanged(int screenId);
    void viewEdgeChanged();

    //! used from ConfigView(s) in order to be informed which is one should be shown
    void lastConfigViewForChanged(Mocha::View *view);

    //! used from MochaView(s) in order to exist only one each time that has the highest priority
    //! to use the global shortcuts activations
    void preferredViewForShortcutsChanged(Mocha::View *view);

protected:
    void updateLastUsedActivity();

protected:
    Mocha::Corona *m_corona{nullptr};

    QList<Plasma::Containment *> m_containments;

    QHash<const Plasma::Containment *, Mocha::View *> m_mochaViews;
    QHash<const Plasma::Containment *, Mocha::View *> m_waitingMochaViews;

private slots:
    void addContainment(Plasma::Containment *containment);
    void appletCreated(Plasma::Applet *applet);
    void destroyedChanged(bool destroyed);
    void containmentDestroyed(QObject *cont);
    void onLastConfigViewChangedFrom(Mocha::View *view);

private:
    //! It can be used in order for MochaViews to not be created automatically when
    //! their corresponding containments are created e.g. copyView functionality
    bool blockAutomaticMochaViewCreation() const;
    void setBlockAutomaticMochaViewCreation(bool block);

    bool explicitDockOccupyEdge(int screen, Plasma::Types::Location location) const;
    bool primaryDockOccupyEdge(Plasma::Types::Location location) const;

    bool viewDataAtLowerEdgePriority(const Mocha::Data::View &test, const Mocha::Data::View &base) const;
    bool viewDataAtLowerScreenPriority(const Mocha::Data::View &test, const Mocha::Data::View &base) const;
    bool viewDataAtLowerStatePriority(const Mocha::Data::View &test, const Mocha::Data::View &base) const;

    bool mapContainsId(const ViewsMap *map, uint viewId) const;
    QString mapScreenName(const ViewsMap *map, uint viewId) const;

    QList<int> subContainmentsOf(Plasma::Containment *containment) const;

    QList<Mocha::Data::View> sortedViewsData(const QList<Mocha::Data::View> &viewsData);

    void destroyContainment(Plasma::Containment *containment);

private:
    bool m_blockAutomaticMochaViewCreation{false};
    bool m_hasInitializedContainments{false};
    QPointer<Mocha::View> m_lastConfigViewFor;

    QStringList m_unloadedContainmentsIds;

    //! try to avoid crashes from recreating the same views all the time
    QList<const Plasma::Containment *> m_viewsToRecreate;

    //! Containments that are pending screen/state updates
    Mocha::Data::ViewsTable m_pendingContainmentUpdates;

    friend class Mocha::View;
};

}
}

#endif
