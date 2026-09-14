/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick

import org.kde.kirigami as Kirigami

FooterDefault {
    finishText: i18nc("@action:button", "E&xit Safe Mode…")
    finishIconName: LayoutMirroring.enabled ? "system-log-out-rtl-symbolic" : "system-log-out-symbolic"
    quitOnFinish: false
    onFinishClicked: pageStack.layers.push(app._createPage("ExitSafeMode.qml"))
}
