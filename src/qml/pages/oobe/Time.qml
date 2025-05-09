/*
 *  SPDX-FileCopyrightText: 2025 Kristen McWilliam <kristen@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.KCMPage {
    id: kcm_users

    heading: i18nc("@title:window", "Set Timezone")
    description: xi18nc("@info:usagetip", "Choose the timezone for your computer.")

    path: "kcm_clock"
}
