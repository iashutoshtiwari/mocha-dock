add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.mocha.plasmoid\")

plasma_install_package(package org.kde.mocha.plasmoid)

set(tasks_SRCS
    plugin/types.cpp
    plugin/launcherhelper.cpp
    plugin/mochatasksplugin.cpp
)

qt_add_library(mochatasksplugin SHARED ${tasks_SRCS})

target_link_libraries(mochatasksplugin
                      Qt::Core
                      Qt::Qml
                      Plasma::Plasma
                      Plasma::PlasmaQuick)

install(TARGETS mochatasksplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mocha/private/tasks)
install(FILES plugin/qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mocha/private/tasks)
