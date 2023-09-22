/*
 *  SPDX-FileCopyrightText: 2023 Joshua Goins <josh@redstrate.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.welcome
import org.kde.kcmutils as KCMUtils

GenericPage {
    id: root

    heading: i18nc("@info:window", "Accessibility")
    description: xi18nc("@info:usagetip", "If you need a screen reader to continue the setup, you can turn it on now. Other settings such as Sticky Keys are located under Accessibility settings, through <application>System Settings</application>.")

    actions: [
        Kirigami.Action {
            icon.name: "preferences-desktop-accessibility"
            text: i18nc("@action:button", "Open Accessibility Settings…")
            onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_access")
        }
    ]

    ColumnLayout {
        anchors.centerIn: parent

        QQC2.Label {
            text: !Controller.orcaAvailable ? i18n("Orca is not currently installed. Please install Orca through Discover and log back in.") : ""
            visible: text.length !== 0

            Layout.alignment: Qt.AlignHCenter
        }
        QQC2.CheckBox {
            text: i18nc("@option:check", "Enable Screen Reader")

            enabled: Controller.orcaAvailable
            checked: Controller.screenReaderEnabled
            onToggled: Controller.screenReaderEnabled = checked

            Layout.alignment: Qt.AlignHCenter
        }
        QQC2.Button {
            text: i18nc("@action:button", "Launch Screen Reader Configuration…")

            enabled: Controller.orcaAvailable
            onClicked: Controller.launchOrcaConfiguration()

            Layout.alignment: Qt.AlignHCenter
        }
    }
}
