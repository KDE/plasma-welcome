/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemodefixes.h"

#include <KDirWatch>
#include <KIO/DeleteJob>
#include <KJob>
#include <kworkspace6/sessionmanagement.h>

#include <QDir>
#include <QtEnvironmentVariables>

#include "welcome_debug.h"

namespace
{
QString withoutTrailingSlash(const QByteArray &path)
{
    return path.length() > 1 && path.endsWith('/') ? path.chopped(1) : path;
}
} // anonymous namespace

SafeModeFixes::SafeModeFixes(QObject *parent)
    : QObject(parent)
    , m_origDirWatch(new KDirWatch(this))
{
    m_origDataDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_DATA_HOME"));
    m_origConfigDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_CONFIG_HOME"));
    m_origStateDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_STATE_HOME"));
    m_origCacheDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_CACHE_HOME"));

    QObject::connect(m_origDirWatch, &KDirWatch::created, this, [this](const QString &path) {
        setOrigDirExists(path, true);
    });
    QObject::connect(m_origDirWatch, &KDirWatch::deleted, this, [this](const QString &path) {
        setOrigDirExists(path, false);
    });
    addOrigDirWatches();
}

QUrl SafeModeFixes::origCacheDir() const
{
    return m_origCacheDirExists ? QUrl() : QUrl::fromLocalFile(m_origCacheDir);
}

bool SafeModeFixes::origCacheDirExists() const
{
    return m_origCacheDirExists;
}

void SafeModeFixes::clearCache()
{
    if (m_origCacheDir.isEmpty()) {
        qCWarning(WELCOME_LOG) << "Didn't clear user cache dir (not in Safe Mode)";
        return;
    }
    auto job = KIO::del(QUrl::fromLocalFile(m_origCacheDir));
    job->start();
}

void SafeModeFixes::logOut()
{
    static SessionManagement *sessionManagement = new SessionManagement();
    sessionManagement->requestLogout(SessionManagement::ConfirmationMode::Skip);
}

void SafeModeFixes::addOrigDirWatches()
{
    for (const QString &path : {m_origConfigDir, m_origStateDir, m_origDataDir, m_origCacheDir}) {
        if (!path.isEmpty()) {
            m_origDirWatch->addDir(path);
            setOrigDirExists(path, QDir(path).exists());
        }
    }
}

void SafeModeFixes::removeOrigDirWatches()
{
    for (const QString &path : {m_origConfigDir, m_origStateDir, m_origDataDir, m_origCacheDir}) {
        if (!path.isEmpty()) {
            m_origDirWatch->removeDir(path);
            setOrigDirExists(path, false); // even if it does exist, we can't know about it now
        }
    }
}

void SafeModeFixes::setOrigDirExists(const QString &path, bool exists)
{
    if (path == m_origCacheDir) {
        m_origCacheDirExists = exists;
        Q_EMIT origCacheDirExistsChanged();
    }
}

#include "moc_safemodefixes.cpp"
