/*
 *  SPDX-FileCopyrightText: 2025 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <KLocalizedString>
#include <kpackage/packagestructure.h>

class PlasmaWelcomePagePackageStructure : public KPackage::PackageStructure
{
    Q_OBJECT
public:
    explicit PlasmaWelcomePagePackageStructure(QObject *parent = nullptr, const QVariantList &args = QVariantList())
        : KPackage::PackageStructure(parent, args)
    {
    }
    void initPackage(KPackage::Package *package) override;
};
