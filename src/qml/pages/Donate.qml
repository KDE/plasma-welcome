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
import org.kde.plasma.welcome

GenericPage {
    heading: i18nc("@title:window", "Support Your Freedom")
    description: xi18nc("@info:usagetip", "The KDE community relies on donations of expertise and funds, and is supported by KDE e.V.--a German nonprofit that manages legal matters, funds development sprints and server resources, and offers employment opportunities for KDE developers. Donations to KDE e.V. support the wider KDE community, and you can make a difference by donating today!<nl/><nl/>Donations are tax-deductible in Germany.")

    topContent: [
        Kirigami.UrlButton {
            id: link
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Make a donation")
            url: "https://kde.org/community/donations?source=plasma-welcome"
        }
    ]

    Image {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Kirigami.Units.gridUnit
        width: Math.min (parent.width, Kirigami.Units.gridUnit * 25)
        fillMode: Image.PreserveAspectFit
        mipmap: true
        source: "konqi-donations.png"

        HoverHandler {
            id: hoverhandler
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: Qt.openUrlExternally(link.url)
        }
        QQC2.ToolTip {
            visible: hoverhandler.hovered
            text: i18nc("@action:button clicking on this takes the user to a web page", "Visit %1", link.url)
        }
    }

    actions: [
        Kirigami.Action {
            icon.name: "favorite-symbolic"
            text: i18nc("@action:button", "Supporting Members")
            onTriggered: pageStack.layers.push(supporters)
        }
    ]

    Supporters {
        id: supporters
    }
}
