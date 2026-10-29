/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QObject>
#include <QUrl>
#include <qqmlintegration.h>

class SafeModeCacheClearer;

// org.kde.plasma.welcome.private, SafeMode
// Provides back-end functionality to power the Safe Mode flow for plasma-welcome
class SafeMode : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool actuallyInSafeMode READ actuallyInSafeMode CONSTANT)
    Q_PROPERTY(SafeModeCacheClearer *cacheClearer READ cacheClearer CONSTANT)

public:
    SafeMode(QObject *parent = nullptr);

    bool actuallyInSafeMode() const;

    SafeModeCacheClearer *cacheClearer();

private:
    SafeModeCacheClearer *m_cacheClearer = nullptr;
    bool m_actuallyInSafeMode = false;
};
