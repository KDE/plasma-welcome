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

Kirigami.Page {
    id: page

    required property string heading
    required property string description
    property alias topContent: layout.children
    property int margins: Kirigami.Units.gridUnit * 2
    leftPadding: margins
    rightPadding: margins

    header: Item {

        height: layout.implicitHeight + page.margins * 2

        ColumnLayout {
            id: layout

            width: parent.width - (page.margins * 2)
            anchors.centerIn: parent

            Kirigami.Heading {
                Layout.fillWidth: true
                text: page.heading
                wrapMode: Text.WordWrap
                type: Kirigami.Heading.Primary
            }

            QQC2.Label {
                Layout.fillWidth: true
                text: page.description
                wrapMode: Text.WordWrap
            }
        }
    }
}
