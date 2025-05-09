/*
 *  SPDX-FileCopyrightText: 2025 Kristen McWilliam <kristen@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.Page {
    id: root

    heading: i18nc("@title:window", "Create user account")
    description: xi18nc("@info:usagetip", "Choose the username and password for your computer's account.")

    Kirigami.FormLayout {
        anchors.centerIn: parent
        // anchors.margins: Kirigami.Units.largeSpacing

        QQC2.TextField {
            id: nameField
            Kirigami.FormData.label: i18nc("The user's actual name", "Name")
        }

        QQC2.TextField {
            id: usernameField
            Kirigami.FormData.label: i18nc("The desired username for the new account", "Username")
            validator: RegularExpressionValidator {
                regularExpression: /^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$/
            }
        }

        Kirigami.PasswordField {
            id: passwordField
            Kirigami.FormData.label: i18nc("The password for the new account", "Password")
        }

        Kirigami.PasswordField {
            id: passwordConfirmField
            Kirigami.FormData.label: i18nc("Confirm the password was typed correctly", "Confirm Password")
        }
    }
}
