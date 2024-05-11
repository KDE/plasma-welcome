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

ColumnLayout {
    id: root

    readonly property string description: xi18nc("@info:usagetip", "KDE contributors have spent the last four months hard at work on this release. We hope you enjoy using Plasma as much as we enjoyed making it!")

    readonly property string updateTitle: "The As-Yet Untitled Update"
    readonly property string updateDescription: "Plasma 6.1 is out and brings massive improvements to the desktop and all its tools. Another work of love from KDE developers and contributors."

    spacing: Kirigami.Units.gridUnit

    QQC2.Button {
        Layout.fillWidth: true
        Layout.fillHeight: true

        leftPadding: Kirigami.Units.smallSpacing
        rightPadding: Kirigami.Units.smallSpacing
        topPadding: Kirigami.Units.smallSpacing
        bottomPadding: Kirigami.Units.smallSpacing

        onClicked: Qt.openUrlExternally(Controller.releaseUrl)

        contentItem: MockDesktop {
            backgroundAlignment: Qt.AlignCenter
            blurRadius: 64

            Rectangle {
                anchors.fill: parent

                // Matches with the overview effect
                opacity: 0.7
                color: Kirigami.Theme.backgroundColor
            }

            RowLayout {
                id: updateRow
                anchors.fill: parent
                anchors.topMargin: Kirigami.Units.gridUnit
                anchors.bottomMargin: Kirigami.Units.gridUnit

                spacing: Kirigami.Units.gridUnit

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    id: iconContainer
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: implicitWidth

                    readonly property bool shouldBeVisible: Kirigami.Units.iconSizes.enormous < parent.width / 4

                    // For some reason, this animates at the start,
                    // but it actually looks good so let's keep it.
                    implicitWidth: shouldBeVisible ? Kirigami.Units.iconSizes.enormous : 0
                    implicitHeight: Kirigami.Units.iconSizes.enormous
                    Behavior on implicitWidth {
                        PropertyAnimation {
                            easing.type: Easing.InOutQuad
                            duration: Kirigami.Units.longDuration
                        }
                    }
                    visible: implicitWidth > 0

                    Kirigami.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        implicitWidth: Kirigami.Units.iconSizes.enormous
                        implicitHeight: Kirigami.Units.iconSizes.enormous
                        source: "start-here-kde-plasma"

                        opacity: iconContainer.shouldBeVisible ? 1 : 0
                        Behavior on opacity {
                            PropertyAnimation {
                                easing.type: Easing.InOutQuad
                                duration: Kirigami.Units.longDuration
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillHeight: true
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 24

                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.Heading {
                        id: title
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true

                        level: 1
                        maximumLineCount: 1
                        elide: Text.ElideRight
                        text: root.updateTitle
                    }

                    Kirigami.Heading {
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        Layout.maximumHeight: updateRow.height - parent.spacing - title.height

                        level: 2
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        text: root.updateDescription
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }

    Kirigami.AbstractCard {
        Layout.fillWidth: true

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            QQC2.Label {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: xi18nc("@info:usagetip", "The KDE community relies on donations of expertise and funds, and is supported by KDE e.V.—a German nonprofit. Donations to KDE e.V. support the wider KDE community, and you can make a difference by donating today.")
            }

            Kirigami.UrlButton {
                text: i18nc("@action:button", "Make a donation")
                url: "https://kde.org/community/donations?source=plasma-welcome"
            }

            Kirigami.UrlButton {
                text: i18nc("@action:button", "Help work on the next release")
                url: "https://community.kde.org/Get_Involved?source=plasma-welcome"
            }
        }
    }
}
