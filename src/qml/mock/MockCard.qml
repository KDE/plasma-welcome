/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

import org.kde.plasma.welcome.private as Private

Kirigami.AbstractCard {
    id: root

    default property alias children: container.children

    property bool applyPlasmaColors: true
    property int backgroundAlignment: Qt.AlignRight | Qt.AlignBottom
    property double backgroundScale: 1
    property int blurRadius: 32

    readonly property string wallpaper: "file:" + Private.App.installPrefix + "/share/wallpapers/Next/contents/images/1920x1080.png"
    readonly property int desktopWidth: 1024 * backgroundScale
    readonly property int desktopHeight: 576 * backgroundScale

    /*
     * 1024x576 is chosen to look good at normal window sizes: The aspect matches
     * most desktops (16:9) and the usual proportions of the mock as shown in the
     * window.
     *
     * The background will be positioned according to the alignment, and expand to
     * fit when the mock exceeds its size. Depending on the effect wanted, content
     * can exceed the size to show a region of the desktop, such as corner for a
     * panel's tray.
     */

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: root.background.borderWidth

        layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
        layer.effect: Kirigami.ShadowedTexture {
            radius: Kirigami.Units.cornerRadius - root.background.borderWidth
        }

        clip: true

        // Use Plasma theme colours, rather than Kirigami's
        Kirigami.Theme.inherit: !root.applyPlasmaColors
        Kirigami.Theme.textColor: root.applyPlasmaColors ? PlasmaCore.Theme.textColor : undefined
        Kirigami.Theme.activeTextColor: root.applyPlasmaColors ? PlasmaCore.Theme.activeTextColor : undefined
        Kirigami.Theme.highlightColor: root.applyPlasmaColors ? PlasmaCore.Theme.highlightColor : undefined
        Kirigami.Theme.backgroundColor: root.applyPlasmaColors ? PlasmaCore.Theme.backgroundColor : undefined

        Image {
            id: wallpaperImage
            anchors.left: (root.backgroundAlignment & Qt.AlignLeft) ? parent.left : undefined
            anchors.right: (root.backgroundAlignment & Qt.AlignRight) ? parent.right: undefined
            anchors.horizontalCenter: (root.backgroundAlignment & Qt.AlignHCenter) ? parent.horizontalCenter : undefined
            anchors.top: (root.backgroundAlignment & Qt.AlignTop) ? parent.top : undefined
            anchors.bottom: (root.backgroundAlignment & Qt.AlignBottom) ? parent.bottom : undefined
            anchors.verticalCenter: (root.backgroundAlignment & Qt.AlignVCenter) ? parent.verticalCenter : undefined

            layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
            layer.effect: MultiEffect {
                autoPaddingEnabled: false
                blurEnabled: blurMax > 0
                blur: 1.0
                blurMax: root.blurRadius * root.backgroundScale
            }

            width: Math.max(root.width, root.desktopWidth)
            height: Math.max(root.height, root.desktopHeight)

            fillMode: Image.PreserveAspectCrop
            source: root.wallpaper
        }
    }
}
