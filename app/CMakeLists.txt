set(mochadock-app_SRCS
    alternativeshelper.cpp
    apptypes.cpp
    infoview.cpp
    mochacorona.cpp
    screenpool.cpp
    primaryoutputwatcher.cpp
    main.cpp
    coretypes.h
)

add_subdirectory(data)
add_subdirectory(declarativeimports)
add_subdirectory(indicator)
add_subdirectory(layout)
add_subdirectory(layouts)
add_subdirectory(package)
add_subdirectory(plasma/extended)
add_subdirectory(settings)
add_subdirectory(settings/generic)
add_subdirectory(settings/actionsdialog)
add_subdirectory(settings/detailsdialog)
add_subdirectory(settings/detailsdialog/delegates)
add_subdirectory(settings/exporttemplatedialog)
add_subdirectory(settings/exporttemplatedialog/delegates)
add_subdirectory(settings/screensdialog)
add_subdirectory(settings/screensdialog/delegates)
add_subdirectory(settings/settingsdialog)
add_subdirectory(settings/settingsdialog/delegates)
add_subdirectory(settings/viewsdialog)
add_subdirectory(settings/viewsdialog/delegates)
add_subdirectory(shortcuts)
add_subdirectory(templates)
add_subdirectory(tools)
add_subdirectory(view)
add_subdirectory(view/helpers)
add_subdirectory(view/indicator)
add_subdirectory(view/settings)
add_subdirectory(view/windowstracker)
add_subdirectory(wm)
add_subdirectory(wm/tracker)

set(mocha_dbusXML dbus/org.kde.MochaDock.xml)
qt_add_dbus_adaptor(mochadock-app_SRCS ${mocha_dbusXML} mochacorona.h Mocha::Corona mochadockadaptor)

ki18n_wrap_ui(mochadock-app_SRCS settings/actionsdialog/actionsdialog.ui)
ki18n_wrap_ui(mochadock-app_SRCS settings/detailsdialog/detailsdialog.ui)
ki18n_wrap_ui(mochadock-app_SRCS settings/exporttemplatedialog/exporttemplatedialog.ui)
ki18n_wrap_ui(mochadock-app_SRCS settings/screensdialog/screensdialog.ui)
ki18n_wrap_ui(mochadock-app_SRCS settings/settingsdialog/settingsdialog.ui)
ki18n_wrap_ui(mochadock-app_SRCS settings/viewsdialog/viewsdialog.ui)

add_executable(mocha-dock ${mochadock-app_SRCS})

include(FakeTarget.cmake)

qt6_generate_wayland_protocol_client_sources(mocha-dock FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/protocols/kde-primary-output-v1.xml)

target_link_libraries(mocha-dock
    Qt::DBus
    Qt::Quick
    Qt::Qml
    KF6::Archive
    KF6::CoreAddons
    KF6::Crash
    KF6::DBusAddons
    KF6::GuiAddons
    KF6::GlobalAccel
    KF6::I18n
    KF6::IconThemes
    KF6::IconWidgets
    KF6::KIOWidgets
    KF6::Notifications
    KF6::NewStuffWidgets
    KF6::Package
    KF6::Svg
    KF6::WindowSystem
    KF6::XmlGui
    KF6::ConfigQml
    Qt::WaylandClient
    Wayland::Client
    Plasma::Activities
    Plasma::KWaylandClient
    Plasma::Plasma
    Plasma::PlasmaQuick
    LayerShellQt::Interface
    PW::LibTaskManager
)



configure_file(org.kde.mocha-dock.desktop.cmake org.kde.mocha-dock.desktop)
configure_file(org.kde.mocha-dock.appdata.xml.cmake org.kde.mocha-dock.appdata.xml)

install(TARGETS mocha-dock ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.mocha-dock.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.mocha-dock.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES dbus/org.kde.MochaDock.xml DESTINATION ${KDE_INSTALL_DBUSINTERFACEDIR})
install(FILES mochadock.notifyrc DESTINATION ${KDE_INSTALL_KNOTIFYRCDIR})
install(FILES mocha-layouts.knsrc DESTINATION  ${KDE_INSTALL_KNSRCDIR})
install(FILES mocha-indicators.knsrc DESTINATION  ${KDE_INSTALL_KNSRCDIR})


add_subdirectory(packageplugins)
