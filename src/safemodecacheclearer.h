/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QObject>
#include <QUrl>
#include <qqmlintegration.h>

class SafeModeCacheClearer : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("access via Private.SafeMode.cacheClearer instead")

public:
    enum class Completion {
        NotStarted,
        Error,
        Success,
    };
    Q_ENUM(Completion)

private:
    Q_PROPERTY(QUrl cacheDir READ cacheDir CONSTANT FINAL)
    Q_PROPERTY(bool cacheDirExists READ cacheDirExists NOTIFY cacheDirExistsChanged FINAL)
    Q_PROPERTY(Completion completion READ completion NOTIFY completionChanged FINAL)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged FINAL)

public:
    SafeModeCacheClearer(QObject *parent = nullptr);
    ~SafeModeCacheClearer();

    QUrl cacheDir() const;
    bool cacheDirExists() const;

    Q_SCRIPTABLE void openCacheDir();
    Q_SCRIPTABLE void clearCache();

    Completion completion() const;
    QString errorString() const;
    Q_SCRIPTABLE void resetCompletion();

Q_SIGNALS:
    void cacheDirExistsChanged();
    void completionChanged();
    void errorStringChanged();

private:
    QString m_cacheDir;
    Completion m_completion = Completion::NotStarted;
    QString m_errorString;
};
