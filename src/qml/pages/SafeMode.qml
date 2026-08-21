/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.Page {
    id: root

    heading: i18nc("@title", "This is a Safe Mode session")
    description: xi18nc("@info:usagetip", "Safe Mode is meant to help you troubleshoot your session, so you can log into a regular KDE Plasma session again.")

    actions: [
        Kirigami.Action {
            text: i18nc("@action:inmenu", "About Welcome Center")
            icon.name: "start-here-kde-plasma"
            onTriggered: pageStack.layers.push(aboutAppPage)
            displayHint: Kirigami.DisplayHint.AlwaysHide
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "About KDE")
            icon.name: "kde"
            onTriggered: pageStack.layers.push(aboutKDEPage)
            displayHint: Kirigami.DisplayHint.AlwaysHide
        }
    ]

    Component {
        id: aboutKDEPage

        FormCard.AboutKDEPage {}
    }

    Component {
        id: aboutAppPage

        FormCard.AboutPage {}
    }

    topContent: [
        Kirigami.UrlButton {
            id: plasmaLink
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Visit the KDE Discuss community forums")
            url: "https://discuss.kde.org"
        }/*,
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button %1", "Open your user configuration directory in Dolphin")
            url: "file:///"
        }*/
    ]

    ColumnLayout {
        id: introImage

        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Kirigami.Units.iconSizes.enormous * 2
            implicitHeight: implicitWidth
            source: "dialog-warning"
        }

        QQC2.Label {
            Layout.fillWidth: true

            text: xi18nc("@info:usagetip", "In a Safe Mode session, your usual desktop and application settings are ignored. If your settings were causing problems during startup, they should not cause problems here. All of your settings were preserved; they will be used again when you return to regular KDE Plasma.<nl/><nl/>You can use this session to back up your data, or to reset user customizations for your next login.")
            wrapMode: Text.WordWrap
        }
    }
}
