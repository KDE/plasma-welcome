/*
 *   SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Kirigami.Card {
    id: root

    required property string title
    required property string subtitle
    required property string buttonIcon
    readonly property int implicitTitleWidth: metrics.width
    readonly property int fixedSizeStuff: icon.implicitWidth + leftPadding + rightPadding + titleRowLayout.spacing

    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing

    Layout.maximumHeight: implicitHeight

    TextMetrics {
        id: metrics
        text: root.title
    }

    showClickFeedback: true

    actions: [
        Kirigami.Action {
            text: qsTr("Learn more...")
            onTriggered: root.clicked()
        }
    ]

    banner {
        titleIcon: root.buttonIcon
        title: root.title
    }

    // Subtitle
    contentItem: QQC2.Label {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.subtitle
        text: root.subtitle
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignTop
    }
}
