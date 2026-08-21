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

    title: i18nc("@title", "Exit Safe Mode")

    ColumnLayout {
        id: columnLayout

        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing * 2

        Item {
            Layout.fillHeight: true
        }

        QQC2.Label {
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            text: xi18nc("@info:usagetip", "After logging out of Safe Mode, return to your regular Plasma session.<nl/><nl/>If you fixed it, great!<nl/>If not, come back and try something else.")
            wrapMode: Text.Wrap
        }

        QQC2.Button {
            Layout.alignment: Qt.AlignHCenter
            text: i18nc("@action:button", "Log Out Now")
            icon.name: LayoutMirroring.enabled ? "system-log-out-rtl-symbolic" : "system-log-out-symbolic"
            onClicked: Private.App.safeModeFixes.logOut()
        }

        Image {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 25
            Layout.maximumHeight: columnLayout.height * 3/5

            fillMode: Image.PreserveAspectFit
            mipmap: true
            source: "konqi-safemode.png"
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
