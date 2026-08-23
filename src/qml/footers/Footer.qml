/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Item {
    id: footer

    required property string contentSource

    height: footerToolBar.implicitHeight

    QQC2.ToolBar {
        id: footerToolBar
        anchors.left: footer.left
        anchors.right: footer.right

        position: QQC2.ToolBar.Footer

        implicitHeight: footerLoader.implicitHeight + footerLoader.anchors.topMargin + footerLoader.anchors.bottomMargin

        contentItem: Loader {
            id: footerLoader
            anchors.fill: parent
            anchors.margins: Kirigami.Units.mediumSpacing

            source: footer.contentSource
        }

        /*
         * Behave like a header, as it frames the page more nicely. This is done by setting colorSet and manually
         * providing window dragging, rather than relying on theme or abusing AbstractApplicationHeader.
         */

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Header

        DragHandler {
            target: null
            grabPermissions: PointerHandler.TakeOverForbidden | PointerHandler.ApprovesTakeOverByAnything
            onActiveChanged: {
                if (active) {
                    footerToolBar.Window.window.startSystemMove();
                }
            }
        }
    }
}
