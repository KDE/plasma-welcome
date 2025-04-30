/*
 *  SPDX-FileCopyrightText: 2025 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <ranges>

#include <QDir>
#include <QQmlComponent>
#include <QtQml>

#include <KPackage/PackageLoader>

#include "config-plasma-welcome.h"

#include "pagesmodel.h"

// TODO: We need to have a page status, for whether we need QML to create an error page or use a provided component
//       That's the best way to handle this, and then we can remove the error page creation from here and just set an error

PagesModel::PagesModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_packages(listPackages())
    , m_legacyDistroPages(listLegacyDistroPages())
{
}

void PagesModel::load(const QStringList &requestedPages)
{
    beginResetModel();

    m_pages.clear();

    for (const QString &pageId : requestedPages) {
        loadPage(pageId);
    }

    endResetModel();
}

void PagesModel::loadPage(const QString &id)
{
    if (id == QStringLiteral("$distroPages")) {
        // Load legacy distro pages
        for (const auto &page : m_legacyDistroPages) {
            const QString distroPageId = page.section('/', -1).section('.', 0, 0);
            loadPage(distroPageId);
        }

        // Load packaged distro pages
        for (const auto &package : m_packages) {
            const QString packageId = package.metadata().pluginId();
            if (packageId.startsWith(QStringLiteral("org.kde"))) {
                break;
            }

            loadPage(packageId);
        }

        return;
    }

    // Try as a package
    if (auto it = std::ranges::find_if(m_packages,
                                       [&](const auto &package) {
                                           return package.metadata().pluginId() == id;
                                       });
        it != m_packages.end()) {
        m_pages << createPage(it->filePath("ui", QStringLiteral("main.qml")), id, it->metadata(), id.startsWith(QStringLiteral("org.kde")) ? KDE : Distro);
        return;
    }

    // Try as a legacy distro page
    if (auto it = std::ranges::find_if(m_legacyDistroPages,
                                       [&](const auto &legacyDistroPage) {
                                           return (legacyDistroPage.section('/', -1) == (id + QStringLiteral(".qml")));
                                       });
        it != m_legacyDistroPages.end()) {
        m_pages << createPage(*it, id, {}, Distro); // TODO: Empty metadata OK?
        return;
    }

    // No such page
    const QString error = QStringLiteral("Page \"%1\" does not exist").arg(id);
    qWarning().noquote() << error;
    m_pages << createErrorPage(error, id, {}, Unknown); // TODO: Ditto
}

QStringList PagesModel::availablePages()
{
    QStringList pages;

    const auto packagePages = m_packages | std::views::transform([&](const KPackage::Package &package) {
                                  return package.metadata().pluginId();
                              });
    pages << QStringList{packagePages.begin(), packagePages.end()};

    const auto legacyDistroPages = m_legacyDistroPages | std::views::transform([&](const QString &page) {
                                       return page.section('/', -1).section('.', 0, 0);
                                   });
    pages << QStringList{legacyDistroPages.begin(), legacyDistroPages.end()};

    return pages;
}

QHash<int, QByteArray> PagesModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    roleNames[IdRole] = "id";
    roleNames[MetaDataRole] = "metaData";
    roleNames[TypeRole] = "type";
    roleNames[ErrorRole] = "error";
    // roleNames[ComponentRole] = "component";
    return roleNames;
}

int PagesModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_pages.count();
}

QVariant PagesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return {};
    }

    const PageData &pageData = m_pages.at(index.row());

    switch (role) {
    case Qt::DisplayRole:
        return {};
    case IdRole:
        return pageData.id;
    case MetaDataRole:
        return QVariant::fromValue<KPluginMetaData>(pageData.metaData);
    case TypeRole:
        return pageData.type;
    case ErrorRole:
        return pageData.error;
    default:
        return {};
    }
}

QList<QQuickItem *> PagesModel::pages() const
{
    const auto pages = m_pages | std::views::transform([&](const PageData &pageData) {
                           return pageData.item;
                       });

    return {pages.begin(), pages.end()};
}

QList<KPackage::Package> PagesModel::listPackages()
{
    return KPackage::PackageLoader::self()->listKPackages(QStringLiteral("Plasma/WelcomePage"));
}

QStringList PagesModel::listLegacyDistroPages()
{
    // TODO Plasma 7: Remove support for legacy distro pages
    const QString legacyDistroPagesDirname = QLatin1String(DISTRO_CUSTOM_PAGE_FOLDER);
    const QDir legacyDistroPagesDir = QDir(legacyDistroPagesDirname);
    const auto legacyDistroPages =
        legacyDistroPagesDir.entryList(QDir::NoDotAndDotDot | QDir::Files | QDir::Readable, QDir::Name) | std::views::transform([&](const QString &page) {
            return "file://" + legacyDistroPagesDirname + page;
        });
    return {legacyDistroPages.begin(), legacyDistroPages.end()};
}

PagesModel::PageData PagesModel::createPage(const QString &path, const QString &id, KPluginMetaData metaData, PageType type, const QString &error)
{
    QQmlEngine *engine = qmlEngine(parent());
    Q_ASSERT(engine);

    QQmlComponent pageComponent(engine);
    pageComponent.loadUrl(QUrl(path));
    if (pageComponent.status() != QQmlComponent::Ready) {
        qWarning() << "Couldn't load page" << id;
        QStringList errorStrings;
        for (const QQmlError &error : pageComponent.errors()) {
            const QString &errorString = error.toString();
            qWarning() << " " << errorString;
            errorStrings << errorString;
        }

        return createErrorPage(id, metaData, type, errorStrings.join('\n'));
    }

    QObject *pageObject = pageComponent.create(); // TODO: engine->rootContext() args?

    // Ensure page is a QQuickItem
    auto pageItem = qobject_cast<QQuickItem *>(pageObject);
    if (!pageItem) {
        pageObject->deleteLater();

        qWarning() << "Couldn't load page" << id;
        const QString error = QStringLiteral("Page is not QQuickItem");
        qWarning().noquote() << " " << error;

        return createErrorPage(id, metaData, type, error);
    }

    // engine->setObjectOwnership(pageItem, QQmlEngine::CppOwnership);
    // pageItem->setParent(this);
    return {id, metaData, type, QString(), std::make_unique<>};
}

PagesModel::PageData PagesModel::createErrorPage(const QString &error, const QString &id, KPluginMetaData metaData, PageType type)
{
    QQmlEngine *engine = qmlEngine(parent());
    Q_ASSERT(engine);

    QQmlComponent component(engine);
    component.loadFromModule("org.kde.plasma.welcome.private", "PageError");
    if (component.status() != QQmlComponent::Ready) {
        qCritical() << "Could not create error page";
        return {};
    }

    auto pageObject = component.createWithInitialProperties({{"error", error}, {"pageType", type}});

    auto pageItem = qobject_cast<QQuickItem *>(pageObject);
    if (!pageItem) {
        pageObject->deleteLater();
        qCritical() << "Error page is not a QQuickItem";
        return {};
    }

    // engine->setObjectOwnership(pageItem, QQmlEngine::CppOwnership);
    // pageItem->setParent(this);
    return {id, metaData, type, pageItem};
}

#include "moc_pagesmodel.cpp"
