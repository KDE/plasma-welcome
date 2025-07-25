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
import org.kde.kirigamiaddons.formcard as FormCard

import org.kde.plasma.welcome as Welcome
import org.kde.plasma.welcome.private as Private

Welcome.Page {
    id: root

    heading: i18nc("@title", "Welcome")
    description: Private.App.customIntroText.length > 0
            ? xi18nc("@info:usagetip %1 is custom text supplied by the distro", "%1<nl/><nl/>This operating system is running Plasma, a free and open-source desktop environment created by KDE, an international software community of volunteers. It is designed to be simple by default for a smooth experience, but powerful when needed to help you really get things done. We hope you love it!", Private.App.customIntroText)
            : xi18nc("@info:usagetip %1 is the name of the user's distro", "Welcome to the %1 operating system running KDE Plasma!<nl/><nl/>Plasma is a free and open-source desktop environment created by KDE, an international software community of volunteers. It is designed to be simple by default for a smooth experience, but powerful when needed to help you really get things done. We hope you love it!", Welcome.Distro.name)

    actions: [
        Kirigami.Action {
            text: i18nc("@action:inmenu", "About Welcome Center")
            icon.name: "start-here-kde-plasma"
            onTriggered: pageStack.layers.push(aboutAppPage)
            displayHint: Kirigami.DisplayHint.AlwaysHide
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "About KDE")
            icon.name: "kde"
            onTriggered: pageStack.layers.push(aboutKDEPage)
            displayHint: Kirigami.DisplayHint.AlwaysHide
        }
    ]

    Component {
        id: aboutKDEPage

        FormCard.AboutKDEPage {}
    }

    Component {
        id: aboutAppPage

        FormCard.AboutPage {}
    }

    topContent: [
        Kirigami.UrlButton {
            id: plasmaLink
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Learn more about the KDE community")
            url: "https://community.kde.org/Welcome_to_KDE?source=plasma-welcome"
        },
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button %1 is the name of the user's distro", "Learn more about %1", Welcome.Distro.name)
            url: Welcome.Distro.homeUrl
            visible: Welcome.Distro.homeUrl.length > 0
        }
    ]

    QQC2.AbstractButton {
        id: konqiButton

        anchors.centerIn: parent
        height: Math.min(root.height, Kirigami.Units.gridUnit * 17)

        property string url: Private.App.customIntroIconLink || plasmaLink.url

        text: Private.App.customIntroIconCaption || i18nc("@info", "The KDE mascot Konqi welcomes you to the KDE community!")

        onClicked: Qt.openUrlExternally(url)

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            Loader {
                id: imageContainer

                readonly property bool isImage:
                    // Image path in the file
                    Private.App.customIntroIcon.startsWith("file:/") ||
                    // Our default image
                    Private.App.customIntroIcon.length === 0

                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                Layout.maximumWidth: root.width

                sourceComponent: isImage ? imageComponent : iconComponent

                Component {
                    id: imageComponent

                    Image {
                        id: image
                        source: Private.App.customIntroIcon || "konqi-kde-hi.png"
                        fillMode: Image.PreserveAspectFit

                        Kirigami.PlaceholderMessage {
                            width: root.width - (Kirigami.Units.largeSpacing * 4)
                            anchors.centerIn: parent
                            text: i18nc("@title", "Image loading failed")
                            explanation: xi18nc("@info:placeholder", "Could not load <filename>%1</filename>. Make sure it exists.", Private.App.customIntroIcon)
                            visible: image.status == Image.Error
                        }
                    }
                }

                Component {
                    id: iconComponent

                    Kirigami.Icon {
                        implicitWidth: Kirigami.Units.iconSizes.enormous * 2
                        implicitHeight: implicitWidth
                        source: Private.App.customIntroIcon || "kde"
                    }
                }

                HoverHandler {
                    id: hoverhandler
                    cursorShape: Qt.PointingHandCursor
                }

                QQC2.ToolTip {
                    visible: hoverhandler.hovered
                    text: i18nc("@action:button clicking on this takes the user to a web page", "Visit %1", konqiButton.url)
                }
            }

            QQC2.Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: Math.round(Math.max(root.width / 2, imageContainer.implicitWidth / 2))
                text: konqiButton.text
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
