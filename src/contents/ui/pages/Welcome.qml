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
import org.kde.plasma.welcome 1.0

GenericPage {
    heading: i18nc("@title", "Welcome to KDE Plasma!")
    description: xi18nc("@info:usagetip", "KDE Plasma is a free and open-source desktop environment made by volunteers around the globe. It's simple by default for a smooth experience, but powerful when needed to help you really get things done.<nl/><nl/>Welcome to the KDE Community!")

    Image {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 4
        width: Kirigami.Units.gridUnit * 16
        height: Kirigami.Units.gridUnit * 16
        source: "konqi-kde-hi.png"
        fillMode: Image.PreserveAspectFit

        QQC2.Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            text: i18nc("@info", "Konqi, the KDE mascot")
        }
    }
}
