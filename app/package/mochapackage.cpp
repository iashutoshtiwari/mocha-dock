/*
    SPDX-FileCopyrightText: 2016 Smith AR <audoban@openmailbox.org>
    SPDX-FileCopyrightText: 2016 Michail Vourlakos <mvourlakos@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "mochapackage.h"

// Qt
#include <QDebug>
#include <QLatin1String>

// KDE
#include <KPackage/PackageLoader>

namespace Mocha {

Package::Package(QObject *parent, const QVariantList &args)
    : KPackage::PackageStructure(parent, args)
{
}

Package::~Package()
{
}

void Package::initPackage(KPackage::Package *package)
{
    auto fallback = KPackage::PackageLoader::self()->loadPackage("Plasma/Shell", "org.kde.plasma.desktop");
    if(!fallback.isValid()) {
        qDebug() << "Failed to load fallback plasma shell package";
    }
    package->setDefaultPackageRoot(QStringLiteral("plasma/shells/"));
    package->setPath("org.kde.mocha.shell");
    package->addFileDefinition("defaults", QStringLiteral("defaults"));
    package->addFileDefinition("mochadockui", QStringLiteral("views/Panel.qml"));
    package->addFileDefinition("widgetexplorerui", QStringLiteral("views/WidgetExplorer.qml"));
    //Configuration
    package->addFileDefinition("mochadockconfigurationui", QStringLiteral("configuration/MochaDockConfiguration.qml"));
    package->addFileDefinition("mochadocksecondaryconfigurationui", QStringLiteral("configuration/MochaDockSecondaryConfiguration.qml"));
    package->addFileDefinition("canvasconfigurationui", QStringLiteral("configuration/CanvasConfiguration.qml"));
    package->addFileDefinition("configmodel", QStringLiteral("configuration/config.qml"));
    package->addFileDefinition("splitter", QStringLiteral("images/splitter.svgz"));
    package->addFileDefinition("trademark", QStringLiteral("images/trademark.svgz"));
    package->addFileDefinition("trademarkicon", QStringLiteral("images/trademarkicon.svgz"));
    package->addFileDefinition("infoviewui", QStringLiteral("views/InfoView.qml"));

    package->addFileDefinition("layout1", QStringLiteral("layouts/Default.mocharc"));
    package->addFileDefinition("layout2", QStringLiteral("layouts/Plasma.mocharc"));
    package->addFileDefinition("layout3", QStringLiteral("layouts/Unity.mocharc"));
    package->addFileDefinition("layout4", QStringLiteral("layouts/Extended.mocharc"));

    package->addFileDefinition("templates", QStringLiteral("templates"));

    package->addFileDefinition("preset1", QStringLiteral("presets/Default.layout.mocha"));
    package->addFileDefinition("preset2", QStringLiteral("presets/Plasma.layout.mocha"));
    package->addFileDefinition("preset3", QStringLiteral("presets/Unity.layout.mocha"));
    package->addFileDefinition("preset4", QStringLiteral("presets/Extended.layout.mocha"));
    package->addFileDefinition("preset10", QStringLiteral("presets/multiple-layouts_hidden.layout.mocha"));

    //! applets
    package->addFileDefinition("compactapplet", QStringLiteral("applet/CompactApplet.qml"));

    package->setFallbackPackage(fallback);
    qDebug() << "package is valid" << package->isValid();
}

void Package::pathChanged(KPackage::Package *package)
{
    if (!package->metadata().isValid())
        return;

    const QString pluginName = package->metadata().pluginId();

    if (!pluginName.isEmpty() && pluginName != "org.kde.mocha.shell") {
        auto fallback = KPackage::PackageLoader::self()->loadPackage("Plasma/Shell", "org.kde.mocha.shell");
        package->setFallbackPackage(fallback);
    } else if (pluginName.isEmpty() || pluginName == QLatin1String("org.kde.mocha.shell")) {
        package->setFallbackPackage(KPackage::Package());
    }
}

}
