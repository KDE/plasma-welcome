/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QNetworkAccessManager>
#include <QNetworkInformation>
#include <QNetworkReply>
#include <QQmlEngine>

// org.kde.plasma.welcome.private, Release
// Provides release information for Welcome Center

class Release : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    Release(QObject *parent = nullptr);

    enum ReleaseType {
        Shipping,
        Beta,
        Development
    };
    Q_ENUM(ReleaseType)

    enum PreviewStatus {
        Unloaded,
        Loading,
        Loaded
    };
    Q_ENUM(PreviewStatus)

    enum PreviewError {
        None,
        Metered,
        NetworkCode,
        ParseFailure
    };
    Q_ENUM(PreviewError)

    bool isBeta() const;
    bool isDevelopment() const;
    QString announcementUrl() const;

    Q_PROPERTY(QString friendlyVersion MEMBER m_friendlyVersion CONSTANT)
    Q_PROPERTY(bool isBeta READ isBeta CONSTANT)
    Q_PROPERTY(bool isDevelopment READ isDevelopment CONSTANT)
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
    void parsePreviewReply(QNetworkReply *const reply);

    QVersionNumber m_version;
    QString m_friendlyVersion;
    QString m_announcementUrl;

    QNetworkInformation *m_networkInfo;
    QNetworkAccessManager *m_previewNetworkAccessManager;
    PreviewStatus m_previewStatus;
    PreviewError m_previewError;
    int m_previewErrorCode;
    QString m_previewTitle;
    QString m_previewDescription;
};
