/*
    SPDX-FileCopyrightText: 2020 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "mochatasksplugin.h"

// local
#include "types.h"
#include "launcherhelper.h"

// Qt
#include <QtQml>


void MochaTasksPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.mocha.private.tasks"));
    qmlRegisterUncreatableMetaObject(Mocha::Tasks::Types::staticMetaObject, uri, 0, 1, "Types", QStringLiteral("Mocha Tasks Types uncreatable"));
    qmlRegisterSingletonType<Mocha::Tasks::LauncherHelper>(uri, 0, 1, "LauncherHelper",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return new Mocha::Tasks::LauncherHelper();
        });
}

