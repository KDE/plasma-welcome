import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtGraphicalEffects 1.15

GenericPage {
    title: i18n("Knowing your Desktop")

    heading: i18n("KDE Plasma")
    description: i18n("Use Plasma to surf the web; keep in touch with colleagues, friends and family; manage your files, enjoy music and videos; and get creative and productive at work. Do it all in a beautiful environment that adapts to your needs, and with the safety, privacy-protection and peace of mind that the best Free Open Source Software has to offer.")

    Image {
        id: image
        anchors.centerIn: parent
        height: Kirigami.Units.gridUnit * 22
        source: "plasma.webp"
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
