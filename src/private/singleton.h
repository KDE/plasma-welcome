/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QQmlEngine>

#include "plasma-welcome-private_export.h"

#define WELCOME_SINGLETON(c) friend class Singleton<c>;

template<typename T>
class PLASMA_WELCOME_PRIVATE_EXPORT Singleton
{
public:
    static T *instance()
    {
        static T instance;
        return &instance;
    };

    static T *create(QQmlEngine *engine, QJSEngine *jsEngine)
    {
        Q_UNUSED(engine);
        Q_UNUSED(jsEngine);
        QJSEngine::setObjectOwnership(instance(), QJSEngine::CppOwnership);
        return instance();
    };
};
