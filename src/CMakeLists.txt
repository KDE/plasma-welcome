add_executable(welcome main.cpp about.cpp resources.qrc)
target_link_libraries(welcome
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    KF5::I18n
    KF5::CoreAddons
    KF5::ConfigWidgets)
kconfig_add_kcfg_files(welcome GENERATE_MOC welcomeconfig.kcfgc)
install(TARGETS welcome ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})