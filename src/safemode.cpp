/*
 *  SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "safemode.h"

#include "safemodebackuprestore.h"
#include "safemodecacheclearer.h"

#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QtEnvironmentVariables>

using namespace Qt::StringLiterals;

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

SafeModeBackupRestore *SafeMode::backupRestore()
{
    if (!m_backupRestore) {
        const QString testHome = QDir::cleanPath(QFile::decodeName(qgetenv("SAFEMODE_BACKUP_TEST_HOME")));
        const QString homeDir = testHome.isEmpty() ? QStandardPaths::writableLocation(QStandardPaths::HomeLocation) : testHome;

        m_backupRestore = new SafeModeBackupRestore(homeDir == "/"_L1 ? QString() : homeDir, this);
    }
    return m_backupRestore;
}

#include "moc_safemode.cpp"
