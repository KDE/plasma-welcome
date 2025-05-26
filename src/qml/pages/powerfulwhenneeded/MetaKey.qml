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
            text: i18nc("@action:button", "See more Keyboard Shortcuts…")
            onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_keys")
        }
    ]

    description: xi18nc("@info:usagetip", "Almost anything in Plasma can be done with the keyboard, using shortcuts that mostly involve the <shortcut>Meta</shortcut> key.<nl/><nl/>This key is usually located between the left <shortcut>Ctrl</shortcut> and <shortcut>Alt</shortcut> keys, and shows a symbol of some kind on it, or else the word “Super:”")

    topContent: [
        MockKeyboard {
            readonly property int topAndBottomMargins: Kirigami.Units.gridUnit * 2

            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: topAndBottomMargins
            Layout.bottomMargin: topAndBottomMargins
        },

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: xi18nc("@info:usagetip", "What can you do with the <shortcut>Meta</shortcut> key? Here are a few examples:\
<list><item>Press it: Open the “Kickoff” Application Launcher widget</item>\
<item>Press <shortcut>Meta+[arrow keys]</shortcut>: Tile window to screen edges or corners</item>\
<item>Press <shortcut>Meta+[number keys]</shortcut>: Launch pinned Task Manager apps</item>\
<item>Press <shortcut>Meta+R</shortcut>: Start a screen recording</item>\
<item>Press <shortcut>Meta+L</shortcut>: Lock the screen</item>\
<item>Press <shortcut>Meta+Shift+S</shortcut>: Toggle screen reader on/off</item>\
<item>Press <shortcut>Meta+Alt+P</shortcut>: Move keyboard focus to panel</item>\
<item>Press <shortcut>Meta+Esc</shortcut>: Launch System Monitor app</item>\
<item>Press <shortcut>Meta+.</shortcut>: Launch Emoji Selector app</item>\
<item>Press <shortcut>Meta+D</shortcut>: Show the desktop</item>\
<item>…And much more!</item></list>")
        }
    ]
}
