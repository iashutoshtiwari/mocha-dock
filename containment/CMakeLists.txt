add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.mocha.containment\")

plasma_install_package(package org.kde.mocha.containment)

set(containment_SRCS
    plugin/types.h
    plugin/mochatypes.h
    plugin/types.cpp
    plugin/layoutmanager.cpp
    plugin/mochacontainmentplugin.cpp
)

add_library(mochacontainmentplugin SHARED ${containment_SRCS})

target_link_libraries(mochacontainmentplugin
                      Qt::Core
                      Qt::Qml
                      Qt::Quick
                      KF6::ConfigQml
                      Plasma::Plasma
                      Plasma::PlasmaQuick)

install(TARGETS mochacontainmentplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mocha/private/containment)
install(FILES plugin/qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mocha/private/containment)
