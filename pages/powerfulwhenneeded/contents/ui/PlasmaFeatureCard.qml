/*
 *   SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    id: root

    required property string page
    required property string title
    required property string subtitle
    required property string buttonIcon

    property bool read: false

    readonly property int implicitTitleWidth: metrics.width
    readonly property int fixedSizeStuff: icon.implicitWidth + leftPadding + rightPadding + unreadContainer.width  + titleRowLayout.spacing * 2

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing

    hoverEnabled: true
    showClickFeedback: true

    TextMetrics {
        id: metrics
        text: root.title
        font.pointSize: title.font.pointSize
    }

    onClicked: {
        pageStack.layers.push(app._createPage(root.page));
        root.read = true;
    }

    contentItem: ColumnLayout {
        spacing: 0

        RowLayout {
            id: titleRowLayout

            spacing: Kirigami.Units.smallSpacing
            Layout.minimumHeight: Kirigami.Units.gridUnit * 2 + spacing

            // Icon
            Kirigami.Icon {
                id: icon
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                Layout.alignment: Qt.AlignVCenter
                source: root.buttonIcon
            }
            // Title
            Kirigami.Heading {
                id: title
                Layout.fillWidth: true
                level: 4
                text: root.title
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 2
                elide: Text.ElideRight
                wrapMode: Text.Wrap
            }
            // Unread indicator
            Item {
                id: unreadContainer
                Layout.preferredHeight: parent.height
                // Essentially, we want a square for the child to center within, but with
                // the empty space to the left removed such that the title has more room
                Layout.preferredWidth: ((height - unreadIndicator.implicitWidth) / 2) + unreadIndicator.implicitWidth

                Rectangle {
                    id: unreadIndicator
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left

                    implicitWidth: Kirigami.Units.largeSpacing
                    implicitHeight: Kirigami.Units.largeSpacing

                    opacity: root.read ? 0 : 1
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.InOutQuad }}

                    radius: implicitWidth * 0.5
                    color: Kirigami.Theme.activeTextColor
                }
            }
        }

        // Subtitle
        QQC2.Label {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.subtitle
            text: root.subtitle
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            opacity: 0.6
            verticalAlignment: Text.AlignTop
        }
    }
}
