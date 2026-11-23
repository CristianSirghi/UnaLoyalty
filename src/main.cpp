#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    // Modulele QML stau în resurse sub qrc:/qt/qml/, calea de import implicită din Qt 6.
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/UnaLoyalty/Main.qml")));

    return app.exec();
}
