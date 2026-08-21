/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

RowLayout {
    id: root

    spacing: Kirigami.Units.smallSpacing

    readonly property bool inLayer: pageStack.layers.depth > 1
    readonly property bool atStart: pageStack.currentIndex === 0
    readonly property bool atEnd: pageStack.currentIndex === pageStack.depth - 1

    readonly property string skipText: i18nc("@action:button", "&Skip")
    readonly property string backText: i18nc("@action:button", "&Back")
    readonly property string nextText: i18nc("@action:button", "&Next")
    readonly property string finishText: i18nc("@action:button", "&Finish")

    function removeAccelerator(string: string): string {
        return string.replace(/&(&|[a-zA-Z0-9])/g, m => m[1] === '&' ? '&' : m[1])
    }

    TextMetrics {
        id: skipMetrics
        font: prevButton.font
        text: root.removeAccelerator(root.skipText)
    }

    TextMetrics {
        id: backMetrics
        font: prevButton.font
        text: root.removeAccelerator(root.backText)
    }

    TextMetrics {
        id: nextMetrics
        font: prevButton.font
        text: root.removeAccelerator(root.nextText)
    }

    TextMetrics {
        id: finishMetrics
        font: prevButton.font
        text: root.removeAccelerator(root.finishText)
    }

    // Help ensure a constant width for the navigation buttons despite changing text
    // NOTE: width is incorrect, advanceWidth is correct
    readonly property int buttonTextWidth: Math.ceil(Math.max(skipMetrics.advanceWidth, backMetrics.advanceWidth,
                                                              nextMetrics.advanceWidth, finishMetrics.advanceWidth))

    QQC2.Button {
        id: prevButton
        Layout.alignment: Qt.AlignLeft
        Layout.preferredWidth: (leftPadding === 0 || rightPadding === 0 || spacing === 0) ? -1 : leftPadding + icon.width + spacing + root.buttonTextWidth + rightPadding

        action: Kirigami.Action {
            readonly property bool isSkip: root.atStart && !root.inLayer

            text: isSkip ? root.skipText : root.backText
            icon.name: {
                if (isSkip) {
                    return "dialog-cancel-symbolic";
                } else if (Qt.application.layoutDirection === Qt.LeftToRight) {
                    "go-previous-symbolic"
                } else {
                    "go-previous-rtl-symbolic"
                }
            }
            shortcut: Qt.application.layoutDirection === Qt.LeftToRight ? "Left" : "Right"

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
        Layout.preferredWidth: (leftPadding === 0 || rightPadding === 0 || spacing === 0) ? -1 : leftPadding + icon.width + spacing + root.buttonTextWidth + rightPadding

        // Nicer to have the arrow on the side it's pointing to
        LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.LeftToRight ? !root.atEnd : root.atEnd

        enabled: !root.inLayer

        action: Kirigami.Action {
            text: root.atEnd ? root.finishText : root.nextText
            icon.name: {
                if (root.atEnd) {
                    return "dialog-ok-apply-symbolic";
                } else if (Qt.application.layoutDirection === Qt.LeftToRight) {
                    "go-next-symbolic"
                } else {
                    "go-next-rtl-symbolic"
                }
            }
            shortcut: Qt.application.layoutDirection === Qt.LeftToRight ? "Right" : "Left"

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
