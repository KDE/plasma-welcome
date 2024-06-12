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

ColumnLayout {
    id: root

    readonly property string description: xi18nc("@info:usagetip", "KDE contributors have spent the last four months hard at work on this release. We hope you enjoy using Plasma as much as we enjoyed making it!")
    readonly property int iconSize: Kirigami.Units.iconSizes.enormous

    readonly property list<QtObject> topContent: [
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "<b>Find out what's new</b>")
            url: Controller.releaseUrl
        },
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Help work on the next release")
            url: "https://community.kde.org/Get_Involved?source=plasma-welcome"
        }
    ]

    spacing: Kirigami.Units.gridUnit

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillHeight: true
        Layout.maximumHeight: Number.POSITIVE_INFINITY

        spacing: Kirigami.Units.gridUnit

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

    ContributionCard {
        Layout.fillWidth: true
    }
}
