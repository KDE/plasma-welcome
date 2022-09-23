# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>

add_executable(plasma-welcome main.cpp about.cpp controller.cpp resources.qrc module.cpp)
target_link_libraries(plasma-welcome
    Qt${QT_MAJOR_VERSION}::Core
    Qt${QT_MAJOR_VERSION}::Gui
    Qt${QT_MAJOR_VERSION}::Qml
    Qt${QT_MAJOR_VERSION}::Quick
    Qt${QT_MAJOR_VERSION}::QuickControls2
    Qt${QT_MAJOR_VERSION}::Svg
    KF5::I18n
    KF5::CoreAddons
    KF5::DBusAddons
    KF5::KIOGui
    KF5::NetworkManagerQt
    KF5::Notifications
    KF5::QuickAddons
    KF5::Service
    KF5::WindowSystem
)
install(TARGETS plasma-welcome ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
