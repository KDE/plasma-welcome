import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

Kirigami.Page {
    id: page

    property string heading: undefined
    property string description: undefined
    property alias image: image
    property bool imageShadow: true
    property alias topContent: layout.children

    leftPadding: Kirigami.Units.gridUnit * 3
    rightPadding: Kirigami.Units.gridUnit * 3

    ColumnLayout {
        id: layout
        width: parent.width - (Kirigami.Units.gridUnit * 4)
        Kirigami.Heading {
            Layout.fillWidth: true
            text: heading
            wrapMode: Text.WordWrap
            type: Kirigami.Heading.Primary
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: description
            wrapMode: Text.WordWrap
        }
    }

    Image {
        id: image
        anchors.centerIn: parent
        height: Kirigami.Units.gridUnit * 22
        fillMode: Image.PreserveAspectFit
    }

    DropShadow {
        anchors.fill: imageShadow ? image : undefined
        source: imageShadow ? image : undefined
        horizontalOffset: 0
        verticalOffset: 1
        radius: 10
        samples: 20
        color: Qt.rgba(0, 0, 0, 0.1)
    }

    DropShadow {
        anchors.fill: imageShadow ? image : undefined
        source: imageShadow ? image : undefined
        horizontalOffset: 0
        verticalOffset: 4
        radius: 16
        samples: 20
        color: Qt.rgba(0, 0, 0, 0.12)
    }

    DropShadow {
        anchors.fill: imageShadow ? image : undefined
        source: imageShadow ? image : undefined
        horizontalOffset: 0
        verticalOffset: 40
        radius: 60
        samples: 20
        color: Qt.rgba(0, 0, 0, 0.12)
    }

    DropShadow {
        anchors.fill: imageShadow ? image : undefined
        source: imageShadow ? image : undefined
        horizontalOffset: 0
        verticalOffset: 80
        radius: 120
        samples: 20
        color: Qt.rgba(0, 0, 0, 0.06)
    }
}
