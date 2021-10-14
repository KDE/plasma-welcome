import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami

Kirigami.Page {
    title: i18n("Knowing your Desktop")

    ColumnLayout {
        width: parent.width - (Kirigami.Units.gridUnit * 4)
        Kirigami.Heading {
            Layout.fillWidth: true
            text: i18n("System Tray")
            wrapMode: Text.WordWrap
            type: Kirigami.Heading.Primary
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Connect to your WiFi network; change the volume; switch to the next song or pause a video; access an external device; change the screen layout. All these and a lot more–directly from the system tray. To conserve the focus on what you’re currently doing, any icon can be hidden if you like. Inactive icons hide themselves unless you tell them to stay where they are.")
            wrapMode: Text.WordWrap
        }
    }

    Image {
        id: image
        anchors.fill: parent
        anchors.topMargin: Kirigami.Units.gridUnit * 7
        fillMode: Image.PreserveAspectFit
        source: "systemtray.png"
    }
}
