/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome

GenericPage {
    id: root

    readonly property string simplePlasmaVersion: Controller.simplePlasmaVersion
    readonly property int iconSize: Kirigami.Units.iconSizes.enormous

    heading: i18nc("@title:window", "Plasma has been updated to version %1", simplePlasmaVersion)
    description: xi18nc("@info:usagetip", "KDE contributors have spent the last four months hard at work on this release. We hope you enjoy using Plasma as much as we enjoyed making it!")

    topContent: [
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Find out what's new in Plasma %1", simplePlasmaVersion)
            url: "https://kde.org/announcements/plasma/5/" + simplePlasmaVersion + ".0?source=plasma-welcome"
        },
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Help work on the next release")
            url: "https://community.kde.org/Get_Involved?source=plasma-welcome"
        },
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Make a donation")
            url: "https://kde.org/community/donations?source=plasma-welcome"
        }
    ]

    RowLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 2
        spacing: Kirigami.Units.largeSpacing * 4

        Kirigami.Icon {
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            source: "start-here-kde-plasma"
        }

        QQC2.Label {
            text: "="
            font.pointSize: 72
        }

        Kirigami.Icon {
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            source: "face-in-love"
        }
    }
}
