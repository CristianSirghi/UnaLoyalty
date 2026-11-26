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

QString Format::shortDateTime(const QDateTime &value) const
{
    // În liste, unde locul e puțin: anul doar dacă nu e anul curent.
    if (value.date().year() == QDate::currentDate().year())
        return value.toString(QStringLiteral("dd.MM, HH:mm"));
    return dateTime(value);
}

QString Format::phone(const QString &value) const
{
    // În Back telefonul e scris local („060000002”), uneori poate și cu prefixul
    // („+373 60000002”, „37360000002”). Păstrăm doar cifrele și scoatem prefixul;
    // rămân 8 cifre (60 000 002), grupate 2-3-3, ca în Moldova.
    QString digits;
    for (const QChar c : value) {
        if (c.isDigit())
            digits += c;
    }
    if (digits.size() == 11 && digits.startsWith(QLatin1String("373")))
        digits.remove(0, 3);
    else if (digits.size() == 9 && digits.startsWith(QLatin1Char('0')))
        digits.remove(0, 1);

    // Alt format (număr din altă țară, greșit scris): îl arătăm cum a venit.
    if (digits.size() != 8)
        return value;

    return QStringLiteral("+373 %1 %2 %3")
        .arg(digits.left(2), digits.mid(2, 3), digits.mid(5, 3));
}

QString Format::initial(const QString &name) const
{
    for (const QChar c : name) {
        if (c.isLetterOrNumber())
            return QString(c).toUpper();
    }
    return {};
}
