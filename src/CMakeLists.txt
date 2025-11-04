# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
# SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>

# KDED Module
add_subdirectory(kded)

# Public library (org.kde.plasma.welcome)
add_subdirectory(public)

# Application, including private library (org.kde.plasma.welcome.private)
add_executable(plasma-welcome)
ecm_add_qml_module(plasma-welcome URI "org.kde.plasma.welcome.private" GENERATE_PLUGIN_SOURCE DEPENDENCIES QtQuick)

configure_file(config-plasma-welcome.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-plasma-welcome.h)

ecm_qt_declare_logging_category(plasma-welcome
    HEADER welcome_debug.h
    IDENTIFIER WELCOME_LOG
    CATEGORY_NAME org.kde.plasma.welcome
    DESCRIPTION "Welcome Center"
    EXPORT WELCOME
)

target_sources(plasma-welcome PRIVATE
    main.cpp

    app.cpp
    qmlconfig.h
    release.cpp
    plasmacolors.cpp
)

ecm_target_qml_sources(plasma-welcome
    SOURCES
    qml/Main.qml
    qml/PageError.qml
    qml/ContributionCard.qml

    qml/footers/Footer.qml
    qml/footers/FooterDefault.qml
    qml/footers/FooterUpdate.qml

    qml/mock/MockCard.qml
    qml/mock/MockActivities.qml
    qml/mock/MockKRunner.qml
    qml/mock/MockOverview.qml
    qml/mock/MockPanel.qml
    qml/mock/panel/MockAppletBase.qml
    qml/mock/panel/MockKickoffApplet.qml
    qml/mock/panel/MockTaskManager.qml
    qml/mock/panel/MockSystemTrayApplet.qml
    qml/mock/panel/MockSystemTrayIcon.qml
    qml/mock/panel/MockDigitalClockApplet.qml
    qml/mock/panel/MockShowDesktopApplet.qml
    qml/mock/MockPlasmoid.qml
    qml/mock/InteractionInhibitor.qml

    qml/pages/PlasmaUpdate.qml
    qml/pages/Live.qml
    qml/pages/Welcome.qml
    qml/pages/Network.qml
    qml/pages/network/PlasmaNM.qml
    qml/pages/network/PlasmaNMLoader.qml
    qml/pages/SimpleByDefault.qml
    qml/pages/PowerfulWhenNeeded.qml
    qml/pages/powerfulwhenneeded/PlasmaFeatureCard.qml
    qml/pages/powerfulwhenneeded/MetaKey.qml
    qml/pages/powerfulwhenneeded/Overview.qml
    qml/pages/powerfulwhenneeded/KRunner.qml
    qml/pages/powerfulwhenneeded/KDEConnect.qml
    qml/pages/powerfulwhenneeded/Activities.qml
    qml/pages/powerfulwhenneeded/Vaults.qml
    qml/pages/Discover.qml
    qml/pages/Feedback.qml
    qml/pages/Enjoy.qml
    qml/pages/enjoy/Supporters.qml

    RESOURCES
    assets/blender.svg
    assets/endlesssky.png
    assets/gimp.svg
    assets/krita.svg
    assets/konqi-kde-hi.png
    assets/konqi-default.png
    assets/kstars.svg
    assets/vlc.png
)

target_compile_definitions(plasma-welcome PRIVATE "DISTRO_CUSTOM_PAGE_FOLDER=\"${DISTRO_CUSTOM_PAGE_FOLDER}\"")
target_compile_definitions(plasma-welcome PRIVATE "DISTRO_CUSTOM_INTRO_FILE=\"${DISTRO_CUSTOM_INTRO_FILE}\"")

target_link_libraries(plasma-welcome PRIVATE
    plasma-welcome-publicplugin # Link the plugin for the public library
    Qt::Core
    Qt::Gui
    Qt::Network
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::Svg
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::CoreAddons
    KF6::DBusAddons
    KF6::I18n
    KF6::I18nQml
    KF6::JobWidgets
    KF6::Service
    KF6::WindowSystem
    Plasma::Plasma
)

kconfig_add_kcfg_files(plasma-welcome GENERATE_MOC config.kcfgc)

ecm_finalize_qml_module(plasma-welcome)
install(TARGETS plasma-welcome ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
