#pragma once

#include <QJsonObject>
#include <QJsonValue>
#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

// Contul clientului și sesiunea lui, pentru QML: SessionService.signedIn, .busy, .firstName...
// Regulile stau pe server (pachetul PG_LOYALTY, docs/SCOP.md „Conturile”); aici doar pașii:
//
//   înregistrare: startRegistration(prenume, nume, telefon) → cod prin SMS → confirmCode(cod)
//   intrare:      startSignIn("sms", telefon) sau startSignIn("email", email) → confirmCode(cod)
//   ieșire:       signOut();   ștergerea contului: deleteAccount()
//   numele:       updateName(prenume, nume) → nameUpdated
//   emailul:      startAddEmail(email) → cod pe email → confirmCode(cod) → emailAdded
//
// Paginile ascultă semnalele: codeSent (deschide pagina codului), signedInChanged
// (aplicația trece la portofel / la prima pagină), nameUpdated (pagina numelui se închide),
// emailAdded (pagina codului se întoarce la datele personale),
// requestFailed (eroarea, cu codul serverului, ca pagina să aleagă ce face, ex. dialogul
// la „phone_registered”).
//
// Tokenul se ține în QSettings (zona privată a aplicației) și pleacă la fiecare cerere prin
// ApiClient. De mutat în Keystore / Keychain înainte de publicare (docs/SCOP.md).
class SessionService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool signedIn READ signedIn NOTIFY signedInChanged)
    // O cerere e în drum spre server (butoanele arată rotița).
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

    // Contul, după intrare (get_account / register / login).
    Q_PROPERTY(QString firstName READ firstName NOTIFY accountChanged)
    Q_PROPERTY(QString lastName READ lastName NOTIFY accountChanged)
    Q_PROPERTY(QString phone READ phone NOTIFY accountChanged)      // +37360000002
    Q_PROPERTY(QString email READ email NOTIFY accountChanged)

    // Unde s-a trimis ultimul cod (telefonul sau emailul, pentru pagina codului) și pe ce cale.
    Q_PROPERTY(QString codeTarget READ codeTarget NOTIFY codeSent)
    Q_PROPERTY(QString codeChannel READ codeChannel NOTIFY codeSent)
    // Doar pe serverul de test: codul vine în răspuns (TEST_CODE), ca să nu fie căutat în jurnal.
    Q_PROPERTY(QString testCode READ testCode NOTIFY codeSent)
    // Peste câte secunde se poate cere alt cod.
    Q_PROPERTY(int resendAfter READ resendAfter NOTIFY codeSent)

public:
    explicit SessionService(QObject *parent = nullptr);

    bool signedIn() const;
    bool busy() const;
    QString firstName() const;
    QString lastName() const;
    QString phone() const;
    QString email() const;
    QString codeTarget() const;
    QString codeChannel() const;
    QString testCode() const;
    int resendAfter() const;

    // Cont nou: SMS cu cod pe telefon. force = omul a confirmat că numărul, deja al altui
    // cont, e acum al lui (după requestFailed("phone_registered", ...)).
    Q_INVOKABLE void startRegistration(const QString &firstName, const QString &lastName,
                                       const QString &phone, bool force = false);
    // Intrare: channel "sms" (target = telefonul) sau "email".
    Q_INVOKABLE void startSignIn(const QString &channel, const QString &target);
    // Emailul contului (din Profil): cod pe email, confirmat tot cu confirmCode. După asta se
    // poate intra în cont și cu emailul.
    Q_INVOKABLE void startAddEmail(const QString &email);
    // Verificarea adresei înainte de trimitere (aceeași regulă ca pe server: ceva@ceva.ceva):
    // "" dacă e bună, altfel textul erorii, deja tradus. Un câmp gol e „bun” (nimic de verificat).
    Q_INVOKABLE QString checkEmail(const QString &email) const;
    // Același cod încă o dată (după resendAfter).
    Q_INVOKABLE void resendCode();
    // Codul primit: termină înregistrarea, intrarea sau adăugarea emailului.
    Q_INVOKABLE void confirmCode(const QString &code);

    // Numele nou al contului (din Profil). Doar în cont: cardurile din Back rămân pe numele vechi.
    Q_INVOKABLE void updateName(const QString &firstName, const QString &lastName);

    Q_INVOKABLE void signOut();
    Q_INVOKABLE void deleteAccount();

signals:
    void signedInChanged();
    void busyChanged();
    void accountChanged();
    void codeSent();
    void nameUpdated();
    void emailAdded();
    // code: codul serverului ("code_invalid", "phone_registered"...) sau "network";
    // message: textul pentru om, deja tradus.
    void requestFailed(const QString &code, const QString &message);

private:
    enum class Purpose { Register, SignIn, AddEmail };

    void requestCode();
    void finishSession(const QJsonValue &data);
    void loadAccount();
    void setAccount(const QJsonObject &account);
    void clearSession();
    void setBusy(bool busy);
    void fail(const QString &code, const QJsonValue &data, bool network);
    QString messageFor(const QString &code, const QJsonValue &data) const;

    bool m_busy = false;
    QString m_token;
    QString m_firstName;
    QString m_lastName;
    QString m_phone;
    QString m_email;

    // Cererea de cod în curs
    Purpose m_purpose = Purpose::SignIn;
    QString m_channel;          // "sms" / "email"
    QString m_target;           // cum l-a scris omul
    QString m_pendingFirstName; // la înregistrare
    QString m_pendingLastName;
    bool m_force = false;
    QString m_requestId;
    QString m_codeTarget;
    QString m_testCode;
    int m_resendAfter = 0;
};
