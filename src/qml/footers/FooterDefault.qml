/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome

RowLayout {
    id: root

    spacing: Kirigami.Units.smallSpacing

    readonly property bool inLayer: pageStack.layers.depth > 1
    readonly property bool atStart: pageStack.currentIndex === 0
    readonly property bool atEnd: pageStack.currentIndex === pageStack.depth - 1

    QQC2.Button {
        Layout.alignment: Qt.AlignLeft

        action: Kirigami.Action {
            readonly property bool isSkip: root.atStart && !root.inLayer

            text: isSkip ? i18nc("@action:button", "&Skip") : i18nc("@action:button", "&Back")
            icon.name: isSkip ? "dialog-cancel-symbolic" : "go-previous-symbolic"
            shortcut: "Left"

            onTriggered: {
                if (root.inLayer) {
                    pageStack.layers.pop();
                } else if (!root.atStart) {
                    pageStack.currentIndex -= 1;
                } else {
                    Qt.quit();
                }
            }
        }
    }

    QQC2.PageIndicator {
        Layout.alignment: Qt.AlignHCenter

        enabled: !root.inLayer
        count: pageStack.depth
        currentIndex: pageStack.currentIndex
        onCurrentIndexChanged: pageStack.currentIndex = currentIndex
        interactive: true
    }

    QQC2.Button {
        id: nextButton
        Layout.alignment: Qt.AlignRight

        enabled: !root.inLayer

        action: Kirigami.Action {
            text: root.atEnd ? i18nc("@action:button", "&Finish") : i18nc("@action:button", "&Next")
            icon.name: root.atEnd ? "dialog-ok-apply-symbolic" : "go-next-symbolic"
            shortcut: "Right"

            enabled: nextButton.enabled

            onTriggered: {
                if (!root.atEnd) {
                    pageStack.currentIndex += 1;
                } else {
                    Qt.quit();
                }
            }
        }
    }
}
