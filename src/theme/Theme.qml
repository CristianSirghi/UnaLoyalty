pragma Singleton
import QtQuick

// Valorile generale ale aplicației. Ecranele și componentele iau culorile, fonturile
// și spațiile doar de aici: o schimbare de culoare se face într-un singur loc.
QtObject {
    // "auto" urmează telefonul; "light" / "dark" îl ignoră.
    property string mode: "auto"
    readonly property bool dark: mode === "dark"
                                 || (mode === "auto"
                                     && Application.styleHints.colorScheme === Qt.ColorScheme.Dark)

    // Culori (light: din schema ecranelor; dark: provizorii, de la UnaWaiter)
    readonly property color background:    dark ? "#15171B" : "#F3F5F8"
    readonly property color surface:       dark ? "#1E2128" : "#FFFFFF"
    readonly property color surfaceMuted:  dark ? "#282B33" : "#E9EDF2"
    readonly property color border:        dark ? "#2A2D33" : "#E1E4E8"
    readonly property color textPrimary:   dark ? "#F0F1F3" : "#1B1F24"
    readonly property color textSecondary: dark ? "#9AA0A8" : "#5F6B7A"
    readonly property color primary:       dark ? "#54A0EB" : "#516894"
    readonly property color primaryPressed: dark ? "#3F8AD6" : "#3E5378"
    // Text pe fundal primary. Fără prefixul "on": QML ia onX drept handler de semnal.
    readonly property color textOnPrimary:      "#FFFFFF"
    readonly property color textOnPrimaryMuted: "#E3E9F4"
    readonly property color danger:        dark ? "#E57373" : "#C62828"

    // Cardul din portofel: mereu alb, ca un card fizic (și QR-ul cere fond alb),
    // deci culorile lui nu se schimbă în tema întunecată.
    readonly property color cardSurface:       "#FFFFFF"
    readonly property color cardText:          "#1B1F24"
    readonly property color cardTextSecondary: "#5F6B7A"

    // Umbra plăcilor (cardul, plăcile cu puncte)
    readonly property color shadow: dark ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0.06, 0.09, 0.16, 0.16)

    // Fonturi (px)
    readonly property int fontTitle: 28
    readonly property int fontHeading: 22
    readonly property int fontBody: 15
    readonly property int fontCaption: 13
    readonly property int fontSmall: 12

    // Spații (px)
    readonly property int spaceXs: 4
    readonly property int spaceS: 8
    readonly property int spaceM: 12
    readonly property int spaceL: 16
    readonly property int spaceXl: 20
    readonly property int spaceXxl: 24

    // Colțuri (px)
    readonly property int radiusS: 12
    readonly property int radiusM: 16
    readonly property int radiusL: 20

    // Înălțimea minimă a unei zone apăsabile
    readonly property int touchTarget: 44
}
