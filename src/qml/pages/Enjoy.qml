/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@ooutlook.com>
 *  SPDX-FileCopyrightText: 2024 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.Page {
    id: root

    heading: i18nc("@title:window", "Enjoy It!")
    description: xi18nc("@info:usagetip", "We hope you love Plasma as much as we loved making it for you! Now it’s time to jump right in. Explore its features, install your favorite apps and games, and get busy doing what makes you you!")

    topContent: [
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@label:URL", "Learn more about the KDE community")
            url: "https://community.kde.org/Welcome_to_KDE?source=plasma-welcome"
        },
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@label:URL", "Get help at KDE’s discussion forums")
            url: "https://discuss.kde.org/?source=plasma-welcome" // TODO: Discuss probably doesn't consume analytics or atleast in this way?
        }
    ]

    actions: [
        Kirigami.Action {
            icon.name: "favorite-symbolic"
            text: i18nc("@action:button", "Supporting Members")
            onTriggered: pageStack.layers.push(supporters)
        }
    ]

    Component {
        id: supporters

        Supporters {}
    }

    ColumnLayout {
        anchors.fill: parent

        spacing: root.padding

        Image {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 25

            fillMode: Image.PreserveAspectFit
            mipmap: true
            source: "konqi-default.png"
        }

        Private.ContributionCard {
            Layout.fillWidth: true
        }
    }
}
