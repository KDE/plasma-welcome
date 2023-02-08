# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>

kcoreaddons_add_plugin(kded_plasma-welcome INSTALL_NAMESPACE "kf${QT_MAJOR_VERSION}/kded")

target_sources(kded_plasma-welcome PRIVATE
    daemon.cpp
)

target_link_libraries(kded_plasma-welcome PRIVATE
    Qt::Core
    KF5::DBusAddons
    KF5::ConfigWidgets
    KF5::KIOGui
    KF5::Notifications
)
