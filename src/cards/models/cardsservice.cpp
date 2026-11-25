#include "cardsservice.h"

#include "core/apiclient.h"
#include "core/serverconfig.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QPointer>

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

CardsService::CardsService(QObject *parent)
    : QObject(parent)
    , m_cards(new CardsModel(this))
{
    loadCards();
}

CardsModel *CardsService::cards() const
{
    return m_cards;
}

void CardsService::loadCards()
{
    // Cât nu există intrarea în cont: cardurile titularului cardului de test.
    ApiClient::instance()->command(
        QStringLiteral("get_cards"),
        {{QStringLiteral("card"), ServerConfig::testCard()}},
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
