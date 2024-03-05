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

Kirigami.Page {
    id: page

    required property string heading
    required property string description

    property alias topContent: topContentLayout.children

    readonly property int margins: Kirigami.Units.gridUnit

    title: heading
    topPadding: 0 // Provided by required header
    leftPadding: margins
    rightPadding: margins
    bottomPadding: margins

    header: Item {
        height: layout.implicitHeight + (page.margins * 2)

        ColumnLayout {
            id: layout
            width: parent.width - (page.margins * 2)
            anchors.centerIn: parent

            QQC2.Label {
                Layout.fillWidth: true
                text: page.description
                wrapMode: Text.WordWrap
            }

            ColumnLayout {
                id: topContentLayout
                visible: children.count > 0
            }
        }
    }
}
