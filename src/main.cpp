#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    // Main.qml din modulul UnaLoyalty (src/CMakeLists.txt); calea o știe Qt.
    engine.loadFromModule("UnaLoyalty", "Main");

    return app.exec();
}
