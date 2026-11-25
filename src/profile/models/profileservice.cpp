#include "profileservice.h"

#include <QCoreApplication>
#include <QLocale>
#include <QQmlEngine>
#include <QSettings>
#include <QStringList>

namespace {

// Cheia din QSettings unde stă limba aleasă de client.
const auto kLanguageKey = QStringLiteral("language");

// Limbile aplicației. Pentru orice altceva: engleza, limba textelor din cod.
bool isSupported(const QString &language)
{
    return language == u"ro" || language == u"ru" || language == u"en";
}

// Limba telefonului, redusă la una din cele trei.
QString systemLanguage()
{
    switch (QLocale::system().language()) {
    case QLocale::Romanian:
        return QStringLiteral("ro");
    case QLocale::Russian:
        return QStringLiteral("ru");
    default:
        return QStringLiteral("en");
    }
}

// După QLocale-ul implicit se formatează numerele și banii (Format): virgulă
// zecimală în română și rusă, punct în engleză.
QLocale localeFor(const QString &language)
{
    if (language == u"ro")
        return QLocale(QLocale::Romanian, QLocale::Moldova);
    if (language == u"ru")
        return QLocale(QLocale::Russian, QLocale::Moldova);
    return QLocale(QLocale::English, QLocale::UnitedStates);
}

} // namespace

ProfileService::ProfileService(QQmlEngine *engine, QObject *parent)
    : QObject(parent)
    , m_engine(engine)
    // Date de test: titularul cardurilor de test Etalonus. Telefonul e inventat.
    // Se înlocuiesc cu răspunsul serverului.
    , m_name(QStringLiteral("Test Loialitate 2"))
    , m_phone(QStringLiteral("+373 60 000 000"))
{
    const QString saved = QSettings().value(kLanguageKey).toString();
    m_language = isSupported(saved) ? saved : systemLanguage();
    applyLanguage();
}

ProfileService *ProfileService::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(jsEngine)
    return new ProfileService(qmlEngine);
}

QString ProfileService::name() const
{
    return m_name;
}

QString ProfileService::phone() const
{
    return m_phone;
}

QString ProfileService::initials() const
{
    // Prima literă din primele două cuvinte care încep cu o literă
    // (cifrele, ca „2” din numele de test, nu intră).
    QString result;
    const QStringList words = m_name.split(QLatin1Char(' '), Qt::SkipEmptyParts);
    for (const QString &word : words) {
        if (word.front().isLetter())
            result += word.front().toUpper();
        if (result.size() == 2)
            break;
    }
    return result;
}

QString ProfileService::language() const
{
    return m_language;
}

void ProfileService::setLanguage(const QString &language)
{
    if (!isSupported(language) || language == m_language)
        return;

    m_language = language;
    // Se ține minte doar limba aleasă de client; cât n-a ales, urmează telefonul.
    QSettings().setValue(kLanguageKey, m_language);
    applyLanguage();
    emit languageChanged();
}

void ProfileService::applyLanguage()
{
    // Traducerea: i18n/unaloyalty_<limba>.ts, ajunsă în aplicație sub :/i18n.
    // Engleza are și ea fișier, doar pentru formele de plural.
    QCoreApplication::removeTranslator(&m_translator);
    if (m_translator.load(QStringLiteral("unaloyalty_") + m_language, QStringLiteral(":/i18n")))
        QCoreApplication::installTranslator(&m_translator);

    QLocale::setDefault(localeFor(m_language));

    // Textele deja afișate (qsTr) se refac în limba nouă.
    if (m_engine)
        m_engine->retranslate();
}
