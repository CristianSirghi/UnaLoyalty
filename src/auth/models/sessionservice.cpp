#include "sessionservice.h"

#include "core/apiclient.h"

#include <QDebug>
#include <QJsonObject>
#include <QPointer>
#include <QSettings>
#include <QSysInfo>

namespace {

// Cheia din QSettings unde stă tokenul sesiunii.
const auto kTokenKey = QStringLiteral("session/token");

// Ce telefon a intrat (pentru lista sesiunilor de pe server): „Android 14”, „Windows 11”.
QString deviceName()
{
    return QSysInfo::prettyProductName().left(100);
}

} // namespace

SessionService::SessionService(QObject *parent)
    : QObject(parent)
{
    // Serverul a refuzat tokenul (expirat, ieșire, cont șters): înapoi la prima pagină.
    connect(ApiClient::instance(), &ApiClient::sessionRejected, this, [this] {
        if (!m_token.isEmpty())
            clearSession();
    });

    m_token = QSettings().value(kTokenKey).toString();
    if (!m_token.isEmpty()) {
        ApiClient::instance()->setToken(m_token);
        loadAccount();
    }
}

bool SessionService::signedIn() const { return !m_token.isEmpty(); }
bool SessionService::busy() const { return m_busy; }
QString SessionService::firstName() const { return m_firstName; }
QString SessionService::lastName() const { return m_lastName; }
QString SessionService::phone() const { return m_phone; }
QString SessionService::email() const { return m_email; }
QString SessionService::codeTarget() const { return m_codeTarget; }
QString SessionService::codeChannel() const { return m_channel; }
QString SessionService::testCode() const { return m_testCode; }
int SessionService::resendAfter() const { return m_resendAfter; }

void SessionService::startRegistration(const QString &firstName, const QString &lastName,
                                       const QString &phone, bool force)
{
    m_purpose = Purpose::Register;
    m_channel = QStringLiteral("sms");
    m_target = phone.trimmed();
    m_pendingFirstName = firstName.trimmed();
    m_pendingLastName = lastName.trimmed();
    m_force = force;

    if (m_pendingFirstName.isEmpty() || m_pendingLastName.isEmpty()) {
        fail(QStringLiteral("name_invalid"), {}, false);
        return;
    }
    requestCode();
}

void SessionService::startSignIn(const QString &channel, const QString &target)
{
    m_purpose = Purpose::SignIn;
    m_channel = channel == u"email" ? QStringLiteral("email") : QStringLiteral("sms");
    m_target = target.trimmed();
    m_force = false;
    requestCode();
}

void SessionService::resendCode()
{
    requestCode();
}

void SessionService::requestCode()
{
    if (m_busy)
        return;
    setBusy(true);

    QVariantMap params{
        {QStringLiteral("channel"), m_channel},
        {QStringLiteral("target"), m_target},
        {QStringLiteral("purpose"), m_purpose == Purpose::Register ? QStringLiteral("register")
                                                                   : QStringLiteral("login")},
    };
    if (m_force)
        params.insert(QStringLiteral("force"), QStringLiteral("1"));

    ApiClient::instance()->commandPost(
        QStringLiteral("request_code"), params,
        [self = QPointer<SessionService>(this)](const ApiClient::Result &result) {
            if (!self)
                return;
            self->setBusy(false);
            if (!result.ok) {
                self->fail(result.error, result.data, result.network);
                return;
            }
            // {"REQUEST_ID":123,"RESEND_AFTER":60,"TEST_CODE":"123456"}
            const QJsonObject answer = result.data.toObject();
            self->m_requestId = QString::number(answer.value(QLatin1String("REQUEST_ID")).toInteger());
            self->m_resendAfter = answer.value(QLatin1String("RESEND_AFTER")).toInt(60);
            self->m_testCode = answer.value(QLatin1String("TEST_CODE")).toString();
            self->m_codeTarget = self->m_target;
            emit self->codeSent();
        });
}

void SessionService::confirmCode(const QString &code)
{
    if (m_busy || m_requestId.isEmpty())
        return;
    setBusy(true);

    QVariantMap params{
        {QStringLiteral("request_id"), m_requestId},
        {QStringLiteral("code"), code.trimmed()},
        {QStringLiteral("device"), deviceName()},
    };
    QString command = QStringLiteral("login");
    if (m_purpose == Purpose::Register) {
        command = QStringLiteral("register");
        params.insert(QStringLiteral("first_name"), m_pendingFirstName);
        params.insert(QStringLiteral("last_name"), m_pendingLastName);
    }

    ApiClient::instance()->commandPost(
        command, params,
        [self = QPointer<SessionService>(this)](const ApiClient::Result &result) {
            if (!self)
                return;
            self->setBusy(false);
            if (!result.ok) {
                self->fail(result.error, result.data, result.network);
                return;
            }
            self->finishSession(result.data);
        });
}

// Răspunsul la register / login: {"TOKEN":"...","ACCOUNT":{...}}
void SessionService::finishSession(const QJsonValue &data)
{
    const QJsonObject answer = data.toObject();
    const QString token = answer.value(QLatin1String("TOKEN")).toString();
    if (token.isEmpty()) {
        fail(QStringLiteral("server_error"), {}, false);
        return;
    }

    m_token = token;
    QSettings().setValue(kTokenKey, m_token);
    ApiClient::instance()->setToken(m_token);

    m_requestId.clear();
    m_testCode.clear();
    m_pendingFirstName.clear();
    m_pendingLastName.clear();

    setAccount(answer.value(QLatin1String("ACCOUNT")).toObject());
    emit signedInChanged();
}

// La pornire, cu tokenul salvat: numele și telefonul de pe server. Fără rețea rămânem în
// cont (tokenul poate fi încă bun); un token refuzat vine prin sessionRejected.
void SessionService::loadAccount()
{
    ApiClient::instance()->commandPost(
        QStringLiteral("get_account"), {},
        [self = QPointer<SessionService>(this)](const ApiClient::Result &result) {
            if (!self)
                return;
            if (!result.ok) {
                qWarning() << "get_account:" << result.error;
                return;
            }
            self->setAccount(result.data.toObject());
        });
}

void SessionService::setAccount(const QJsonObject &account)
{
    m_firstName = account.value(QLatin1String("FIRST_NAME")).toString();
    m_lastName = account.value(QLatin1String("LAST_NAME")).toString();
    m_phone = account.value(QLatin1String("PHONE")).toString();
    m_email = account.value(QLatin1String("EMAIL")).toString();
    emit accountChanged();
}

void SessionService::signOut()
{
    if (m_token.isEmpty())
        return;
    // Serverul șterge sesiunea; telefonul iese oricum, chiar fără rețea.
    ApiClient::instance()->commandPost(QStringLiteral("logout"), {},
                                       [](const ApiClient::Result &result) {
                                           if (!result.ok)
                                               qWarning() << "logout:" << result.error;
                                       });
    clearSession();
}

void SessionService::deleteAccount()
{
    if (m_busy || m_token.isEmpty())
        return;
    setBusy(true);
    ApiClient::instance()->commandPost(
        QStringLiteral("delete_account"), {},
        [self = QPointer<SessionService>(this)](const ApiClient::Result &result) {
            if (!self)
                return;
            self->setBusy(false);
            if (!result.ok) {
                self->fail(result.error, result.data, result.network);
                return;
            }
            self->clearSession();
        });
}

void SessionService::clearSession()
{
    m_token.clear();
    QSettings().remove(kTokenKey);
    ApiClient::instance()->setToken(QString());
    setAccount(QJsonObject());
    emit signedInChanged();
}

void SessionService::setBusy(bool busy)
{
    if (m_busy == busy)
        return;
    m_busy = busy;
    emit busyChanged();
}

void SessionService::fail(const QString &code, const QJsonValue &data, bool network)
{
    const QString key = network ? QStringLiteral("network") : code;
    if (network || !code.startsWith(QLatin1String("token_")))
        qWarning() << "SessionService:" << code;
    emit requestFailed(key, messageFor(key, data));
}

// Textul pentru om, după codul serverului (oracle_loyalty.php / PG_LOYALTY).
QString SessionService::messageFor(const QString &code, const QJsonValue &data) const
{
    const int retry = data.toObject().value(QLatin1String("RETRY_AFTER")).toInt();
    const bool byEmail = m_channel == u"email";

    if (code == u"network")
        return tr("No connection to the server. Check the internet and try again.");
    if (code == u"phone_invalid")
        return tr("Check the phone number.");
    if (code == u"email_invalid")
        return tr("Check the email address.");
    if (code == u"name_invalid")
        return tr("Enter your first and last name.");
    if (code == u"account_not_found")
        return byEmail ? tr("There is no account with this email.")
                       : tr("There is no account with this phone number.");
    if (code == u"phone_registered")
        return tr("This phone number already has an account.");
    if (code == u"email_taken")
        return tr("This email belongs to another account.");
    if (code == u"too_soon")
        return tr("Wait %n second(s) before asking for a new code.", nullptr, retry);
    if (code == u"too_many")
        return tr("Too many codes. Try again in %n minute(s).", nullptr, (retry + 59) / 60);
    if (code == u"code_invalid")
        return tr("Wrong code. Check it and try again.");
    if (code == u"code_expired")
        return tr("The code has expired. Ask for a new one.");
    if (code == u"code_attempts")
        return tr("Too many wrong attempts. Ask for a new code.");
    if (code.startsWith(QLatin1String("token_")))
        return tr("Your session has ended. Sign in again.");
    if (code == u"sms_not_configured" || code == u"email_not_configured")
        return tr("Sending codes isn't available yet.");
    return tr("Something went wrong on the server. Try again later.");
}
