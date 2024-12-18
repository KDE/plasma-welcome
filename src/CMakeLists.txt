# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
# SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>

# KDED Module
add_subdirectory(kded)

# Private library
add_subdirectory(private)

# Application
add_executable(plasma-welcome)
ecm_add_qml_module(plasma-welcome URI "org.kde.plasma.welcome" GENERATE_PLUGIN_SOURCE)

target_sources(plasma-welcome PRIVATE
    main.cpp

    controller.cpp
    distro.cpp
    utils.cpp

    configModule.cpp
    applicationInfo.cpp
)

ecm_target_qml_sources(plasma-welcome
    SOURCES
    qml/Page.qml
    qml/GenericPage.qml
    qml/ScrollablePage.qml
    qml/KCMPage.qml
    qml/ApplicationIcon.qml
)

target_link_libraries(plasma-welcome PRIVATE
    plasma-welcome-private
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
    KF6::DBusAddons
    KF6::KIOGui
    KF6::JobWidgets
    KF6::KCMUtils
    KF6::ConfigGui
    KF6::Service
    KF6::WindowSystem
    KF6::I18nQml
)

ecm_finalize_qml_module(plasma-welcome)
install(TARGETS plasma-welcome ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
