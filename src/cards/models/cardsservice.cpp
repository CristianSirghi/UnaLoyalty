#include "cardsservice.h"

#include "auth/models/sessionservice.h"
#include "core/apiclient.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QPointer>
#include <QQmlEngine>

namespace {

// Culoarea cardului când serverul nu trimite una validă (Theme.primary din tema deschisă).
const QColor kDefaultBrandColor(0x51, 0x68, 0x94);

// Un card din răspunsul get_cards (docs/SCOP.md, „Serverul de test”).
Card cardFromJson(const QJsonObject &json)
{
    Card card;
    card.id = json.value(QLatin1String("ID")).toInt();
    card.localName = json.value(QLatin1String("LOCAL_NAME")).toString();
    card.points = json.value(QLatin1String("BONUS_POINTS")).toDouble();
    card.barcode = json.value(QLatin1String("BARCODE")).toString();
    card.brandColor = QColor(json.value(QLatin1String("BRAND_COLOR")).toString());
    if (!card.brandColor.isValid())
        card.brandColor = kDefaultBrandColor;
    card.bonusPercent = json.value(QLatin1String("BONUS_PRC")).toDouble();
    card.maxPayPercent = json.value(QLatin1String("MAX_BONUS_USE_PRC")).toDouble();
    return card;
}

} // namespace

CardsService::CardsService(QQmlEngine *engine, QObject *parent)
    : QObject(parent)
    , m_cards(new CardsModel(this))
{
    auto *session = engine ? engine->singletonInstance<SessionService *>("UnaLoyalty",
                                                                        "SessionService")
                           : nullptr;
    if (!session)
        return;

    // Alt cont, alte carduri: la intrare se cer din nou, la ieșire dispar.
    connect(session, &SessionService::signedInChanged, this, [this, session] {
        if (session->signedIn())
            loadCards();
        else
            m_cards->setCards({});
    });
    if (session->signedIn())
        loadCards();
}

CardsService *CardsService::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(jsEngine)
    return new CardsService(qmlEngine);
}

CardsModel *CardsService::cards() const
{
    return m_cards;
}

void CardsService::loadCards()
{
    // Cardurile persoanelor legate de cont; contul îl află serverul din token.
    ApiClient::instance()->command(
        QStringLiteral("get_cards"), {},
        [self = QPointer<CardsService>(this)](const ApiClient::Result &result) {
            if (!self)
                return;
            if (!result.ok) {
                qWarning() << "get_cards:" << result.error;
                return;
            }
            QList<Card> cards;
            const QJsonArray rows = result.data.toArray();
            for (const QJsonValue &row : rows)
                cards.append(cardFromJson(row.toObject()));
            self->m_cards->setCards(cards);
        });
}
