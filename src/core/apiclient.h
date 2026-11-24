#pragma once

#include <QJsonValue>
#include <QObject>
#include <QUrl>
#include <QVariantMap>

#include <functional>

class QNetworkAccessManager;
class QNetworkReply;

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

    // Adresa de bază a serverului, terminată cu "/": căile se adaugă după ea.
    QUrl baseUrl() const;
    void setBaseUrl(const QUrl &url);

    void get(const QString &path, const QVariantMap &params, Callback done);
    void post(const QString &path, const QVariantMap &params, Callback done);

private:
    void handle(QNetworkReply *reply, Callback done);

    QNetworkAccessManager *m_network;
    QUrl m_baseUrl;
};
