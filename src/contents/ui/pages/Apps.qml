import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

Kirigami.Page {
    title: i18n("Managing Software")

    ColumnLayout {
        width: parent.width - (Kirigami.Units.gridUnit * 4)
        Kirigami.Heading {
            Layout.fillWidth: true
            text: i18n("Popular Applications")
            wrapMode: Text.WordWrap
            type: Kirigami.Heading.Primary
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Here are some applications to help you be more productive and creative.")
            wrapMode: Text.WordWrap
        }
    }

    GridLayout {
        anchors.centerIn: parent
        columns: 5
        columnSpacing: Kirigami.Units.largeSpacing * 4
        rowSpacing: Kirigami.Units.largeSpacing * 4

        Repeater {
            model: ListModel {
                ListElement { name: "Krita"; appstream: "org.kde.krita"; icon: "org.kde.krita" }
                ListElement { name: "Blender"; appstream: "org.blender.Blender"; icon: "blender" }
                ListElement { name: "Inkscape"; appstream: "org.inkscape.Inkscape"; icon: "inkscape" }
                ListElement { name: "VLC"; appstream: "org.videolan.VLC"; icon: "vlc" }
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
}
