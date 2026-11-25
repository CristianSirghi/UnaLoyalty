#include "profileservice.h"

#include "core/apiclient.h"
#include "core/serverconfig.h"

#include <QCoreApplication>
#include <QDebug>
#include <QJsonObject>
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
{
    const QString saved = QSettings().value(kLanguageKey).toString();
    m_language = isSupported(saved) ? saved : systemLanguage();
    applyLanguage();

    loadProfile();
}

void ProfileService::loadProfile()
{
    ApiClient::instance()->command(
        QStringLiteral("get_profile"),
        {{QStringLiteral("card"), ServerConfig::testCard()}},
        [self = QPointer<ProfileService>(this)](const ApiClient::Result &result) {
            if (!self)
                return;
            if (!result.ok) {
                qWarning() << "get_profile:" << result.error;
                return;
            }
            // Răspunsul: {"FIRST_NAME": ..., "LAST_NAME": ..., "PHONE": ...}
            const QJsonObject person = result.data.toObject();
            self->m_firstName = person.value(QLatin1String("FIRST_NAME")).toString().trimmed();
            self->m_lastName = person.value(QLatin1String("LAST_NAME")).toString().trimmed();
            self->m_phone = person.value(QLatin1String("PHONE")).toString().trimmed();
            emit self->profileChanged();
        });
}

ProfileService *ProfileService::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(jsEngine)
    return new ProfileService(qmlEngine);
}

QString ProfileService::name() const
{
    // Unul din ele poate lipsi: atunci fără spațiu în plus.
    return QStringList{m_firstName, m_lastName}.join(QLatin1Char(' ')).trimmed();
}

QString ProfileService::phone() const
{
    return m_phone;
}

QString ProfileService::initials() const
{
    // Prima literă din prenume și prima din nume („Ana Maria” + „Popescu” → „AP”).
    QString result;
    for (const QString &part : {m_firstName, m_lastName}) {
        for (const QChar c : part) {
            if (c.isLetter()) {
                result += c.toUpper();
                break;
            }
        }
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
