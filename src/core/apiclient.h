#pragma once

#include <QJsonValue>
#include <QObject>
#include <QUrl>
#include <QVariantMap>

#include <functional>

class QNetworkAccessManager;
class QNetworkReply;

// Singura piesă care vorbește cu serverul PHP (docs/SCOP.md). Serviciile o folosesc
// prin ApiClient::instance() și își știu singure comenzile:
//   ApiClient::instance()->command(QStringLiteral("get_profile"),
//                                  {{QStringLiteral("card"), card}},
//                                  [](const ApiClient::Result &r) { ... });
// Serverul răspunde mereu JSON; o eroare vine ca {"error": "..."} (Result.ok = false).
class ApiClient : public QObject
{
    Q_OBJECT

public:
    struct Result {
        bool ok = false;
        QJsonValue data;   // răspunsul, când ok
        QString error;     // ce n-a mers, când !ok
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

    void get(const QString &path, const QVariantMap &params, Callback done);
    void post(const QString &path, const QVariantMap &params, Callback done);

private:
    void handle(QNetworkReply *reply, Callback done);

    QNetworkAccessManager *m_network;
    QUrl m_baseUrl;
};
