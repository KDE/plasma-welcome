/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemodecacheclearer.h"

#include <KDirWatch>
#include <KIO/DeleteJob>
#include <KIO/OpenUrlJob>
#include <KJob>

#include <QDir>
#include <QStandardPaths>
#include <QtEnvironmentVariables>

#include "welcome_debug.h"

namespace
{
QString withoutTrailingSlash(const QByteArray &path)
{
    return path.length() > 1 && path.endsWith('/') ? path.chopped(1) : path;
}
} // anonymous namespace

SafeModeCacheClearer::SafeModeCacheClearer(QObject *parent)
    : QObject(parent)
{
    m_cacheDir = withoutTrailingSlash(qgetenv("KDE_SAFEMODE_ORIG_XDG_CACHE_HOME"));

    // Clearing the cache is safe, assuming apps don't do stupid race-conditiony things.
    // Allow the user to clear the cache of the currently running non-Safe-Mode session.
    if (m_cacheDir.isEmpty()) {
        m_cacheDir = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation);
    }

    if (!m_cacheDir.isEmpty()) {
        KDirWatch::self()->addDir(m_cacheDir);
        QObject::connect(KDirWatch::self(), &KDirWatch::created, this, &SafeModeCacheClearer::cacheDirExistsChanged);
        QObject::connect(KDirWatch::self(), &KDirWatch::deleted, this, &SafeModeCacheClearer::cacheDirExistsChanged);
    }
}

SafeModeCacheClearer::~SafeModeCacheClearer()
{
    if (!m_cacheDir.isEmpty()) {
        KDirWatch::self()->removeDir(m_cacheDir);
    }
}

QUrl SafeModeCacheClearer::cacheDir() const
{
    return m_cacheDir.isEmpty() ? QUrl() : QUrl::fromLocalFile(m_cacheDir);
}

bool SafeModeCacheClearer::cacheDirExists() const
{
    return m_cacheDir.isEmpty() ? false : QDir(m_cacheDir).exists();
}

SafeModeCacheClearer::Completion SafeModeCacheClearer::completion() const
{
    return m_completion;
}

QString SafeModeCacheClearer::errorString() const
{
    return m_errorString;
}

void SafeModeCacheClearer::resetCompletion()
{
    m_completion = Completion::NotStarted;
    m_errorString = QString();
    Q_EMIT completionChanged();
    Q_EMIT errorStringChanged();
    Q_EMIT cacheDirExistsChanged(); // doesn't hurt to check again
}

void SafeModeCacheClearer::openCacheDir()
{
    if (m_cacheDir.isEmpty()) {
        return;
    }
    auto job = new KIO::OpenUrlJob(QUrl::fromLocalFile(m_cacheDir));
    QObject::connect(job, &KJob::result, this, [this](KJob *openJob) {
        if (openJob->error()) {
            qCWarning(WELCOME_LOG) << "Could not open cache dir:" << openJob->errorString();
        }
    });
    job->start();
}

void SafeModeCacheClearer::clearCache()
{
    resetCompletion();

    if (m_cacheDir.isEmpty()) {
        qCWarning(WELCOME_LOG) << "Didn't clear user cache dir: directory path not set";
        return;
    }

    auto job = KIO::del(QUrl::fromLocalFile(m_cacheDir));

    QObject::connect(job, &KJob::result, this, [this](const KJob *job) {
        if (job->error()) {
            m_errorString = job->errorString();
            m_completion = Completion::Error;
            Q_EMIT errorStringChanged();
            qCWarning(WELCOME_LOG) << "Error clearing cache:" << job->errorString();
        } else {
            m_completion = Completion::Success;
            Q_EMIT cacheDirExistsChanged(); // just in case inotify hates us
        }
        Q_EMIT completionChanged();
    });
    job->start();
}

#include "moc_safemodecacheclearer.cpp"
