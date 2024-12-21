/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QNetworkInformation>
#include <QNetworkReply>
#include <QRegularExpression>
#include <QTextDocumentFragment>

#include <KLocalizedString>

#include "plasma-welcome-version.h"

#include "release.h"

Release::Release(QObject *parent)
    : QObject(parent)
{
    m_version = QVersionNumber::fromString(QString::fromLatin1(PLASMA_WELCOME_VERSION_STRING));

    // Friendly version string, matching desktop preview banner
    if constexpr (PLASMA_WELCOME_VERSION_PATCH == 80 || PLASMA_WELCOME_VERSION_PATCH >= 90) {
        // Development or beta version

        // finalMajor, finalMinor is the final version in the line
        // and should be updated after the final Plasma 6 release
        constexpr int finalMajor = 5;
        constexpr int finalMinor = 27;

        // Incremented minor, which is zeroed and major incremented when we reach the final version in the major release line
        int major = (PLASMA_WELCOME_VERSION_MAJOR == finalMajor && PLASMA_WELCOME_VERSION_MINOR == finalMinor) ? PLASMA_WELCOME_VERSION_MAJOR + 1
                                                                                                               : PLASMA_WELCOME_VERSION_MAJOR;
        int minor = (PLASMA_WELCOME_VERSION_MAJOR == finalMajor && PLASMA_WELCOME_VERSION_MINOR == finalMinor) ? 0 : PLASMA_WELCOME_VERSION_MINOR + 1;

        const QString version = QStringLiteral("%1.%2").arg(QString::number(major), QString::number(minor));

        if constexpr (PLASMA_WELCOME_VERSION_PATCH == 80) {
            // Development version
            m_friendlyVersion = i18nc("@label %1 is the Plasma version", "%1 Dev", version);
        } else if constexpr (PLASMA_WELCOME_VERSION_PATCH == 90) {
            // Beta version
            m_friendlyVersion = i18nc("@label %1 is the Plasma version", "%1 Beta", version);
        } else if constexpr (PLASMA_WELCOME_VERSION_PATCH > 90) {
            // Beta version beyond 1
            constexpr int betaNumber = PLASMA_WELCOME_VERSION_PATCH - 89;
            m_friendlyVersion = i18nc("@label %1 is the Plasma version, %2 is the beta release number", "%1 Beta %2", version, betaNumber);
        } else {
            Q_UNREACHABLE();
        }
    } else {
        // Release version
        m_friendlyVersion = QStringLiteral("%1.%2").arg(QString::number(m_version.majorVersion()), QString::number(m_version.minorVersion()));
    }

    // Announcement URL
    if constexpr (PLASMA_WELCOME_VERSION_PATCH == 80) {
        // Development version
        m_announcementUrl = QStringLiteral("https://invent.kde.org/groups/plasma/-/activity/");
    } else if constexpr (PLASMA_WELCOME_VERSION_PATCH >= 90) {
        // Beta version
        m_announcementUrl = QStringLiteral("https://kde.org/announcements/plasma/%1/%1.%2.90/")
                                .arg(QString::number(m_version.majorVersion()), QString::number(m_version.minorVersion()));
    } else {
        // Release version
        m_announcementUrl = QStringLiteral("https://kde.org/announcements/plasma/%1/%1.%2.0/")
                                .arg(QString::number(m_version.majorVersion()), QString::number(m_version.minorVersion()));
    }

    // Setup QNAM for fetching preview
    m_previewStatus = PreviewStatus::Unloaded;
    m_previewError = PreviewError::None;
    m_previewNetworkAccessManager = new QNetworkAccessManager(this);
    m_previewNetworkAccessManager->setAutoDeleteReplies(true);
    connect(m_previewNetworkAccessManager, &QNetworkAccessManager::finished, this, &Release::parsePreviewReply);
}

int Release::patchVersion() const
{
    return m_version.microVersion();
}

QString Release::announcementUrl() const
{
    return m_announcementUrl + "?source=plasma-welcome";
}

void Release::tryAutomaticPreview()
{
    // Check if the network is up and unmetered
    if (!QNetworkInformation::loadDefaultBackend()) {
        qWarning() << "Failed to load QNetworkInformation backend";
        return;
    }

    auto networkInformation = QNetworkInformation::instance();

    if (networkInformation->isMetered()) {
        return;
    }

    // If we're not metered, and reachability is changed, let's try to load if appropriate
    connect(networkInformation, &QNetworkInformation::reachabilityChanged, this, [this](QNetworkInformation::Reachability newReachability) {
        if (m_previewStatus == PreviewStatus::Unloaded && newReachability == QNetworkInformation::Reachability::Online) {
            getPreview();
        }
    });

    getPreview();
}

void Release::getPreview()
{
    if (m_previewStatus == Loaded || m_previewStatus == Loading) {
        return;
    }

    m_previewStatus = Loading;
    emit previewStatusChanged();

    // Try getting the announcement for the current language
    QString announcementUrl = m_announcementUrl;

    const QString kdeSite = QStringLiteral("https://kde.org/");
    if (announcementUrl.startsWith(kdeSite)) {
        // It's our website, we can localise it
        QString languageCode = KLocalizedString::languages().first().toLower().replace("_", "-");
        announcementUrl.insert(kdeSite.length(), languageCode + "/");
    }

    m_previewNetworkAccessManager->get(QNetworkRequest(announcementUrl));
}

void Release::parsePreviewReply(QNetworkReply *const reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        m_previewError = PreviewError::NetworkCode;
        m_previewErrorCode = static_cast<int>(reply->error());

        emit previewErrorChanged();
        emit previewErrorCodeChanged();

        m_previewStatus = PreviewStatus::Unloaded;
        emit previewStatusChanged();

        return;
    }

    const QString data = QString::fromUtf8(reply->readAll());

    auto tryRegexes = [&data](const QStringList &regexes) -> QString {
        for (QString regexString : regexes) {
            const QRegularExpression regex(regexString);
            const QRegularExpressionMatch match = regex.match(data);

            if (match.hasMatch()) {
                return QTextDocumentFragment::fromHtml(match.captured(1)).toPlainText();
            }
        }

        return QString();
    };

    const QString title = tryRegexes({"<h2 class=h1>(.+?)</h2>", // Tagline on Plasma announcement
                                      "<meta property=\"og:title\" content=\"(.+?)\"", // OpenGraph title
                                      "<meta content=\"(.+?)\" property=\"og:title\""}); // OpenGraph title (reversed)

    const QString description = tryRegexes({"<meta property=\"og:description\" content=\"(.+?)\"", // OpenGraph description
                                            "<meta content=\"(.+?)\" property=\"og:description\""}); // OpenGraph description (reversed)

    if (title.isEmpty() || description.isEmpty()) {
        m_previewError = PreviewError::ParseFailure;
        emit previewErrorChanged();

        m_previewStatus = PreviewStatus::Unloaded;
        emit previewStatusChanged();

        return;
    }

    m_previewTitle = title;
    m_previewDescription = description;

    emit previewTitleChanged();
    emit previewDescriptionChanged();

    m_previewStatus = PreviewStatus::Loaded;
    emit previewStatusChanged();
}

#include "moc_release.cpp"
