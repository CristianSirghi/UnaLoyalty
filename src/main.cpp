#include <QGuiApplication>
#include <QLocale>
#include <QQmlApplicationEngine>
#include <QTranslator>

int main(int argc, char *argv[])
{
#ifdef Q_OS_ANDROID
    // Desenare prin TextureView, nu prin SurfaceView (decis 24.11.2026, vezi
    // docs/SCOP.md, „Fluiditate pe Android”).
    // Implicit (0), Qt 6.12 desenează pe Android 10+ într-o SurfaceView cu o
    // sub-suprafață proprie: trei straturi pe tot ecranul, compuse prin GPU. Pe un
    // Galaxy A51, derularea se simțea în urma degetului. Orice altă valoare =
    // TextureView: un singur strat, în ritmul ferestrei Android; pe același telefon
    // derularea se simte mult mai fluidă. Se poate suprascrie din afară (variabila
    // setată deja), de ex. pentru comparații.
    if (!qEnvironmentVariableIsSet("QT_ANDROID_SURFACE_CONTAINER_TYPE"))
        qputenv("QT_ANDROID_SURFACE_CONTAINER_TYPE", "1");
#endif

    QGuiApplication app(argc, argv);

    // Limba: după telefon (ex. ro-MD → unaloyalty_ro.qm, ru → unaloyalty_ru.qm). Pentru
    // orice altă limbă nu se găsește nimic și rămân textele din cod, în engleză.
    QTranslator translator;
    if (translator.load(QLocale(), QStringLiteral("unaloyalty"), QStringLiteral("_"),
                        QStringLiteral(":/i18n")))
        app.installTranslator(&translator);

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    // Main.qml din modulul UnaLoyalty (CMakeLists.txt); calea o știe Qt.
    engine.loadFromModule("UnaLoyalty", "Main");

    return app.exec();
}
