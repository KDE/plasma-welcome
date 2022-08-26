import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

import org.kde.welcome 1.0

GenericPage {
    heading: i18nc("@info:window", "Tweaking your System")
    description: i18nc("@info:usagetip", "System Settings let's you tweak your system to your liking. From Wi-Fi to Theme options, you can find everything here.")

    Kirigami.Icon {
        id: image
        anchors.centerIn: parent
        width: Kirigami.Units.gridUnit * 10
        height: Kirigami.Units.gridUnit * 10
        source: "systemsettings"

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: Controller.open("systemsettings")
        }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 1
            radius: 20
            samples: 20
            color: Qt.rgba(0, 0, 0, 0.2)
        }
    }

    Kirigami.Heading {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: image.bottom
        text: i18nc("@title the name of the 'System Settings' app", "System Settings")
        wrapMode: Text.WordWrap
        level: 3
    }
}
