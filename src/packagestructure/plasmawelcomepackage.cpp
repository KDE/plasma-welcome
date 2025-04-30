/*
 *  SPDX-FileCopyrightText: 2025 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "plasmawelcomepackage.h"

#include <KPackage/Package>

void PlasmaWelcomePagePackageStructure::initPackage(KPackage::Package *package)
{
    package->setDefaultPackageRoot(QStringLiteral("plasma/plasma-welcome/pages"));
    package->addDirectoryDefinition("ui", QStringLiteral("ui"));

    package->addFileDefinition("mainscript", QStringLiteral("ui/main.qml"));
    package->setRequired("mainscript", true);
}

K_PLUGIN_CLASS_WITH_JSON(PlasmaWelcomePagePackageStructure, "plasma-welcome-packagestructure.json")

#include "plasmawelcomepackage.moc"

#include "moc_plasmawelcomepackage.cpp"
