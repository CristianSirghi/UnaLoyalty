#pragma once

#include <QJsonValue>
#include <QObject>
#include <QUrl>
#include <QVariantMap>

#include <functional>

class QNetworkAccessManager;
class QNetworkReply;
class QNetworkRequest;

// Singura piesă care vorbește cu serverul PHP (docs/SCOP.md). Serviciile o folosesc
// prin ApiClient::instance() și își știu singure comenzile:
//   ApiClient::instance()->command(QStringLiteral("get_profile"),
//                                  {{QStringLiteral("card"), card}},
//                                  [](const ApiClient::Result &r) { ... });
// Serverul răspunde mereu JSON; o eroare vine ca {"error": "..."} (Result.ok = false).
//
// Tokenul sesiunii (setToken, îl pune SessionService) pleacă la fiecare cerere în antetul
// X-Loyalty-Token. Când serverul îl refuză (token_invalid, token_expired, token_required),
// vine semnalul sessionRejected().
class ApiClient : public QObject
{
    Q_OBJECT

public:
    struct Result {
        bool ok = false;
        QJsonValue data;   // răspunsul; la eroare, tot obiectul (ex. RETRY_AFTER)
        QString error;     // ce n-a mers, când !ok: codul serverului sau textul rețelei
        bool network = false; // !ok din cauza rețelei, nu a serverului
    };
    using Callback = std::function<void(const Result &)>;

    explicit ApiClient(QObject *parent = nullptr);

    // Instanța comună a aplicației, cu adresa din ServerConfig. Se creează la prima
    // folosire și trăiește cât aplicația (părinte: QCoreApplication).
    static ApiClient *instance();

    // Adresa de bază a serverului, terminată cu "/": căile se adaugă după ea.
    QUrl baseUrl() const;
    void setBaseUrl(const QUrl &url);

    // O comandă a scriptului PHP (GET): adresa serverului + ?cmd=<command>&<params>.
    void command(const QString &command, const QVariantMap &params, Callback done);
    // La fel, dar parametrii pleacă în corpul unui POST (coduri, nume: nu în adresă,
    // care ajunge în jurnalele serverului).
    void commandPost(const QString &command, const QVariantMap &params, Callback done);

    QString token() const;
    void setToken(const QString &token);

    void get(const QString &path, const QVariantMap &params, Callback done);
    void post(const QString &path, const QVariantMap &params, Callback done);

signals:
    // Serverul a refuzat tokenul: sesiunea s-a terminat (ieșire pe alt telefon, expirare).
    void sessionRejected();

private:
    void handle(QNetworkReply *reply, Callback done);
    void prepare(QNetworkRequest &request) const;

    QNetworkAccessManager *m_network;
    QUrl m_baseUrl;
    QString m_token;
};
