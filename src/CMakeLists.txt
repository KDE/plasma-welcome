add_executable(tour main.cpp about.cpp controller.cpp resources.qrc)
target_link_libraries(tour
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    KF5::I18n
    KF5::CoreAddons
    KF5::ConfigWidgets)
kconfig_add_kcfg_files(tour GENERATE_MOC tourconfig.kcfgc)
install(TARGETS tour ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
