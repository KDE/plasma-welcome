/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QJSValue>
#include <QQmlEngine>

// org.kde.plasma.welcome, Utils
// Provides utility functionality for Welcome Center, intended for distro pages

class Utils : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    Utils(QObject *parent = nullptr);

    Q_INVOKABLE void launchApp(const QString &program);
    Q_INVOKABLE void runCommand(const QString &command, QJSValue callback = QJSValue());
    Q_INVOKABLE void copyToClipboard(const QString &content) const;
};
