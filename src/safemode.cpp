/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemode.h"

#include "safemodecacheclearer.h"

#include <kworkspace6/sessionmanagement.h>

#include <QtEnvironmentVariables>

SafeMode::SafeMode(QObject *parent)
    : QObject(parent)
    , m_actuallyInSafeMode(qEnvironmentVariableIntValue("KDE_SAFEMODE") > 0)
{
}

bool SafeMode::actuallyInSafeMode() const
{
    return m_actuallyInSafeMode;
}

SafeModeCacheClearer *SafeMode::cacheClearer()
{
    if (!m_cacheClearer) {
        m_cacheClearer = new SafeModeCacheClearer(this);
    }
    return m_cacheClearer;
}

void SafeMode::requestLogoutPrompt()
{
    static SessionManagement *sessionManagement = new SessionManagement();
    sessionManagement->requestLogout(SessionManagement::ConfirmationMode::ForcePrompt);
}

#include "moc_safemode.cpp"
