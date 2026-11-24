#pragma once

#include <QDateTime>
#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

// Cum se afișează numerele, banii și datele în toată aplicația: un singur loc.
// Folosește limba curentă (QLocale implicit): pe un telefon în română, „245,00 lei”;
// când va exista alegerea limbii din Profil, se schimbă QLocale::setDefault și tot
// textul urmează. În QML:
//   Format.points(100)        → "100"      (zecimale doar dacă există: "32,29")
//   Format.money(245)         → "245,00 lei"
//   Format.percent(5)         → "5%"
//   Format.dateTime(d)        → "21.11.2026, 13:45"
//   Format.initial("Etalonus") → "E"       (prima literă/cifră, pentru cercul localului)
class Format : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Format(QObject *parent = nullptr);

    Q_INVOKABLE QString points(double value) const;
    Q_INVOKABLE QString money(double value) const;
    Q_INVOKABLE QString percent(double value) const;
    Q_INVOKABLE QString dateTime(const QDateTime &value) const;
    Q_INVOKABLE QString initial(const QString &name) const;
};
