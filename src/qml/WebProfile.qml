/*
 *  SPDX-FileCopyrightText: 2026 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

pragma Singleton

import QtQuick
import QtWebEngine

Item {
    id: root

    function instance(): WebEngineProfile {
        return profilePrototype.instance();
    }

    WebEngineProfilePrototype {
        id: profilePrototype
        storageName: ""
        persistentStoragePath: ""
        cachePath: ""
        httpCacheType: WebEngineProfile.MemoryHttpCache
        persistentCookiesPolicy: WebEngineProfile.NoPersistentCookies
        persistentPermissionsPolicy: WebEngineProfile.StoreInMemory
    }
}
