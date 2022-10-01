/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

import org.kde.welcome 1.0

GenericPage {
    id: root

    readonly property string newPlasmaVersion: Controller.newPlasmaVersion
    readonly property int iconSize: Kirigami.Units.iconSizes.enormous

    heading: i18nc("@title:window", "Plasma has been updated to version %1", newPlasmaVersion)
    description: xi18nc("@info:usagetip", "KDE contributors have spent the last four months hard at work on this release. We hope you enjoy using Plasma as much as we enjoyed making it!")

    topContent: [
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Find out what's new in Plasma %1", newPlasmaVersion)
            url: "https://kde.org/announcements/plasma/5/" + root.newPlasmaVersion + ".0"
        },
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Help work on the next release")
            url: "https://community.kde.org/Get_Involved"
        },
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Make a donation")
            url: "https://kde.org/community/donations/"
        }
    ]

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 2
        spacing: Kirigami.Units.largeSpacing * 2

        Kirigami.Icon {
            Layout.preferredWidth: root.iconSize/1.5
            Layout.preferredHeight: root.iconSize/1.5
            Layout.alignment: Qt.AlignHCenter
            source: "arrow-up-double"
        }

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            source: "start-here-kde-plasma"
        }
    }
}
