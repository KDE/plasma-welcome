import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

import org.kde.welcome 1.0

GenericPage {
    title: i18n("Managing Software")

    heading: i18n("Discover")
    description: i18n("Discover helps you find and install applications, games, and tools. You can search or browse by category, and look at screenshots and read reviews to help you pick the perfect app.")

    Kirigami.Icon {
        id: image
        anchors.centerIn: parent
        width: Kirigami.Units.gridUnit * 10
        height: Kirigami.Units.gridUnit * 10
        source: "plasmadiscover"

        QQC2.ToolTip.text: i18n("Open Discover")
        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

        MouseArea {
            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor
            onClicked: Controller.open("plasma-discover")
        }
    }

    GridLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.gridUnit * 3
        columns: 5
        columnSpacing: Kirigami.Units.largeSpacing * 4
        rowSpacing: Kirigami.Units.largeSpacing * 4

        Repeater {
            model: ListModel {
                ListElement { name: "Krita"; appstream: "org.kde.krita"; icon: "org.kde.krita" }
                ListElement { name: "Blender"; appstream: "org.blender.Blender"; icon: "blender" }
                ListElement { name: "Inkscape"; appstream: "org.inkscape.Inkscape"; icon: "inkscape" }
                ListElement { name: "VLC"; appstream: "org.videolan.VLC"; icon: "vlc" }
                ListElement { name: "Gimp"; appstream: "org.gimp.GIMP"; icon: "gimp" }
            }
            delegate: ColumnLayout {
                id: applicationItem
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                    Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                    source: model.icon
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: model.name
                    wrapMode: Text.WordWrap
                }

                MouseArea {
                    width: applicationItem.width
                    height: applicationItem.height

                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.openUrlExternally(`appstream://${model.appstream}`)
                }
            }
        }
    }

    DropShadow {
        anchors.fill: image
        source: image
        horizontalOffset: 0
        verticalOffset: 1
        radius: 10
        samples: 20
        color: Qt.rgba(0, 0, 0, 0.1)
    }

    DropShadow {
        anchors.fill: image
        source: image
        horizontalOffset: 0
        verticalOffset: 4
        radius: 16
        samples: 20
        color: Qt.rgba(0, 0, 0, 0.12)
    }

    DropShadow {
        anchors.fill: image
        source: image
        horizontalOffset: 0
        verticalOffset: 40
        radius: 60
        samples: 20
        color: Qt.rgba(0, 0, 0, 0.12)
    }

    DropShadow {
        anchors.fill: image
        source: image
        horizontalOffset: 0
        verticalOffset: 80
        radius: 120
        samples: 20
        color: Qt.rgba(0, 0, 0, 0.06)
    }
}
