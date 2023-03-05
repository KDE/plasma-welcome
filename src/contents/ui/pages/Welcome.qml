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
import org.kde.plasma.welcome 1.0

GenericPage {
    heading: i18nc("@title", "Welcome to KDE Plasma!")
    description: xi18nc("@info:usagetip", "Plasma is a free and open-source desktop environment created by KDE, an international software community of volunteers. The Plasma desktop environment is simple by default for a smooth experience, but powerful when needed to help you really get things done. We hope you love it!")

    topContent: [
        Kirigami.UrlButton {
            id: link
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Learn more about the KDE community")
            url: "https://community.kde.org/Welcome_to_KDE?source=plasma-welcome"
        }
    ]

    ColumnLayout {
        anchors.centerIn: parent
        height: Math.min(parent.height, Kirigami.Units.gridUnit * 17)
        spacing: Kirigami.Units.smallSpacing

        Image {
            id: konqiImage

            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            source: "konqi-kde-hi.png"
            fillMode: Image.PreserveAspectFit

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

        QQC2.Label {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: Math.round(konqiImage.implicitWidth / 2)
            text: i18nc("@info", "The KDE mascot Konqi welcomes you to the KDE community!")
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
