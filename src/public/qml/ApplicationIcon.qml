/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome

QQC2.ToolButton {
    id: root

    required property var application
    required property int size

    icon.name: application.icon ?? "unknown"
    text: application.name ?? ""

    onClicked: Welcome.Utils.launchApp(application.desktopName)

    contentItem: ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            Layout.preferredWidth: root.size
            Layout.preferredHeight: root.size
            source: root.icon.name
        }

        Kirigami.Heading {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Kirigami.Units.gridUnit
            text: root.text
            wrapMode: Text.WordWrap
            level: 3
        }

    }

    QQC2.ToolTip.visible: hovered
    QQC2.ToolTip.text: i18nc("@action:button", "Launch %1 now", text)
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
}
