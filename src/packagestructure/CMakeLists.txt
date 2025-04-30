# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2025 Oliver Beard <olib141@outlook.com>

kcoreaddons_add_plugin(plasma-welcome_page
    SOURCES plasmawelcomepackage.cpp
    INSTALL_NAMESPACE kf6/packagestructure
)

target_link_libraries(plasma-welcome_page KF6::Package KF6::I18n)
