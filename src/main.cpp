#include <QGuiApplication>
#include <QQmlApplicationEngine>

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

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    // Main.qml din modulul UnaLoyalty (src/CMakeLists.txt); calea o știe Qt.
    engine.loadFromModule("UnaLoyalty", "Main");

    return app.exec();
}
