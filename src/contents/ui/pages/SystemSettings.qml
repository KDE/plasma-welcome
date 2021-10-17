import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

GenericPage {
    title: i18n("Tweaking your System")

    heading: i18n("System Settings")
    description: i18n("System Settings let's you tweak your system to your liking. From Wi-Fi to Theme options, you can find everything here.")

    Image {
        id: image
        anchors.centerIn: parent
        height: Kirigami.Units.gridUnit * 22
        source: "systemsettings.png"
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
