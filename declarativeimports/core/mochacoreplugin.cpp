/*
    SPDX-FileCopyrightText: 2016 Smith AR <audoban@openmailbox.org>
    SPDX-FileCopyrightText: 2016 Michail Vourlakos <mvourlakos@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "mochacoreplugin.h"

// local
#include "dialog.h"
#include "environment.h"
#include "iconitem.h"
#include "quickwindowsystem.h"
#include "tools.h"

#include <types.h>

// Qt
#include <QtQml>


void MochaCorePlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.mocha.core"));
    qmlRegisterUncreatableMetaObject(Mocha::Types::staticMetaObject, uri, 0, 2, "Types", QStringLiteral("Mocha Types uncreatable"));
    qmlRegisterType<Mocha::IconItem>(uri, 0, 2, "IconItem");
    qmlRegisterType<Mocha::Quick::Dialog>(uri, 0, 2, "Dialog");
    qmlRegisterSingletonType<Mocha::Environment>(uri, 0, 2, "Environment", &Mocha::environment_qobject_singletontype_provider);
    qmlRegisterSingletonType<Mocha::Tools>(uri, 0, 2, "Tools", &Mocha::tools_qobject_singletontype_provider);
    qmlRegisterSingletonType<Mocha::QuickWindowSystem>(uri, 0, 2, "WindowSystem", &Mocha::windowsystem_qobject_singletontype_provider);
}
