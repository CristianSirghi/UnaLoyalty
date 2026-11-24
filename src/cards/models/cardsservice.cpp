#include "cardsservice.h"

CardsService::CardsService(QObject *parent)
    : QObject(parent)
    , m_cards(new CardsModel(this))
{
    // Date de exemplu: cardurile de test Etalonus de pe casa de test
    // (docs/INSTRUCTIUNE_LOIALITATE_UAMENU.md). Se înlocuiesc cu răspunsul serverului.
    m_cards->setCards({
        { 1, QStringLiteral("Etalonus"), 0,   QStringLiteral("2803990000016") },
        { 2, QStringLiteral("Etalonus"), 100, QStringLiteral("2803990000023") },
    });
}

CardsModel *CardsService::cards() const
{
    return m_cards;
}
