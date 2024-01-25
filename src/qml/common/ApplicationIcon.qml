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
import Qt5Compat.GraphicalEffects

import org.kde.plasma.welcome

ColumnLayout {
    id: root

    required property var application
    required property int size

    Kirigami.Icon {
        id: image
        Layout.preferredWidth: root.size
        Layout.preferredHeight: root.size
        source: application.icon ?? "unknown"

        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: Controller.launchApp(application.desktopName)
        }

        QQC2.ToolTip {
            visible: hoverHandler.hovered
            text: i18nc("@action:button", "Launch %1 now", application.name ?? "")
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
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: Kirigami.Units.gridUnit
        text: application.name ?? ""
        wrapMode: Text.WordWrap
        level: 3
    }
}
