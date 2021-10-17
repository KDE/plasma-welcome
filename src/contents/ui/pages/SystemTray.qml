import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

GenericPage {
    title: i18n("Knowing your Desktop")

    heading: i18n("System Tray")
    description: i18n("Connect to your WiFi network; change the volume; switch to the next song or pause a video; access an external device; change the screen layout. All these and a lot more–directly from the system tray. To conserve the focus on what you’re currently doing, any icon can be hidden if you like. Inactive icons hide themselves unless you tell them to stay where they are.")

    Image {
        id: image
        anchors.centerIn: parent
        height: Kirigami.Units.gridUnit * 22
        source: "systemtray.png"
        fillMode: Image.PreserveAspectFit
    }

    DropShadow {
        anchors.fill: image
        source: image
        horizontalOffset: 0
        verticalOffset: 5
        radius: 20
        samples: 20
        color: Qt.rgba(0, 0, 0, 0.25)
    }
}
