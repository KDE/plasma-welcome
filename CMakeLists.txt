# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>

cmake_minimum_required(VERSION 3.16)

project(welcome)

include(FeatureSummary)

set(PROJECT_VERSION "5.27.80")
set(REQUIRED_QT_VERSION 6.4.0)
set(KF6_MIN_VERSION 5.240.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

include(KDEClangFormat)
include(KDEGitCommitHooks)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(ECMPoQmTools)
include(ECMQmlModule)
include(ECMDeprecationSettings)

set(DISTRO_PAGE_PATH "/usr/share/plasma-welcome-extra-pages/" CACHE STRING "Path on disk to find custom pages")

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h *.hpp *.c)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX PLASMA_WELCOME
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/src/plasma-welcome-version.h"
)

find_package(Qt${QT_MAJOR_VERSION} ${REQUIRED_QT_VERSION} REQUIRED COMPONENTS Core Gui Network Qml QuickControls2 Svg)
find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS Kirigami2 CoreAddons ConfigWidgets DBusAddons I18n KIO NewStuff Notifications Plasma Service WindowSystem DBusAddons KCMUtils)

find_package(KUserFeedback)
set_package_properties(KUserFeedback PROPERTIES
    DESCRIPTION "Framework for collecting user feedback for apps via telemetry and surveys"
    PURPOSE "Required for embedded User Feedback settings page"
    TYPE RUNTIME
)


find_package(KAccounts)
set_package_properties(KAccounts PROPERTIES
    DESCRIPTION "Online account management system and its Plasma integration components"
    PURPOSE "Required for embedded Online Accounts settings page"
    TYPE RUNTIME
)


ecm_set_disabled_deprecation_versions(QT 5.15.2
    KF 5.101
)

add_subdirectory(src)

install(PROGRAMS org.kde.plasma-welcome.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.plasma-welcome.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

ki18n_install(po)
