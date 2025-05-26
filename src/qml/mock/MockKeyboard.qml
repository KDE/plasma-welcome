/*
 *  SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

RowLayout {
    spacing: Kirigami.Units.largeSpacing

    MockKey {
        label: i18nc("The typical label for the keyboard's Ctrl key", "Ctrl")
    }
    MockKey {
        label: i18nc("The typical label for the keyboard's Function key", "Fn")
    }
    MockKey {
        id: metaKey

        property var symbols: [
            // Icon name, symbol, or label     If it's an icon, treat it as a mask?
            ["icon:applications-all-symbolic", true],
            ["⌘", true],
            ["icon:start-here", false],
            ["icon:preferences-system-linux", false],
            ["icon:start-here-kde-symbolic", true],
            [i18nc("The typical label for the keyboard's Meta key", "Super"), true],
        ]
        property int currentSymbolIndex: 0

        label: symbols[currentSymbolIndex][0]
        iconIsMask: symbols[currentSymbolIndex][1]
        highlighted: true


        QQC2.ToolTip.text: i18nc("This is a terrible dad joke about the meta key on the keyboard being able to have many symbols. Translate it into one of similar groanworthiness if this is possible; if not, translate it as an empty string.", "I never meta key I didn't like")
        QQC2.ToolTip.visible: QQC2.ToolTip.text.length > 0 && metaKeyHoverHandler.hovered
        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

        HoverHandler {
            id: metaKeyHoverHandler
        }

        Timer {
            interval: Kirigami.Units.humanMoment
            running: true
            repeat: true
            onTriggered: {
                if (metaKey.currentSymbolIndex === metaKey.symbols.length - 1) {
                    metaKey.currentSymbolIndex = 0;
                } else {
                    metaKey.currentSymbolIndex++;
                }
            }
        }
    }
    MockKey {
        label: i18nc("The typical label for the keyboard's Alt key", "Alt")
        Layout.preferredWidth: Math.round(implicitWidth * 1.5)
    }
}
