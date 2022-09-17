/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

GenericPage {
    heading: i18nc("@title:window", "Freedom Isn't Free")
    description: xi18nc("@info:usagetip", "KDE operates on a shoestring budget, relying largely on donations of labor and resources. You can help change that!<nl/><nl/>Financial donations help KDE pay for development sprints, hardware and server resources, and expanded employment. Donations are tax-deductible in Germany.")

    topContent: [
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Make a donation")
            url: "https://kde.org/community/donations/"
        }
    ]

    Image {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit * 2
        height: Kirigami.Units.gridUnit * 16
        fillMode: Image.PreserveAspectFit
        source: "konqi.png"
    }
}
