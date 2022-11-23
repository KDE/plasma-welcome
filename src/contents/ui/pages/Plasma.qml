/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

import org.kde.welcome 1.0
import org.kde.plasma.welcome 1.0

GenericPage {
    id: root

    heading: i18nc("@title:window", "Make It Your Own")
    description: xi18nc("@info:usagetip","Plasma is made of widgets: little modules that can be configured, removed, or exchanged for completely different ones! It's easy to adapt Plasma to your needs and workflows.")

    AnimatedImage {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 4
        width: Kirigami.Units.gridUnit * 14
        height: Kirigami.Units.gridUnit * 14
        source: "widgets.gif"
        playing: root.activeFocus

        QQC2.Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: Kirigami.Units.largeSpacing
            width: Math.round(parent.width * 0.75)
            text: i18nc("@info", "You can use the built-in widgets as well as community-made ones.")
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
