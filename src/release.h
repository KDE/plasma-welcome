/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QNetworkReply>

#include <singleton.h>

// org.kde.plasma.welcome, Release
// Provides release information for Welcome Center

class Release : public QObject, public Singleton<Release>
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    WELCOME_SINGLETON(Release)

public:
    enum PreviewStatus {
        Unloaded,
        Loading,
        Loaded
    };
    Q_ENUM(PreviewStatus)

    enum PreviewError {
        None,
        Code,
        ParseFailure
    };
    Q_ENUM(PreviewError)

    int patchVersion() const;
    QString announcementUrl() const;

    Q_PROPERTY(QString friendlyVersion MEMBER m_friendlyVersion CONSTANT)
    Q_PROPERTY(int patchVersion READ patchVersion CONSTANT)
    Q_PROPERTY(QString announcementUrl READ announcementUrl CONSTANT)

    Q_PROPERTY(PreviewStatus previewStatus MEMBER m_previewStatus NOTIFY previewStatusChanged)
    Q_PROPERTY(PreviewError previewError MEMBER m_previewError NOTIFY previewErrorChanged)
    Q_PROPERTY(int previewErrorCode MEMBER m_previewErrorCode NOTIFY previewErrorChanged)
    Q_PROPERTY(QString previewTitle MEMBER m_previewTitle NOTIFY previewTitleChanged)
    Q_PROPERTY(QString previewDescription MEMBER m_previewDescription NOTIFY previewDescriptionChanged)
    Q_INVOKABLE void tryAutomaticPreview();
    Q_INVOKABLE void getPreview();

Q_SIGNALS:
    void previewStatusChanged();
    void previewErrorChanged();
    void previewErrorCodeChanged();
    void previewTitleChanged();
    void previewDescriptionChanged();

private:
    Release(QObject *parent = nullptr);

    void parsePreviewReply(QNetworkReply *const reply);

    QVersionNumber m_version;
    QString m_friendlyVersion;
    QString m_announcementUrl;

    QNetworkAccessManager *m_previewNetworkAccessManager;
    PreviewStatus m_previewStatus;
    PreviewError m_previewError;
    int m_previewErrorCode;
    QString m_previewTitle;
    QString m_previewDescription;
};
