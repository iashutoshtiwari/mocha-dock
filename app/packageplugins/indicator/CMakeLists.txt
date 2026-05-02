kcoreaddons_add_plugin(mocha_packagestructure_indicator SOURCES indicatorpackage.cpp INSTALL_NAMESPACE kpackage/packagestructure)
set_target_properties(mocha_packagestructure_indicator PROPERTIES OUTPUT_NAME mocha_indicator)

target_link_libraries(mocha_packagestructure_indicator
   KF6::I18n
   KF6::Package
)
