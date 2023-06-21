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
import Qt5Compat.GraphicalEffects

import org.kde.plasma.welcome 1.0

ColumnLayout {
    id: root

    required property string application
    required property int size

    ApplicationInfo {
        id: appInfo
        desktopName: root.application
    }

    Kirigami.Icon {
        id: image
        Layout.preferredWidth: root.size
        Layout.preferredHeight: root.size
        source: appInfo.icon

        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: Controller.launchApp(appInfo.desktopName)
        }

        QQC2.ToolTip {
            visible: hoverHandler.hovered
            text: i18nc("@action:button", "Launch %1 now", appInfo.name)
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
        text: appInfo.name
        wrapMode: Text.WordWrap
        level: 3
    }
}
