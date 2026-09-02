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

import org.kde.plasma.welcome.private as Private

Kirigami.Page {
    id: root

    title: i18nc("@title", "Clear Cache Files")

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing * 2

        QQC2.Label {
            Layout.fillWidth: true
            text: xi18nc("@info:usagetip", "Plasma, system services, and applications create cache files to help with performance.<nl/><nl/>After clearing cache files, they will be automatically regenerated when needed. Your customizations remain unchanged.<nl/><nl/>Clearing your cache is a safe and easy attempt to fix a session. Often the problem lies elsewhere, but it doesn't hurt to try.")
            wrapMode: Text.Wrap
        }

        QQC2.Button {
            Layout.alignment: Qt.AlignHCenter
            text: i18nc("@action:button", "Clear Cache Files")
            icon.name: "edit-clear-all"
            enabled: Private.App.safeModeFixes.origCacheDirExists
            onClicked: Private.App.safeModeFixes.clearCache()
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: !Private.App.safeModeFixes.origCacheDirExists
            text: i18nc("@info:usagetip", "Your cache has been cleared.")
            type: Kirigami.MessageType.Positive
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
