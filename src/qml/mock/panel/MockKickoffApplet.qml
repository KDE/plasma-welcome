/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

import org.kde.plasma.welcome

MockAppletBase {
    id: applet

    implicitWidth: icon.implicitWidth

    Kirigami.Icon {
        id: icon
        anchors.centerIn: parent

        implicitWidth: Kirigami.Units.iconSizes.medium
        implicitHeight: Kirigami.Units.iconSizes.medium

        source: "start-here-kde-symbolic"
        color: PlasmaCore.Theme.textColor
    }
}
