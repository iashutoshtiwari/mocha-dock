/*
    SPDX-FileCopyrightText: 2020 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "lattetasksplugin.h"

// local
#include "types.h"
#include "launcherhelper.h"

// Qt
#include <QtQml>


void LatteTasksPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.latte.private.tasks"));
    qmlRegisterUncreatableMetaObject(Latte::Tasks::Types::staticMetaObject, uri, 0, 1, "Types", QStringLiteral("Latte Tasks Types uncreatable"));
    qmlRegisterSingletonType<Latte::Tasks::LauncherHelper>(uri, 0, 1, "LauncherHelper",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return new Latte::Tasks::LauncherHelper();
        });
}

