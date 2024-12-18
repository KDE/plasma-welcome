/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <singleton.h>

// org.kde.plasma.welcome, Distro
// Provides distro information for Welcome Center

class Distro : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    WELCOME_SINGLETON(Distro)

    QString name() const;
    QString icon() const;
    QString url() const;
    QString bugReportUrl() const;

    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString icon READ icon CONSTANT)
    Q_PROPERTY(QString url READ url CONSTANT)
    Q_PROPERTY(QString bugReportUrl READ bugReportUrl CONSTANT)

private:
    Distro(QObject *parent = nullptr);
};
