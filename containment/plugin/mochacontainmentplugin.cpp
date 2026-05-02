/*
    SPDX-FileCopyrightText: 2020 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "mochacontainmentplugin.h"

// local
#include "layoutmanager.h"
#include "types.h"

// Qt
#include <QtQml>

void MochaContainmentPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.mocha.private.containment"));
    qmlRegisterUncreatableMetaObject(Mocha::Containment::Types::staticMetaObject, uri, 0, 1, "Types", QStringLiteral("Mocha Containment Types uncreatable"));
    qmlRegisterType<Mocha::Containment::LayoutManager>(uri, 0, 1, "LayoutManager");
}

