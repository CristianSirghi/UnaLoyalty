#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "profile/models/profileservice.h"

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
    // Pentru QSettings (ex. limba aleasă în Profil). Pe Windows ajung în registru,
    // sub HKCU\Software\UNA\UnaLoyalty; pe Android, în fișierele aplicației.
    QCoreApplication::setOrganizationName(QStringLiteral("UNA"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("una.md"));
    // Numele și versiunea (pagina „About the app”: Qt.application.name / .version).
    // Versiunea vine din project(... VERSION ...) în CMakeLists.txt.
    QCoreApplication::setApplicationName(QStringLiteral("UnaLoyalty"));
    QCoreApplication::setApplicationVersion(QStringLiteral(APP_VERSION));

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    // Limba: o alege ProfileService (cea salvată, altfel a telefonului). Îl cerem
    // înainte de Main.qml, ca primul ecran să apară direct în limba bună.
    engine.singletonInstance<ProfileService *>("UnaLoyalty", "ProfileService");

    // Main.qml din modulul UnaLoyalty (CMakeLists.txt); calea o știe Qt.
    engine.loadFromModule("UnaLoyalty", "Main");

    return app.exec();
}
