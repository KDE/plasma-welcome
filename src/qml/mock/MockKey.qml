/*
 *  SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Rectangle {
    id: root

    property string label: ""
    property bool iconIsMask: false
    property bool highlighted: false

    readonly property bool labelIsIcon: label.startsWith("icon:")
    readonly property string iconName: labelIsIcon ? label.replace("icon:", ""): ""

    readonly property int keySize: Kirigami.Units.gridUnit * 3
    readonly property int keyIconSize: Kirigami.Units.iconSizes.medium

    implicitWidth: Math.max(keySize, innerLabel.implicitWidth + (innerLabel.anchors.margins * 2))
    implicitHeight: keySize

    radius: Kirigami.Units.cornerRadius

    // Hardcode dark colors because:
    // 1. Most keyboard keys these days are black or at least dark
    // 2. Reversing colors such that there are bright white keys when using a dark
    //    theme looks weird
    color: "#232323"
    border.color: highlighted ? "deepskyblue" : "black"
    border.width: highlighted ? 2 : 1

    QQC2.Label {
        id: innerLabel

        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        visible: opacity > 0
        opacity: root.labelIsIcon ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}

        text: root.labelIsIcon ? "" : root.label
        // Show single-character symbols as large as icons
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * (text.length === 1 ? 2 : 1)
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Kirigami.Icon {
        anchors.centerIn: parent
        width: root.keyIconSize
        height: root.keyIconSize

        visible: opacity > 0
        opacity: root.labelIsIcon ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}

        source: root.iconName
        animated: true
        isMask: root.iconIsMask
        color: "white"
    }
}
