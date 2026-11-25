#pragma once

#include <QObject>
#include <QPointer>
#include <QString>
#include <QTranslator>
#include <QtQml/qqmlregistration.h>

class QQmlEngine;
class QJSEngine;

// Profilul clientului, pentru QML: ProfileService.name, .phone, .initials, .language.
// Datele sunt în forma din Back (TMS_PERSONS_PHYS, verificat 25.11.2026): prenumele
// (FIRST_NAME) și numele (LAST_NAME) separat, telefonul mobil (PHONE_MOB) în format local,
// „060000002”. Le dă serverul (comanda get_profile), cerute la pornire; până vin, sunt
// goale. Cât nu există intrarea în cont, se cere titularul cardului de test
// (ServerConfig::testCard). Telefonul se afișează prin Format.phone: „+373 60 000 002”.
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

    // Numele afișat: prenumele + numele („Test Loialitate 2”).
    Q_PROPERTY(QString name READ name NOTIFY profileChanged)
    // Telefonul mobil așa cum e în baza de date („060000002”); de afișat cu Format.phone.
    Q_PROPERTY(QString phone READ phone NOTIFY profileChanged)
    // Pentru cercul cu inițiale: prima literă din prenume și din nume → „TL”.
    Q_PROPERTY(QString initials READ initials NOTIFY profileChanged)
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
    void profileChanged();

private:
    void applyLanguage();
    // Cere de la server prenumele, numele și telefonul (get_profile).
    void loadProfile();

    QPointer<QQmlEngine> m_engine;
    QTranslator m_translator;
    QString m_language;
    QString m_firstName;
    QString m_lastName;
    QString m_phone;
};
