#pragma once

#include <QDateTime>
#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

// Cum se afișează numerele, banii și datele în toată aplicația: un singur loc.
// Folosește limba curentă (QLocale implicit): în română, „245,00 lei”. QLocale::setDefault
// îl schimbă ProfileService, odată cu limba aleasă în Profil. În QML:
//   Format.points(100)        → "100"      (zecimale doar dacă există: "32,29")
//   Format.money(245)         → "245,00 lei"
//   Format.percent(5)         → "5%"
//   Format.dateTime(d)        → "21.11.2026, 13:45"
//   Format.shortDateTime(d)   → "21.11, 13:45"  (pentru liste; anul doar dacă nu e cel curent)
//   Format.initial("Etalonus") → "E"       (prima literă/cifră, pentru cercul localului)
//   Format.phone("060000002") → "+373 60 000 002"   (număr din Moldova; altfel rămâne cum e)
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
    Q_INVOKABLE QString shortDateTime(const QDateTime &value) const;
    Q_INVOKABLE QString initial(const QString &name) const;
    Q_INVOKABLE QString phone(const QString &value) const;
};
