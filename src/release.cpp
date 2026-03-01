/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <QRegularExpression>
#include <QTextDocumentFragment>

#include <KLocalizedString>

#include "../plasma-welcome-version.h"
#include "welcome_debug.h"

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

    // Setup for fetching preview
    if (!QNetworkInformation::loadDefaultBackend()) {
        qCWarning(WELCOME_LOG) << "Failed to load QNetworkInformation backend";
    }
    m_networkInfo = QNetworkInformation::instance();

    m_previewNetworkAccessManager = new QNetworkAccessManager(this);
    m_previewNetworkAccessManager->setAutoDeleteReplies(true);
    connect(m_previewNetworkAccessManager, &QNetworkAccessManager::finished, this, &Release::parsePreviewReply);

    m_previewStatus = PreviewStatus::Unloaded;
    m_previewError = PreviewError::None;
}

bool Release::isBeta() const
{
    return PLASMA_WELCOME_VERSION_MINOR >= 80 || PLASMA_WELCOME_VERSION_PATCH >= 90;
}

bool Release::isDevelopment() const
{
    return PLASMA_WELCOME_VERSION_PATCH == 80;
}

QString Release::announcementUrl() const
{
    return m_announcementUrl + "?source=plasma-welcome";
}

void Release::tryAutomaticPreview()
{
    if (m_previewStatus == Loaded || m_previewStatus == Loading) {
        return;
    }

    if (!m_networkInfo) {
        // Can't check if we're metered, so let's play it safe
        return;
    }

    if (m_networkInfo->isMetered()) {
        // We're metered
        m_previewError = PreviewError::Metered;
        emit previewErrorChanged();

        return;
    }

    // If we're not metered, let's try to load
    getPreview();
}

void Release::getPreview()
{
    if (m_previewStatus == Loaded || m_previewStatus == Loading) {
        return;
    }

    m_previewStatus = Loading;
    emit previewStatusChanged();

    // Let's retry automatically if the network goes up later
    if (m_networkInfo) {
        connect(m_networkInfo, &QNetworkInformation::reachabilityChanged, this, [this](QNetworkInformation::Reachability newReachability) {
            if (m_previewStatus == PreviewStatus::Unloaded && newReachability == QNetworkInformation::Reachability::Online) {
                getPreview();
            }
        });
    }

    // Try getting the announcement for the current language
    QString announcementUrl = m_announcementUrl;

    const QString kdeSite = QStringLiteral("https://kde.org/");
    if (announcementUrl.startsWith(kdeSite)) {
        // It's ours, we know how to localise it: Hugo uses
        // lowercase BCP 47 tags, as defined in RFC 5646
        QString languageTag = QLocale().bcp47Name().toLower();
        if (languageTag != "en-POSIX") {
            announcementUrl.insert(kdeSite.length(), languageTag + "/");
        }
    }

    qCInfo(WELCOME_LOG) << "Fetching announcement for preview with URL" << announcementUrl;

    m_previewNetworkAccessManager->get(QNetworkRequest(QUrl(announcementUrl)));
}

void Release::parsePreviewReply(QNetworkReply *const reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        m_previewError = PreviewError::NetworkCode;
        m_previewErrorCode = static_cast<int>(reply->error());
        m_previewStatus = PreviewStatus::Unloaded;

        emit previewErrorChanged();
        emit previewErrorCodeChanged();
        emit previewStatusChanged();

        qCWarning(WELCOME_LOG) << "Failed to get announcement preview:" << m_previewErrorCode << reply->errorString();
        return;
    }

    const QString data = QString::fromUtf8(reply->readAll());

    enum PreviewField {
        Title,
        Description
    };

    struct PreviewRegex {
        QString source;
        QString regexString;
    };

    auto applyRegexes = [this, &data](const PreviewField &previewField, const QList<PreviewRegex> &previewRegexes) {
        for (const PreviewRegex &previewRegex : previewRegexes) {
            const QRegularExpression regex(previewRegex.regexString, QRegularExpression::DotMatchesEverythingOption);
            const QRegularExpressionMatch match = regex.match(data);

            if (match.hasMatch()) {
                const QString previewString = QTextDocumentFragment::fromHtml(match.captured(1)).toRawText();

                if (previewField == Title) {
                    m_previewTitle = std::move(previewString);
                    qCDebug(WELCOME_LOG) << "Parsed title from announcement preview using" << previewRegex.source;
                } else if (previewField == Description) {
                    m_previewDescription = std::move(previewString);
                    qCDebug(WELCOME_LOG) << "Parsed description from announcement preview using" << previewRegex.source;
                }

                return;
            }
        }

        if (previewField == Title) {
            m_previewTitle = QString();
            qCWarning(WELCOME_LOG) << "Failed to parse title from annoucement preview";
        } else if (previewField == Description) {
            m_previewDescription = QString();
            qCWarning(WELCOME_LOG) << "Failed to parse description from annoucement preview";
        }
    };

    applyRegexes(Title,
                 {{"Plasma announcement subtitle with unquoted class", "<h2\\s+class=h1\\s*>([^<]*)</h2>"},
                  {"Plasma announcement subtitle", "<h2\\s+class=\"h1\"\\s*>([^<]*)</h2>"},
                  {"OpenGraph title", "<meta\\s+property=\"og:title\"\\s+content=\"([^\"]*)\""},
                  {"OpenGraph title (reversed)", "<meta\\s+content=\"([^\"]*)\"\\s+property=\"og:title\""},
                  {"HTML title", "<title\\s*>([^<]*)</title>"}});

    applyRegexes(Description,
                 {{"OpenGraph description", "<meta\\s+property=\"og:description\"\\s+content=\"([^\"]*)\""},
                  {"OpenGraph description (reversed)", "<meta\\s+content=\"([^\"]*)\"\\s+property=\"og:description\""}});

    if (m_previewTitle.isEmpty() || m_previewDescription.isEmpty()) {
        m_previewError = PreviewError::ParseFailure;
        m_previewStatus = PreviewStatus::Unloaded;

        emit previewErrorChanged();
        emit previewStatusChanged();

        return;
    }

    m_previewStatus = PreviewStatus::Loaded;

    emit previewTitleChanged();
    emit previewDescriptionChanged();
    emit previewStatusChanged();
}

#include "moc_release.cpp"
