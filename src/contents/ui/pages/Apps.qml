import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

GenericPage {
    title: i18n("Managing Software")

    heading: i18n("Popular Applications")
    description: i18n("Here are some applications to help you be more productive and creative.")

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
}
