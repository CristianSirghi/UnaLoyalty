#include "cardsservice.h"

CardsService::CardsService(QObject *parent)
    : QObject(parent)
    , m_cards(new CardsModel(this))
{
    // Date de exemplu: cardurile de test Etalonus de pe casa de test
    // (docs/INSTRUCTIUNE_LOIALITATE_UAMENU.md), cu regulile tipului de card de test
    // (5% bonus, plată cu puncte până la 50%). Al doilea e tot un card de test Etalonus,
    // afișat ca „[Alt local]” ca să se vadă portofelul cu mai multe localuri.
    // Se înlocuiesc cu răspunsul serverului.
    m_cards->setCards({
        { 2, QStringLiteral("Etalonus"),    100, QStringLiteral("2803990000023"),
          QColor(0x51, 0x68, 0x94), 5, 50 },
        { 1, QStringLiteral("[Alt local]"), 0,   QStringLiteral("2803990000016"),
          QColor(0x2F, 0x7A, 0x68), 0, 0 },
    });
}

CardsModel *CardsService::cards() const
{
    return m_cards;
}
