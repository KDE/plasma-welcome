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
import org.kde.plasma.welcome.private as Private

ColumnLayout {
    id: root

    readonly property string description: xi18nc("@info:usagetip", "KDE contributors have spent the last four months hard at work on this release. We hope you enjoy using Plasma as much as we enjoyed making it!")

    Component.onCompleted: Welcome.Release.tryAutomaticPreview()

    spacing: Kirigami.Units.gridUnit

    Welcome.MockCard {
        id: card
        Layout.fillWidth: true
        Layout.fillHeight: true

        // Prevent initial state from being immediately
        // applied so the animations will run
        property bool ready: false
        Component.onCompleted: ready = true

        states: [
            State {
                name: "None"
                when: !card.ready
            },
            State {
                name: "Loading"
                when: Welcome.Release.previewStatus === Welcome.Release.Loading
            },
            State {
                name: "Loaded"
                when: Welcome.Release.previewStatus === Welcome.Release.Loaded
            },
            State {
                name: "Error"
                when: Welcome.Release.previewError !== Welcome.Release.None
            },
            State {
                name: "Unloaded"
                when: Welcome.Release.previewStatus === Welcome.Release.Unloaded
            }
        ]

        focusPolicy: card.state === "Loaded" ? Qt.TabFocus : Qt.NoFocus
        showClickFeedback: card.state === "Loaded"
        hoverEnabled: card.state === "Loaded"

        onClicked: {
            if (card.state === "Loaded") {
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
                // Tint values taken from kirigamiaddons.formcard's FormDelegateBackground
                let tintFactor;
                if (card.showClickFeedback && card.pressed) {
                    tintFactor = 0.2;
                } else if (card.visualFocus) {
                    tintFactor = 0.1;
                } else if (card.hoverEnabled && !Kirigami.Settings.tabletMode && card.hovered) {
                    tintFactor = 0.07;
                } else {
                    tintFactor = 0;
                }

                // Tint multiplied by 1/opacity to account for loss in intensity due to opacity
                return Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor,
                                                         Kirigami.Theme.highlightColor,
                                                         tintFactor * (1 / opacity));
            }

            Behavior on color {
                ColorAnimation {
                    duration: Kirigami.Units.shortDuration
                }
            }
        }

        Item {
            id: releasePreview
            anchors.fill: parent
            anchors.margins: Kirigami.Units.gridUnit

            layer.enabled: true
            opacity: card.state === "Loaded" ? 1 : 0
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
                        if (!releasePreview.visible) {
                            return false;
                        }
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
                    if (!releasePreview.visible) {
                        return false;
                    }
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
            id: releasePreviewLoading
            anchors.centerIn: parent

            Timer {
                id: releasePreviewLoadingTimer

                interval: Kirigami.Units.humanMoment
                running: card.state === "Loading"
            }

            opacity: (card.state === "Loading" && !releasePreviewLoadingTimer.running) ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                PropertyAnimation {
                    easing.type: Easing.InOutQuad
                    duration: Kirigami.Units.longDuration
                }
            }
        }

        QQC2.Button {
            id: releasePreviewUnloaded
            anchors.centerIn: parent

            icon.name: "view-refresh-symbolic"
            text: i18nc("@action:button", "Load Preview")
            onClicked: Welcome.Release.getPreview()

            opacity: card.state === "Unloaded" ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                PropertyAnimation {
                    easing.type: Easing.InOutQuad
                    duration: Kirigami.Units.longDuration
                }
            }
        }

        Kirigami.PlaceholderMessage {
            id: releasePreviewError
            anchors.centerIn: parent

            opacity: card.state === "Error" ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                PropertyAnimation {
                    easing.type: Easing.InOutQuad
                    duration: Kirigami.Units.longDuration
                }
            }

            readonly property QtObject retryAction: Kirigami.Action {
                enabled: !releasePreviewErrorRetryTimer.running
                icon.name: "view-refresh-symbolic"
                text: i18nc("@action:button", "Retry")
                onTriggered: {
                    releasePreviewErrorRetryTimer.start();
                    Welcome.Release.getPreview();
                }
            }

            readonly property QtObject announcementAction: Kirigami.Action {
                text: i18nc("@action:button", "Open in browser…")
                onTriggered: Qt.openUrlExternally(Welcome.Release.announcementUrl)
            }

            Timer {
                id: releasePreviewErrorRetryTimer

                interval: Kirigami.Units.humanMoment
            }

            // HACK: PlaceholderMessage will make the button invisible if the
            // action is disabled, but we still want it visible
            Binding {
                target: releasePreviewError.children.find((child) => child instanceof QQC2.Button);
                property: "visible"
                value: true
                when: releasePreviewError.helpfulAction ?? false
            }

            width: parent.width - Kirigami.Units.gridUnit * 2

            type: Kirigami.PlaceholderMessage.Type.Actionable
            text: i18nc("@info", "Failed to load preview")
            explanation: {
                switch (Welcome.Release.previewError) {
                    case Welcome.Release.None:
                    default:
                        return null;
                    case Welcome.Release.Code:
                        return i18nc("@info, %1 is an error code", "A network error occured (%1)").arg(Welcome.Release.previewErrorCode);
                    case Welcome.Release.ParseFailure:
                        return i18nc("@info", "Could not parse preview");
                }
            }
            helpfulAction: {
                switch (Welcome.Release.previewError) {
                    case Welcome.Release.None:
                    default:
                        return null;
                    case Welcome.Release.Code:
                        return retryAction;
                    case Welcome.Release.ParseFailure:
                        return announcementAction;
                }
            }
        }
    }

    Private.ContributionCard {
        Layout.fillWidth: true
    }
}
