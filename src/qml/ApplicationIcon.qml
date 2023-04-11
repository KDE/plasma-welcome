/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15

import org.kde.plasma.welcome 1.0

GenericIcon {
    id: root

    required property string application

    ApplicationInfo {
        id: appInfo
        desktopName: root.application
    }

    source: appInfo.icon
    onTapped: Controller.launchApp(appInfo.desktopName)
    title: appInfo.name
    toolTip: i18nc("@action:button", "Launch %1 now", appInfo.name)
}
