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
            text: i18n("KDE Plasma")
            wrapMode: Text.WordWrap
            type: Kirigami.Heading.Primary
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Use Plasma to surf the web; keep in touch with colleagues, friends and family; manage your files, enjoy music and videos; and get creative and productive at work. Do it all in a beautiful environment that adapts to your needs, and with the safety, privacy-protection and peace of mind that the best Free Open Source Software has to offer.")
            wrapMode: Text.WordWrap
        }
    }
}
