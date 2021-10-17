import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

GenericPage {
    title: i18n("Managing Software")

    heading: i18n("Discover")
    description: i18n("Discover helps you find and install applications, games, and tools. You can search or browse by category, and look at screenshots and read reviews to help you pick the perfect app.")

    Image {
        id: image
        anchors.centerIn: parent
        height: Kirigami.Units.gridUnit * 22
        source: "discover.png"
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
