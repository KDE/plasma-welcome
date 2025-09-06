/*
 *  SPDX-FileCopyrightText: 2025 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "applicationInfo.h"

#include <QString>

#include <KService>
#include <KSycoca>

ApplicationInfo::ApplicationInfo(QObject *parent)
    : QObject(parent)
{
    // Update application information when KSycoca's database is changed,
    // e.g. it may have been installed later
    connect(KSycoca::self(), &KSycoca::databaseChanged, this, &ApplicationInfo::update);
}

ApplicationInfo::~ApplicationInfo()
{
}

QString ApplicationInfo::desktopName() const
{
    return m_desktopName;
}

void ApplicationInfo::setDesktopName(const QString &desktopName)
{
    if (m_desktopName != desktopName) {
        m_desktopName = desktopName;
        Q_EMIT desktopNameChanged();

        update();
    }
}

bool ApplicationInfo::exists() const
{
    return m_exists;
}

QString ApplicationInfo::name() const
{
    return m_name;
}

QString ApplicationInfo::icon() const
{
    return m_icon;
}

void ApplicationInfo::update()
{
    const KService::Ptr service = KService::serviceByDesktopName(m_desktopName);

    bool exists = (service != nullptr);
    QString name = service ? service->name() : QString();
    QString icon = service ? service->icon() : QString();

    if (m_exists != exists) {
        m_exists = exists;
        Q_EMIT existsChanged();
    }

    if (m_name != name) {
        m_name = name;
        Q_EMIT nameChanged();
    }

    if (m_icon != icon) {
        m_icon = icon;
        Q_EMIT iconChanged();
    }
}

#include "moc_applicationInfo.cpp"
