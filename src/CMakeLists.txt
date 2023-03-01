# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>

set(HAVE_KUSERFEEDBACK ${KUserFeedback_FOUND})
configure_file(kuserfeedbacksettings.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/kuserfeedbacksettings.h)
configure_file(version.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/version.h)

add_executable(plasma-welcome main.cpp controller.cpp resources.qrc module.cpp)

target_compile_definitions(plasma-welcome PRIVATE "DISTRO_PAGE_PATH=\"${DISTRO_PAGE_PATH}\"")

target_link_libraries(plasma-welcome
    Qt::Core
    Qt::Gui
    Qt::Network
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::Svg
    KF6::I18n
    KF6::CoreAddons
    KF6::ConfigWidgets
    KF6::DBusAddons
    KF6::KIOGui
    KF6::Notifications
    KF6::QuickAddons
    KF6::Service
    KF6::WindowSystem
)
kconfig_add_kcfg_files(plasma-welcome GENERATE_MOC config.kcfgc)
install(TARGETS plasma-welcome ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

ecm_add_qml_module(PlasmaWelcomeModule URI "org.kde.plasma.welcome" NO_PLUGIN VERSION 1.0)
ecm_target_qml_sources(PlasmaWelcomeModule SOURCES qml/GenericPage.qml)
ecm_target_qml_sources(PlasmaWelcomeModule SOURCES qml/KCM.qml)
ecm_finalize_qml_module(PlasmaWelcomeModule DESTINATION ${KDE_INSTALL_QMLDIR})

add_subdirectory(kded)
