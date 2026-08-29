/*
 *  SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QVersionNumber>

#include <KConfig>
#include <KConfigGroup>
#include <KDEDModule>

class PlasmaWelcomeDaemon : public KDEDModule
{
    Q_OBJECT

public:
    PlasmaWelcomeDaemon(QObject *parent, const QList<QVariant> &);

private:
    bool isSignificantUpgrade() const;
    void launch(const QStringList &args);

    KConfig m_config;
    KConfigGroup m_configGroup;
    const QVersionNumber m_currentVersion;
    const QVersionNumber m_previousVersion;
};
