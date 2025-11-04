# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>

kcoreaddons_add_plugin(kded_plasma-welcome INSTALL_NAMESPACE "kf6/kded")

ecm_qt_declare_logging_category(kded_plasma-welcome
    HEADER welcome_kded_debug.h
    IDENTIFIER WELCOME_KDED_LOG
    CATEGORY_NAME org.kde.plasma.welcome.kded
    DESCRIPTION "Welcome Center (KDED)"
    EXPORT WELCOME
)

target_sources(kded_plasma-welcome PRIVATE
    daemon.cpp
    daemon.h
)

target_link_libraries(kded_plasma-welcome PRIVATE
    Qt::Core
    KF6::DBusAddons
    KF6::KIOGui
    KF6::JobWidgets
)
