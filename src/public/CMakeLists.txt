# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>

add_library(plasma-welcome-public STATIC)
ecm_add_qml_module(plasma-welcome-public
    URI "org.kde.plasma.welcome"
    GENERATE_PLUGIN_SOURCE
    DEPENDENCIES org.kde.kcmutils
)

target_sources(plasma-welcome-public PRIVATE
    controller.cpp
    distro.cpp
    utils.cpp

    configModule.cpp
    applicationInfo.cpp
)

ecm_target_qml_sources(plasma-welcome-public
    SOURCES
    qml/Page.qml
    qml/GenericPage.qml
    qml/ScrollablePage.qml
    qml/KCMPage.qml
    qml/ApplicationIcon.qml
)

target_link_libraries(plasma-welcome-public PRIVATE
    Qt::Core
    KF6::CoreAddons
    KF6::I18n
    KF6::JobWidgets
    KF6::KCMUtils
    KF6::KIOGui
)

ecm_finalize_qml_module(plasma-welcome-public)
