# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>

configure_file(config-plasma-welcome.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-plasma-welcome.h)

add_executable(plasma-welcome)
ecm_add_qml_module(plasma-welcome URI "org.kde.plasma.welcome" GENERATE_PLUGIN_SOURCE)

target_sources(plasma-welcome PRIVATE
    main.cpp
    controller.cpp
    controller.h
    module.cpp
    module.h
    applicationInfo.cpp
    applicationInfo.h
    qmlconfig.h
)

ecm_target_qml_sources(plasma-welcome SOURCES
    qml/GenericPage.qml
    qml/KCM.qml
    qml/ApplicationIcon.qml
)

ecm_target_qml_sources(plasma-welcome PATH ""
    SOURCES
    contents/ui/Main.qml
    contents/ui/pages/PlasmaUpdate.qml
    contents/ui/pages/plasmaupdate/Update.qml
    contents/ui/pages/plasmaupdate/Beta.qml
    contents/ui/pages/Live.qml
    contents/ui/pages/Welcome.qml
    contents/ui/pages/Network.qml
    contents/ui/pages/network/PlasmaNM.qml
    contents/ui/pages/SimpleByDefault.qml
    contents/ui/pages/PowerfulWhenNeeded.qml
    contents/ui/pages/powerfulwhenneeded/PlasmaFeatureButton.qml
    contents/ui/pages/Discover.qml
    contents/ui/pages/kcms/Feedback.qml
    contents/ui/pages/Contribute.qml
    contents/ui/pages/Donate.qml
    RESOURCES
    contents/assets/konqi-donations.png
    contents/assets/konqi-kde-hi.png
    contents/assets/konqi-build.png
    contents/assets/krita.png
    contents/assets/endlesssky.png
)

target_compile_definitions(plasma-welcome PRIVATE "DISTRO_CUSTOM_PAGE_FOLDER=\"${DISTRO_CUSTOM_PAGE_FOLDER}\"")
target_compile_definitions(plasma-welcome PRIVATE "DISTRO_CUSTOM_INTRO_FILE=\"${DISTRO_CUSTOM_INTRO_FILE}\"")

target_link_libraries(plasma-welcome PRIVATE
    Qt::Core
    Qt::Gui
    Qt::Network
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::Svg
    KF6::I18n
    KF6::ConfigCore
    KF6::CoreAddons
    KF6::ConfigWidgets
    KF6::DBusAddons
    KF6::KIOGui
    KF6::JobWidgets
    KF6::KCMUtils
    KF6::Service
    KF6::WindowSystem
)
kconfig_add_kcfg_files(plasma-welcome GENERATE_MOC config.kcfgc)
install(TARGETS plasma-welcome ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

ecm_finalize_qml_module(plasma-welcome)

add_subdirectory(kded)
