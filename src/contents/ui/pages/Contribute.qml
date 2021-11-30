import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

GenericPage {
    heading: i18n("Get Involved")
    description: i18n("Welcome to the KDE Community! By joining our team, you will be part of an international effort by thousands of people working to deliver a stunning Free Software computing experience. You will meet new friends, learn new skills and make a difference to millions of users while working with people from all around the globe. This page will give you a brief introduction to things everyone in KDE should know, and help you get started with contributing.")

    topContent: [
        QQC2.Button {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18n("Start Contributing")
            onClicked: Qt.openUrlExternally("https://community.kde.org/Get_Involved")
        }
    ]

    Image {
        id: image
        anchors.centerIn: parent
        height: Kirigami.Units.gridUnit * 20
        fillMode: Image.PreserveAspectFit
        source: "konqi-build.png"
    }
}
