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
    description: xi18nc("@info:usagetip", "KDE contributors have spent the last four months hard at work on this release, and we hope you'll love it!")

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
        }
    ]

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 2
        spacing: Kirigami.Units.largeSpacing *2

        RowLayout {
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
        QQC2.Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 12
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: i18nc("@info caption", "We hope you enjoy using Plasma as much as we enjoyed making it!")
        }
    }
}
