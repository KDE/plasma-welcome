# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>

cmake_minimum_required(VERSION 3.16)

project(welcome)

include(FeatureSummary)

set(PROJECT_VERSION "5.27.5")
set(REQUIRED_QT_VERSION 5.15.2)
set(KF5_MIN_VERSION 5.98)

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)

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
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS Kirigami2 CoreAddons ConfigWidgets DBusAddons Declarative I18n KIO NewStuff Notifications Plasma Service WindowSystem)
find_package(KUserFeedback)
find_package(KAccounts REQUIRED)

ecm_set_disabled_deprecation_versions(QT 5.15.2
    KF 5.101
)

add_subdirectory(src)

install(PROGRAMS org.kde.plasma-welcome.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.plasma-welcome.desktop DESTINATION ${KDE_INSTALL_AUTOSTARTDIR})
install(FILES org.kde.plasma-welcome.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

ki18n_install(po)
