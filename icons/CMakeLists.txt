include(ECMInstallIcons)

ecm_install_icons(ICONS
    16-apps-mocha-dock.svg
    22-apps-mocha-dock.svg
    24-apps-mocha-dock.svg
    32-apps-mocha-dock.svg
    48-apps-mocha-dock.svg
    sc-apps-mocha-dock.svg
THEME hicolor
DESTINATION ${KDE_INSTALL_ICONDIR})

install(FILES org.kde.mocha.plasmoid.svg DESTINATION ${KDE_INSTALL_ICONDIR}/breeze/applets/256)
