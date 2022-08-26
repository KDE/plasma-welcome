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

Kirigami.Page {
    ColumnLayout {
        anchors.centerIn: parent

        Image {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 16
            source: "konqi-kde-hi.png"
            fillMode: Image.PreserveAspectFit
        }
        QQC2.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: i18nc("@info:placeholder", "Welcome to KDE Plasma")
            font.pixelSize: 25
        }
    }
}
