/*
 *  SPDX-FileCopyrightText: 2025 Nicolas Fella <nicolas.fella@gmx.de>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QColor>
#include <QObject>
#include <qqmlregistration.h>

#include <Plasma/Theme>

class PlasmaColors : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QColor textColor READ textColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor disabledTextColor READ disabledTextColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor activeTextColor READ activeTextColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor highlightColor READ highlightColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor NOTIFY colorsChanged)

public:
    PlasmaColors();

    QColor textColor() const;
    QColor disabledTextColor() const;
    QColor activeTextColor() const;
    QColor highlightColor() const;
    QColor backgroundColor() const;

Q_SIGNALS:
    void colorsChanged();

private:
    Plasma::Theme m_theme;
};
