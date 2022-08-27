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
import QtGraphicalEffects 1.15

Kirigami.Page {
    id: page

    property string heading: ""
    property string description: ""
    property alias topContent: layout.children
    leftPadding: Kirigami.Units.gridUnit * 2
    rightPadding: Kirigami.Units.gridUnit * 2

    header: Item {
        id: headerContainer

        property int headerMargins: Kirigami.Units.gridUnit * 2

        visible: page.description.length > 0 && page.heading.length > 0
        height: visible ? layout.implicitHeight + headerMargins * 2 : 0

        ColumnLayout {
            id: layout

            width: parent.width - (headerContainer.headerMargins * 2)
            anchors.centerIn: parent

            Kirigami.Heading {
                Layout.fillWidth: true
                visible: page.heading.length > 0
                text: page.heading
                wrapMode: Text.WordWrap
                type: Kirigami.Heading.Primary
            }

            QQC2.Label {
                Layout.fillWidth: true
                visible: page.description.length > 0
                text: page.description
                wrapMode: Text.WordWrap
            }
        }
    }
}
