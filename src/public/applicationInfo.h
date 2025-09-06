/*
 *  SPDX-FileCopyrightText: 2025 Oliver Beard <olib141@outlook.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QObject>
#include <qqmlregistration.h>

class ApplicationInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString desktopName READ desktopName WRITE setDesktopName NOTIFY desktopNameChanged)
    Q_PROPERTY(bool exists READ exists NOTIFY existsChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString icon READ icon NOTIFY iconChanged)
    QML_ELEMENT

public:
    ApplicationInfo(QObject *parent = nullptr);
    ~ApplicationInfo() override;

    QString desktopName() const;
    void setDesktopName(const QString &desktopName);

    bool exists() const;
    QString name() const;
    QString icon() const;

Q_SIGNALS:
    void desktopNameChanged();
    void existsChanged();
    void nameChanged();
    void iconChanged();

private:
    void update();

    QString m_desktopName;
    bool m_exists;
    QString m_name;
    QString m_icon;
};
