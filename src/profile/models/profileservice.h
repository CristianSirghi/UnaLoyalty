#pragma once

#include <QObject>
#include <QPointer>
#include <QString>
#include <QTranslator>
#include <QtQml/qqmlregistration.h>

class QQmlEngine;
class QJSEngine;

// Profilul clientului, pentru QML: ProfileService.name, .phone, .initials, .language.
// Numele și telefonul sunt deocamdată date de test; mai târziu le ia de la server prin
// ApiClient (TMS_PERSONS_PHYS: nume, telefon).
//
// Tot aici se alege limba aplicației: "ro", "ru" sau "en". La prima pornire e limba
// telefonului (altă limbă decât ro/ru → engleză); după ce clientul alege una în Profil,
// se ține minte (QSettings) și schimbarea se vede pe loc. main.cpp cere serviciul
// înainte de Main.qml, ca traducerea să fie pusă de la primul ecran.
class ProfileService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString phone READ phone CONSTANT)
    // Pentru cercul cu inițiale: „Test Loialitate 2” → „TL”.
    Q_PROPERTY(QString initials READ initials CONSTANT)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)

public:
    explicit ProfileService(QQmlEngine *engine, QObject *parent = nullptr);

    // Qt creează singletonul prin funcția asta: așa serviciul știe motorul QML,
    // de care are nevoie ca să reîmprospăteze textele la schimbarea limbii.
    static ProfileService *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    QString name() const;
    QString phone() const;
    QString initials() const;

    QString language() const;
    void setLanguage(const QString &language);

signals:
    void languageChanged();

private:
    void applyLanguage();

    QPointer<QQmlEngine> m_engine;
    QTranslator m_translator;
    QString m_language;
    QString m_name;
    QString m_phone;
};
