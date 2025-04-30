/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024-2025 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <ranges>

#include <QDir>
#include <QQmlEngine>

#include <KAuthorized>
#include <KDesktopFile>
#include <KOSRelease>
#include <KPackage/PackageLoader>
#include <KPluginMetaData>

#include "config-plasma-welcome.h"

#include "app.h"

App::App(QObject *parent)
    : QObject(parent)
{
    m_mode = Mode::Welcome;
    m_packages = KPackage::PackageLoader::self()->listKPackages(QStringLiteral("Plasma/WelcomePage"));

    // TODO Plasma 7: Remove support for legacy distro pages
    const QString legacyDistroPagesDirname = QLatin1String(DISTRO_CUSTOM_PAGE_FOLDER);
    const QDir legacyDistroPagesDir = QDir(legacyDistroPagesDirname);
    const auto legacyDistroPages = legacyDistroPagesDir.entryList(QDir::NoDotAndDotDot | QDir::Files | QDir::Readable, QDir::Name)
                                 | std::views::transform([&](const QString &page) { return "file://" + legacyDistroPagesDirname + page; });
    m_legacyDistroPages = { legacyDistroPages.begin(), legacyDistroPages.end() };

    const QFileInfo introTextFile = QFileInfo(QStringLiteral(DISTRO_CUSTOM_INTRO_FILE));
    if (introTextFile.exists()) {
        const KDesktopFile desktopFile(introTextFile.absoluteFilePath());
        m_customIntroText = desktopFile.readName();
        m_customIntroIcon = desktopFile.readIcon();
        m_customIntroIconLink = desktopFile.readUrl();
        m_customIntroIconCaption = desktopFile.readComment();
    }
}

void App::setMode(App::Mode mode)
{
    m_mode = mode;
}

// TODO listPages for cmdline arg?

void App::loadPages(const QStringList &requestedPages)
{
    Q_ASSERT(m_pages.isEmpty());

    // TODO: Get orders from config in /usr/share/plasma/plasma-welcome/plasma-welcome.conf
    //       allow distros override to insert own modules, remove built-in modules and customise order
    const QStringList updateOrder = {"org.kde.update"};
    const QStringList liveOrder = {"org.kde.live",
                                   "org.kde.welcome",
                                   "org.kde.network",
                                   "org.kde.simplebydefault",
                                   "org.kde.powerfulwhenneeded",
                                   "org.kde.discover",
                                   "$legacyDistroPages",
                                   "org.kde.enjoy"};
    const QStringList welcomeOrder = {"org.kde.welcome",
                                      "org.kde.network",
                                      "org.kde.simplebydefault",
                                      "org.kde.powerfulwhenneeded",
                                      "org.kde.discover",
                                      "org.kde.feedback",
                                      "$legacyDistroPages",
                                      "org.kde.enjoy"};

    // "$legacyDistroPages", insert non-kpackage distro pages

    QStringList loadPages;
    switch (m_mode) {
    case Pages:
        loadPages = requestedPages;
        break;
    case Update:
        loadPages = updateOrder;
        break;
    case Live:
        loadPages = liveOrder;
        break;
    case Welcome:
        loadPages = welcomeOrder;
        break;
    }

    for (const QString &id : loadPages) {
        if (id == QStringLiteral("$legacyDistroPages")) {
            // Load our legacy distro pages
            // TODO Plasma 7: Remove support for legacy distro pages
            for (const auto &page : m_legacyDistroPages) {
                m_pages << loadPage(page, page.section('/', -1).section('.', 0, 0));
            }
        } else if (auto it = std::ranges::find_if(m_packages, [&](const auto &package) {
            return package.metadata().pluginId() == id;
        }); it != m_packages.end()) {
            // Load page from package
            m_pages << loadPage(it->filePath("ui", QStringLiteral("main.qml")), id);
        } else if (auto it = std::ranges::find_if(m_legacyDistroPages, [&](const auto &legacyDistroPage) {
            return (legacyDistroPage.section('/', -1) == (id.endsWith(QStringLiteral(".qml")) ? id : id + QStringLiteral(".qml")));
        }); it != m_legacyDistroPages.end()) {
            // Load page from legacy distro pages
            // TODO Plasma 7: Remove support for legacy distro pages
            m_pages << loadPage(*it, it->section('/', -1).section('.', 0, 0));
        } else {
            // We couldn't find the page
            const QString error = QStringLiteral("Page \"%1\" does not exist").arg(id);
            qWarning().noquote() << error;

            m_pages << loadErrorPage(error, PageType::Unknown);
        }
    }
}

// TODO: Why the hell does the first page we load have grayscale antialiasing
// TODO: How to make these pages in C++ and CORRECTLY manage their lifetimes/ownership?

QQuickItem *App::loadPage(const QString &path, const QString &id)
{
    QQmlEngine *engine = qmlEngine(this);

    QQmlComponent pageComponent(engine, QUrl(path), nullptr);
    if (pageComponent.status() != QQmlComponent::Ready) {
        qWarning() << "Couldn't load page" << id;
        QStringList errorStrings;
        for (const QQmlError &error : pageComponent.errors()) {
            const QString &errorString = error.toString();
            qWarning() << " " << errorString;
            errorStrings << errorString;
        }

        return loadErrorPage(errorStrings.join('\n'), id.startsWith(QStringLiteral("org.kde")) ? PageType::KDE : PageType::Distro);
    }

    QObject *pageObject = pageComponent.create(); // TODO: engine->rootContext() args?

    // Ensure page is a QQuickItem
    auto pageItem = qobject_cast<QQuickItem *>(pageObject);
    if (!pageItem) {
        pageObject->deleteLater();

        qWarning() << "Couldn't load page" << id;
        const QString error = QStringLiteral("Page is not QQuickItem");
        qWarning().noquote() << " " << error;

        return loadErrorPage(error, id.startsWith(QStringLiteral("org.kde")) ? PageType::KDE : PageType::Distro);
    }

    // engine->setObjectOwnership(pageItem, QQmlEngine::CppOwnership);
    // pageItem->setParent(this);
    return pageItem;
}

QQuickItem *App::loadErrorPage(const QString &error, const PageType pageType)
{
    QQmlEngine *engine = qmlEngine(this);

    QQmlComponent component(engine);
    component.loadFromModule("org.kde.plasma.welcome.private", "PageError");

    if (component.status() != QQmlComponent::Ready) {
        qCritical() << "Could not create error page";
        return nullptr;
    }

    auto pageObject = component.createWithInitialProperties({{"error", error}, {"pageType", pageType}});

    auto pageItem = qobject_cast<QQuickItem *>(pageObject);
    if (!pageItem) {
        pageObject->deleteLater();
        qCritical() << "Error page is not a QQuickItem";
        return nullptr;
    }

    // engine->setObjectOwnership(pageItem, QQmlEngine::CppOwnership);
    // pageItem->setParent(this);
    return pageItem;
}

QStringList App::availablePages()
{
    QStringList pages;

    const auto packagePages = m_packages | std::views::transform([&](const KPackage::Package &package) {
        return package.metadata().pluginId();
    });
    pages << QStringList{ packagePages.begin(), packagePages.end() };

    const auto legacyDistroPages = m_legacyDistroPages | std::views::transform([&](const QString &page) {
        return page.section('/', -1).section('.', 0, 0);
    });
    pages << QStringList{ legacyDistroPages.begin(), legacyDistroPages.end() };

    return pages;
}

QString App::installPrefix() const
{
    return QString::fromLatin1(PLASMA_WELCOME_INSTALL_DIR);
}

// Workaround for lack of appstream info in snaps for advertised items on Discover page
bool App::isDistroSnapOnly() const
{
    return KOSRelease().extraValue("UBUNTU_VARIANT") == QStringLiteral("core");
}

bool App::kcmAvailable(const QString &kcm) const
{
    KPluginMetaData data(QStringLiteral("plasma/kcms/systemsettings/%1").arg(kcm));
    return data.isValid() && KAuthorized::authorizeControlModule(kcm + QLatin1String(".desktop"));
}

#include "moc_app.cpp"
