#include "apiclient.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>

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

ApiClient::Result failure(const QString &error)
{
    ApiClient::Result result;
    result.error = error;
    return result;
}

} // namespace

ApiClient::ApiClient(QObject *parent)
    : QObject(parent)
    , m_network(new QNetworkAccessManager(this))
{
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
    request.setTransferTimeout(kTimeoutMs);
    handle(m_network->get(request), std::move(done));
}

void ApiClient::post(const QString &path, const QVariantMap &params, Callback done)
{
    if (m_baseUrl.isEmpty()) {
        done(failure(tr("Missing server address.")));
        return;
    }

    QNetworkRequest request(m_baseUrl.resolved(QUrl(path)));
    request.setTransferTimeout(kTimeoutMs);
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      QStringLiteral("application/x-www-form-urlencoded"));
    handle(m_network->post(request, formEncode(params)), std::move(done));
}

void ApiClient::handle(QNetworkReply *reply, Callback done)
{
    connect(reply, &QNetworkReply::finished, this, [reply, done = std::move(done)]() {
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            done(failure(reply->errorString()));
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
            done(failure(doc.object().value(QLatin1String("error")).toString()));
            return;
        }

        Result result;
        result.ok = true;
        result.data = doc.isArray() ? QJsonValue(doc.array()) : QJsonValue(doc.object());
        done(result);
    });
}
