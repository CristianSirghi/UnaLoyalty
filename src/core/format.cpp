#include "format.h"

#include <QLocale>

#include <cmath>

Format::Format(QObject *parent)
    : QObject(parent)
{
}

QString Format::points(double value) const
{
    // Punctele pot fi fracționare (5% din bon): zecimale doar când există, rotunjite
    // la 2, ca 0,1 + 0,2 să nu apară „0,30000000000000004”.
    const double rounded = std::round(value * 100.0) / 100.0;
    const int decimals = rounded == std::floor(rounded) ? 0 : 2;
    return QLocale().toString(rounded, 'f', decimals);
}

QString Format::money(double value) const
{
    return tr("%1 lei").arg(QLocale().toString(value, 'f', 2));
}

QString Format::percent(double value) const
{
    return points(value) + QLocale().percent();
}

QString Format::dateTime(const QDateTime &value) const
{
    // Format fix, cum e pe bonurile tipărite, nu după limbă.
    return value.toString(QStringLiteral("dd.MM.yyyy, HH:mm"));
}

QString Format::initial(const QString &name) const
{
    for (const QChar c : name) {
        if (c.isLetterOrNumber())
            return QString(c).toUpper();
    }
    return {};
}
