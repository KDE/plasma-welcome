/*
 *  SPDX-FileCopyrightText: 2025 Nicolas Fella <nicolas.fella@gmx.de>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "plasmacolors.h"

PlasmaColors::PlasmaColors()
{
    connect(&m_theme, &Plasma::Theme::themeChanged, this, &PlasmaColors::colorsChanged);
}

QColor PlasmaColors::textColor() const
{
    return m_theme.color(Plasma::Theme::TextColor);
}

QColor PlasmaColors::disabledTextColor() const
{
    return m_theme.color(Plasma::Theme::DisabledTextColor);
}

QColor PlasmaColors::activeTextColor() const
{
    return m_theme.color(Plasma::Theme::HighlightedTextColor);
}

QColor PlasmaColors::highlightColor() const
{
    return m_theme.color(Plasma::Theme::HighlightColor);
}

QColor PlasmaColors::backgroundColor() const
{
    return m_theme.color(Plasma::Theme::BackgroundColor);
}

#include "moc_plasmacolors.cpp"
