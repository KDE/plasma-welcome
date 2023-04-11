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

import org.kde.plasma.welcome 1.0

ColumnLayout {
    id: root

    required property int size
    required property string source

    signal tapped()
    property alias title: title.text
    property alias toolTip: toolTip.text

    Kirigami.Icon {
        id: image
        Layout.preferredWidth: root.size
        Layout.preferredHeight: root.size
        source: root.source

        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            id: tapHandler
            onTapped: root.tapped()
        }

        QQC2.ToolTip {
            id: toolTip
            visible: hoverHandler.hovered && text
        }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 1
            radius: 20
            samples: 20
            color: Qt.rgba(0, 0, 0, 0.2)
        }
    }

    Kirigami.Heading {
        id: title
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: Kirigami.Units.gridUnit
        wrapMode: Text.WordWrap
        level: 3
        visible: text
    }
}
