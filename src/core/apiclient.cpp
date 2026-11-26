#include "apiclient.h"

#include "serverconfig.h"

#include <QCoreApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QPointer>

namespace {

constexpr int kTimeoutMs = 15000;

// Codifică parametrii ca formular. Nu folosim QUrlQuery: el lasă "+" necodificat,
// iar PHP îl citește ca spațiu (un telefon "+373..." ar ajunge " 373...").
QByteArray formEncode(const QVariantMap &params)
{
    QByteArray out;
    for (auto it = params.cbegin(); it != params.cend(); ++it) {
        if (!out.isEmpty())
            out += '&';
        out += QUrl::toPercentEncoding(it.key()) + '='
               + QUrl::toPercentEncoding(it.value().toString());
    }
    return out;
}

ApiClient::Result failure(const QString &error, bool network = false)
{
    ApiClient::Result result;
    result.error = error;
    result.network = network;
    return result;
}

} // namespace

ApiClient::ApiClient(QObject *parent)
    : QObject(parent)
    , m_network(new QNetworkAccessManager(this))
{
}

ApiClient *ApiClient::instance()
{
    static QPointer<ApiClient> shared;
    if (!shared) {
        shared = new ApiClient(QCoreApplication::instance());
        shared->setBaseUrl(QUrl(ServerConfig::url()));
    }
    return shared;
}

void ApiClient::command(const QString &command, const QVariantMap &params, Callback done)
{
    QVariantMap all = params;
    all.insert(QStringLiteral("cmd"), command);
    // Adresa e chiar scriptul (.../etalonus_test.php), deci calea rămâne goală.
    get(QString(), all, std::move(done));
}

void ApiClient::commandPost(const QString &command, const QVariantMap &params, Callback done)
{
    if (m_baseUrl.isEmpty()) {
        done(failure(tr("Missing server address.")));
        return;
    }

    // Comanda rămâne în adresă (?cmd=), datele în corp.
    QUrl url = m_baseUrl;
    url.setQuery(QString::fromLatin1(formEncode({{QStringLiteral("cmd"), command}})));

    QNetworkRequest request(url);
    prepare(request);
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      QStringLiteral("application/x-www-form-urlencoded"));
    handle(m_network->post(request, formEncode(params)), std::move(done));
}

QString ApiClient::token() const
{
    return m_token;
}

void ApiClient::setToken(const QString &token)
{
    m_token = token;
}

void ApiClient::prepare(QNetworkRequest &request) const
{
    request.setTransferTimeout(kTimeoutMs);
    if (!m_token.isEmpty())
        request.setRawHeader("X-Loyalty-Token", m_token.toLatin1());
}

QUrl ApiClient::baseUrl() const
{
    return m_baseUrl;
}

void ApiClient::setBaseUrl(const QUrl &url)
{
    m_baseUrl = url;
}

void ApiClient::get(const QString &path, const QVariantMap &params, Callback done)
{
    if (m_baseUrl.isEmpty()) {
        done(failure(tr("Missing server address.")));
        return;
    }

    QUrl url = m_baseUrl.resolved(QUrl(path));
    url.setQuery(QString::fromLatin1(formEncode(params)));

    QNetworkRequest request(url);
    prepare(request);
    handle(m_network->get(request), std::move(done));
}

void ApiClient::post(const QString &path, const QVariantMap &params, Callback done)
{
    if (m_baseUrl.isEmpty()) {
        done(failure(tr("Missing server address.")));
        return;
    }

    QNetworkRequest request(m_baseUrl.resolved(QUrl(path)));
    prepare(request);
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      QStringLiteral("application/x-www-form-urlencoded"));
    handle(m_network->post(request, formEncode(params)), std::move(done));
}

void ApiClient::handle(QNetworkReply *reply, Callback done)
{
    connect(reply, &QNetworkReply::finished, this, [this, reply, done = std::move(done)]() {
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            done(failure(reply->errorString(), true));
            return;
        }

        QJsonParseError parseError;
        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll(), &parseError);
        if (parseError.error != QJsonParseError::NoError) {
            done(failure(tr("Invalid response from server.")));
            return;
        }

        // Serverul raportează erorile ca {"error": "..."}, nu prin cod HTTP.
        if (doc.isObject() && doc.object().contains(QLatin1String("error"))) {
            Result result = failure(doc.object().value(QLatin1String("error")).toString());
            result.data = doc.object();
            if (result.error.startsWith(QLatin1String("token_")))
                emit sessionRejected();
            done(result);
            return;
        }

        Result result;
        result.ok = true;
        result.data = doc.isArray() ? QJsonValue(doc.array()) : QJsonValue(doc.object());
        done(result);
    });
}
