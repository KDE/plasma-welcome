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
import org.kde.kcmutils as KCMUtils

import org.kde.plasma.welcome as Welcome

Welcome.Page {
    heading: i18nc("@info:window", "Keyboard Shortcuts")

    actions: [
        Kirigami.Action {
            icon.name: "preferences-desktop-keyboard-shortcut"
            text: i18nc("@action:button", "Configure Shortcuts…")
            onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_keys")
        }
    ]

    description: Welcome.Utils.isMac()
        ? xi18nc("@info:usagetip", "Almost anything in Plasma can be done with the keyboard, using shortcuts that mostly involve the <shortcut>Meta</shortcut> key.<nl/><nl/>On a Mac keyboard, this is the “Command” key:")
        : xi18nc("@info:usagetip", "Almost anything in Plasma can be done with the keyboard, using shortcuts that mostly involve the <shortcut>Meta</shortcut> key.<nl/><nl/>This key is usually located between the left <shortcut>Ctrl</shortcut> and <shortcut>Alt</shortcut> keys, and contains either a symbol of some kind, or the word “Super:”")

    topContent: [
        Item {
            id: keyboard

            readonly property int keySpacing: Kirigami.Units.largeSpacing
            readonly property int topAndBottomMargins: Kirigami.Units.gridUnit

            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: topAndBottomMargins
            Layout.bottomMargin: topAndBottomMargins

            implicitWidth: pcKeyboardLayout.visible? pcKeyboardLayout.implicitWidth : macKeyboardLayout.implicitWidth
            implicitHeight: pcKeyboardLayout.visible? pcKeyboardLayout.implicitHeight : macKeyboardLayout.implicitHeight

            // Generic PC keyboard layout, since they're almost all the same on the left
            // side of the space bar
            RowLayout {
                id: pcKeyboardLayout

                visible: !Welcome.Utils.isMac()

                spacing: keyboard.keySpacing

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
                        ["icon:start-here-kde-symbolic", true],
                        ["icon:preferences-system-linux", false],
                        [i18nc("The typical label for the keyboard's Meta key", "Super"), true],
                    ]
                    property int currentSymbolIndex: 0

                    label: symbols[currentSymbolIndex][0]
                    iconIsMask: symbols[currentSymbolIndex][1]
                    highlighted: true


                    QQC2.ToolTip.text: i18nc("This is a terrible dad joke about the meta key on the keyboard being able to have many symbols. Translate it into one of similar groanworthiness if this is possible; if not, translate it as an empty string.", "I never meta key I didn't like")
                    QQC2.ToolTip.visible: QQC2.ToolTip.text.trim().length > 0 && metaKeyHoverHandler.hovered
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
                    Layout.preferredWidth: Math.round(implicitWidth * 1.5)
                    label: i18nc("The typical label for the keyboard's Alt key", "Alt")
                }
            }

            // Mac keyboard layout, since it's appreciably different and we can detect it
            RowLayout {
                id: macKeyboardLayout

                visible: Welcome.Utils.isMac()

                spacing: keyboard.keySpacing

                MockKey {
                    label: i18nc("The actual translated label for 'fn' on a Mac keyboard", "fn")
                    subLabel: "🌐"
                }
                MockKey {
                    label: "^"
                    subLabel: i18nc("The actual translated label for 'control' on a Mac keyboard", "control")
                }
                MockKey {
                    label: "⌥"
                    subLabel: i18nc("The actual translated label for 'option' on a Mac keyboard", "option")
                }
                MockKey {
                    // Layout.preferredWidth: Math.round(implicitWidth * 1.5)
                    label: "⌘"
                    subLabel: i18nc("The actual translated label for 'command' on a Mac keyboard", "command")
                    highlighted: true
                }
            }
        },

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: xi18nc("@info:usagetip", "What can you do with the <shortcut>Meta</shortcut> key? Here are a few examples:\
<list><item>Press it: Open the Application Launcher widget</item>\
<item>Press <shortcut>Meta+[arrow keys]</shortcut>: Tile window to screen edges or corners</item>\
<item>Press <shortcut>Meta+[number keys]</shortcut>: Launch pinned Task Manager apps</item>\
<item>Press <shortcut>Meta+R</shortcut>: Start a screen recording</item>\
<item>Press <shortcut>Meta+L</shortcut>: Lock the screen</item>\
<item>Press <shortcut>Meta+Shift+S</shortcut>: Toggle screen reader on/off</item>\
<item>Press <shortcut>Meta+Alt+P</shortcut>: Move keyboard focus to panel</item>\
<item>Press <shortcut>Meta+Esc</shortcut>: Launch System Monitor app</item>\
<item>Press <shortcut>Meta+.</shortcut>: Launch Emoji Selector app</item>\
<item>Press <shortcut>Meta+D</shortcut>: Show the desktop</item></list>")
        }
    ]

    component MockKey: Rectangle {
        id: key

        property string label: ""
        property string subLabel: ""
        property bool iconIsMask: false
        property bool highlighted: false

        readonly property bool labelIsIcon: label.startsWith("icon:")
        readonly property string iconName: labelIsIcon ? label.replace("icon:", ""): ""

        readonly property int keySize: Kirigami.Units.gridUnit * 3
        readonly property int keyIconSize: Kirigami.Units.iconSizes.medium

        implicitWidth: Math.max(keySize,
                                mainLabel.implicitWidth + (symbolContainer.anchors.margins * 2),
                                secondaryLabel.implicitWidth + (secondaryLabel.anchors.margins * 2))
        implicitHeight: keySize

        radius: Kirigami.Units.cornerRadius

        // Hardcode dark colors because:
        // 1. Most keyboard keys these days are black or at least dark
        // 2. Reversing colors such that there are bright white keys when using a dark
        //    theme looks weird
        color: "#232323"
        border.color: highlighted ? "deepskyblue" : "black"
        border.width: highlighted ? 2 : 1

        Item {
            id: symbolContainer

            anchors.fill: parent
            anchors.margins: Welcome.Utils.isMac() ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing

            QQC2.Label {
                id: mainLabel

                anchors {
                    fill: Welcome.Utils.isMac() ? undefined : parent
                    top: Welcome.Utils.isMac() ? parent.top : undefined
                    right: Welcome.Utils.isMac() ? parent.right : undefined
                }

                visible: opacity > 0
                opacity: key.labelIsIcon ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}

                text: key.labelIsIcon ? "" : key.label
                // Show single-character symbols as large as icons
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * (text.length > 1 || Welcome.Utils.isMac() ? 1 : 2)
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Kirigami.Icon {
                anchors.centerIn: parent
                width: key.keyIconSize
                height: key.keyIconSize

                visible: opacity > 0
                opacity: key.labelIsIcon ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }}

                source: key.iconName
                animated: true
                isMask: key.iconIsMask
                color: "white"
            }
        }

        QQC2.Label {
            id: secondaryLabel

            anchors {
                bottom: parent.bottom
                left: parent.left
                margins: Kirigami.Units.smallSpacing
            }

            visible: text.length > 0

            text: key.subLabel
            color: "white"
        }
    }
}
