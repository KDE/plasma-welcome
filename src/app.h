/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024-2025 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QObject>
#include <qqmlregistration.h>

#include <KConfig>

#include "pagesmodel.h"

// org.kde.plasma.welcome.private, App
// Provides core functionality for Welcome Center not intended for distro pages

class App : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(Mode mode MEMBER m_mode CONSTANT)
    Q_PROPERTY(PagesModel *pagesModel READ pagesModel CONSTANT)
    Q_PROPERTY(QString installPrefix READ installPrefix CONSTANT)
    Q_PROPERTY(bool isDistroSnapOnly READ isDistroSnapOnly CONSTANT)
    Q_PROPERTY(QString customIntroText MEMBER m_customIntroText CONSTANT)
    Q_PROPERTY(QString customIntroIcon MEMBER m_customIntroIcon CONSTANT)
    Q_PROPERTY(QString customIntroIconLink MEMBER m_customIntroIconLink CONSTANT)
    Q_PROPERTY(QString customIntroIconCaption MEMBER m_customIntroIconCaption CONSTANT)

public:
    App(QObject *parent = nullptr);

    enum Mode {
        Pages, // Specified subset of pages via m_pages
        Update, // Post-Plasma update
        Live, // Welcome with added Live page
        Welcome // Normal experience with all pages
    };
    Q_ENUM(Mode)

    void setMode(App::Mode mode);
    void loadPages(const QStringList &requestedPages);
    QStringList availablePages() const;

    PagesModel *pagesModel() const;
    QString installPrefix() const;
    bool isDistroSnapOnly() const;

    Q_INVOKABLE bool kcmAvailable(const QString &kcm) const;

private:
    KConfig *m_appConfig;

    struct ModeConfig {
        QString configKey;
        QStringList pageIds;
    };

    static const QMap<App::Mode, ModeConfig> ModeConfigs;

    Mode m_mode;
    PagesModel *m_pagesModel;

    QString m_customIntroText;
    QString m_customIntroIcon;
    QString m_customIntroIconLink;
    QString m_customIntroIconCaption;
};
