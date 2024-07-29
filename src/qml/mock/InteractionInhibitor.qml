/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick

MouseArea {
    anchors.fill: parent
    z: 1000 // Ensure we are on top of our siblings

    // Eat mouse events (hover, click, scroll)
    acceptedButtons: Qt.AllButtons
    hoverEnabled: true
    onWheel: wheel => wheel.accepted = true

    function setRecursiveFocusPolicy(item, excludeParent = false) {
        if (!excludeParent) {
            item.childrenChanged.connect(() => setRecursiveFocusPolicy(item, true));

            item.focusPolicy = Qt.NoFocus;
            item.activeFocusOnTab = false;
        }

        for (var i = 0; i < item.children.length; ++i) {
            setRecursiveFocusPolicy(item.children[i]);
        }
    }

    // Disable tab navigation for parent and all children (including future children)
    Component.onCompleted: setRecursiveFocusPolicy(parent)
}
