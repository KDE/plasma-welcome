/*
 *  SPDX-FileCopyrightText: 2025 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QQuickItem>
#include <QStandardItemModel>

#include <KPackage/Package>
#include <kpluginmetadata.h>

class PagesModel : public QAbstractListModel
{
    Q_OBJECT

public:
    PagesModel(QObject *parent = nullptr);

    enum AdditionalRoles {
        IdRole = Qt::UserRole + 1,
        MetaDataRole,
        TypeRole,
        ErrorRole,
        ComponentRole
    };
    Q_ENUM(AdditionalRoles)

    enum PageType {
        KDE,
        Distro,
        Unknown
    };
    Q_ENUM(PageType)

    void load(const QStringList &requestedPages);
    void loadPage(const QString &id);

    QStringList availablePages();

    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    Q_INVOKABLE QList<QQmlComponent *> pageComponents() const;

    // Q_INVOKABLE QString id(int row);
    // Q_INVOKABLE PageType pageType(int row);
    // Q_INVOKABLE QQuickItem *pageItem(int row);
    // Q_INVOKABLE KPluginMetaData metaData(int row);

private:
    QList<KPackage::Package> m_packages;
    QStringList m_legacyDistroPages;

    QList<KPackage::Package> listPackages();
    QStringList listLegacyDistroPages();

    struct PageData {
        QString id;
        KPluginMetaData metaData;
        PageType type;
        QString error;
        std::unique_ptr<QQmlComponent *> component;
    };

    PageData createPage(const QString &path, const QString &id, KPluginMetaData metaData, PageType type, const QString &error);
    PageData createErrorPage(const QString &id, KPluginMetaData metaData, PageType type, const QString &error);

    QList<PageData> m_pages;
};
