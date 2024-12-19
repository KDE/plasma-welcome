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

import org.kde.plasma.welcome as Welcome

ColumnLayout {
    id: root

    readonly property string description: xi18nc("@info:usagetip", "KDE contributors have spent the last four months hard at work on this release. We hope you enjoy using Plasma as much as we enjoyed making it!")
    readonly property int iconSize: Kirigami.Units.iconSizes.enormous

    readonly property list<QtObject> topContent: [
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Help work on the next release")
            url: "https://community.kde.org/Get_Involved?source=plasma-welcome"
        }
    ]

    Component.onCompleted: {
        Welcome.Release.tryAutomaticPreview();
    }

    spacing: Kirigami.Units.gridUnit

    Welcome.MockCard {
        id: card
        Layout.fillWidth: true
        Layout.fillHeight: true

        readonly property bool ready: Welcome.Release.previewStatus === Welcome.Release.Loaded

        focusPolicy: Qt.TabFocus
        showClickFeedback: ready
        hoverEnabled: ready

        onClicked: {
            if (ready) {
                Qt.openUrlExternally(Welcome.Release.announcementUrl);
            }
        }

        applyPlasmaColors: false
        backgroundAlignment: Qt.AlignHCenter | Qt.AlignVCenter
        blurRadius: 64

        Rectangle {
            anchors.fill: parent

            opacity: 0.7 // Same as overview underlay
            color: {
                // Tint, 0.3 and 0.1 taken from Kirigami private/DefaultCardBackground
                let tintFactor;
                if (card.showClickFeedback && (card.down || card.highlighted)) {
                    tintFactor = 0.3;
                } else if (card.hoverEnabled && card.hovered) {
                    tintFactor = 0.1;
                } else {
                    tintFactor = 0;
                }

                // Tint multiplied by 1/opacity to account for loss in intensity due to opacity
                return Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor,
                                                         Kirigami.Theme.highlightColor,
                                                         tintFactor * (1 / opacity));
            }
        }

        Item {
            id: releasePreview
            anchors.fill: parent
            anchors.margins: Kirigami.Units.gridUnit

            opacity: card.ready ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                PropertyAnimation {
                    easing.type: Easing.InOutQuad
                    duration: Kirigami.Units.longDuration
                }
            }

            RowLayout {
                anchors.fill: parent

                spacing: Kirigami.Units.gridUnit

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    id: releasePreviewIconContainer
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: implicitWidth

                    // Only show if using no more than a quarter of the available width
                    readonly property bool show: {
                        if (releasePreview.width < 0) {
                            // Initially, it'll be negative
                            return true;
                        }
                        return Kirigami.Units.iconSizes.enormous <= (releasePreview.width / 4);
                    }

                    implicitWidth: show ? Kirigami.Units.iconSizes.enormous : 0
                    implicitHeight: Kirigami.Units.iconSizes.enormous
                    opacity: show ? 1 : 0
                    visible: opacity > 0

                    Behavior on implicitWidth {
                        PropertyAnimation {
                            easing.type: Easing.InOutQuad
                            duration: Kirigami.Units.longDuration
                        }
                    }

                    Behavior on opacity {
                        PropertyAnimation {
                            easing.type: Easing.InOutQuad
                            duration: Kirigami.Units.longDuration
                        }
                    }

                    Kirigami.Icon {
                        anchors.verticalCenter: releasePreviewIconContainer.verticalCenter
                        anchors.right: releasePreviewIconContainer.right

                        implicitWidth: Kirigami.Units.iconSizes.enormous
                        implicitHeight: Kirigami.Units.iconSizes.enormous
                        source: "start-here-kde-plasma"
                    }
                }

                ColumnLayout {
                    id: releasePreviewTextLayout

                    Layout.alignment: Qt.AlignCenter
                    Layout.fillHeight: true
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 24

                    Kirigami.Heading {
                        id: title
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true

                        level: 1
                        maximumLineCount: 1
                        elide: Text.ElideRight
                        text: Welcome.Release.previewTitle
                    }

                    Kirigami.Heading {
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        Layout.maximumHeight: releasePreviewIconContainer.height - parent.spacing - title.height

                        level: 2
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        text: Welcome.Release.previewDescription
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            QQC2.Label {
                id: releasePreviewHint
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                // Only show if there's a grid unit between it and the text
                readonly property bool show: {
                    if (releasePreview.height < 0) {
                        // Initially, it'll be negative
                        return true;
                    }
                    return (releasePreviewTextLayout.y + releasePreviewTextLayout.height) <= (releasePreview.height - Kirigami.Units.gridUnit - height);
                }

                text: i18nc("@info", "<b>Click to read the announcement</b>") // TODO: Better context, @info:something

                anchors.bottomMargin: show ? 0 : (height + Kirigami.Units.gridUnit * 2) * -1
                opacity: show ? 0.6 : 0
                visible: opacity > 0

                Behavior on anchors.bottomMargin {
                    PropertyAnimation {
                        easing.type: Easing.InOutQuad
                        duration: Kirigami.Units.longDuration
                    }
                }

                Behavior on opacity {
                    PropertyAnimation {
                        easing.type: Easing.InOutQuad
                        duration: Kirigami.Units.longDuration
                    }
                }
            }
        }

        Kirigami.LoadingPlaceholder {
            anchors.centerIn: parent

            opacity: (Welcome.Release.previewStatus == Welcome.Release.Loading && !releasePreviewPlaceholderTimer.running) ? 1 : 0
            visible: opacity > 0

            Timer {
                id: releasePreviewPlaceholderTimer

                interval: Kirigami.Units.humanMoment
                running: true
            }

            Behavior on opacity {
                PropertyAnimation {
                    easing.type: Easing.InOutQuad
                    duration: Kirigami.Units.longDuration
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
        }
    }
}
