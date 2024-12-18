/*
 *  SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <KOSRelease>

#include "distro.h"

Distro::Distro(QObject *parent)
    : QObject(parent)
{
}

QString Distro::name() const
{
    return KOSRelease().name();
}

QString Distro::icon() const
{
    return KOSRelease().logo();
}

QString Distro::url() const
{
    return KOSRelease().homeUrl();
}

QString Distro::bugReportUrl() const
{
    return KOSRelease().bugReportUrl();
}

#include "moc_distro.cpp"
