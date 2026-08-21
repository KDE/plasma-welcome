/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QObject>
#include <QUrl>
#include <qqmlregistration.h>

class KDirWatch;
class KJob;

class SafeModeFixes : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("access via Private.App.safeModeFixes instead")

    Q_PROPERTY(QUrl origCacheDir READ origCacheDir CONSTANT FINAL)
    Q_PROPERTY(bool origCacheDirExists READ origCacheDirExists NOTIFY origCacheDirExistsChanged FINAL)

public:
    SafeModeFixes(QObject *parent = nullptr);

    QUrl origCacheDir() const;
    bool origCacheDirExists() const;

    Q_SCRIPTABLE void clearCache();

    Q_SCRIPTABLE void logOut();

Q_SIGNALS:
    void origCacheDirExistsChanged();

private:
    void addOrigDirWatches();
    void removeOrigDirWatches();
    void setOrigDirExists(const QString &path, bool exists);

private:
    QString m_origDataDir;
    QString m_origConfigDir;
    QString m_origStateDir;
    QString m_origCacheDir;
    KDirWatch *m_origDirWatch;
    bool m_origCacheDirExists = false;
};
