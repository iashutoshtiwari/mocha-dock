configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config-mocha-lib.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-mocha-lib.h)

include_directories(../../legacy)

set(mochacoreplugin_SRCS
    mochacoreplugin.cpp
    dialog.cpp
    environment.cpp
    ../../legacy/ManagedTextureNode.cpp
    iconitem.cpp
    quickwindowsystem.cpp
    tools.cpp
    types.h
)

add_library(mochacoreplugin SHARED ${mochacoreplugin_SRCS})

target_link_libraries(mochacoreplugin
    Qt::Quick
    Qt::Qml
    KF6::CoreAddons
    KF6::IconThemes
    KF6::Svg
    KF6::WindowSystem
    Plasma::Plasma
    Plasma::PlasmaQuick
)


install(TARGETS mochacoreplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mocha/core)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mocha/core)
