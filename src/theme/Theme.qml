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
    readonly property color cardSurfaceMuted:  "#E9EDF2"   // butoane rotunde pe card
    readonly property color cardSurfacePressed: "#D5DBE3"
    readonly property color cardText:          "#1B1F24"
    readonly property color cardTextSecondary: "#5F6B7A"

    // Pe banda colorată a portofelului (culoarea localului): alb transparent, ca să se
    // potrivească pe orice culoare de local.
    readonly property color bandOutline:        Qt.rgba(1, 1, 1, 0.65) // contur punctat
    readonly property color bandIndicator:      Qt.rgba(1, 1, 1, 0.5)  // punctele de pagină inactive
    readonly property color bandOverlay:        Qt.rgba(1, 1, 1, 0.12) // fond de placă
    readonly property color bandOverlayStrong:  Qt.rgba(1, 1, 1, 0.22) // apăsat; cercul cu „+”

    // Umbra plăcilor (cardul, plăcile cu puncte)
    readonly property color shadow: dark ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0.06, 0.09, 0.16, 0.16)

    // Fonturi (px), de la mare la mic
    readonly property int fontTitle: 28          // valori mari (punctele de pe placă)
    readonly property int fontHeadingLarge: 24   // titlul portofelului, pe bandă
    readonly property int fontHeading: 22        // titlul paginilor; codul mărit
    readonly property int fontHeadingSmall: 20   // punctele din detaliul bonului
    readonly property int fontSubheading: 18     // titluri de secțiune, numele localului, totalul
    readonly property int fontBodyLarge: 16      // text evidențiat (titlul unui mesaj)
    readonly property int fontBody: 15           // textul obișnuit
    readonly property int fontBodySmall: 14      // explicații sub un titlu
    readonly property int fontCaption: 13        // etichete, date
    readonly property int fontSmall: 12          // cel mai mic text (bara de jos, note)

    // Spații (px). Treptele „Plus” sunt la jumătatea dintre două trepte (ex. spaceSPlus
    // = 10, între 8 și 12), pentru spațiile din interiorul plăcilor și rândurilor.
    readonly property int spaceXxs: 2            // între rânduri de text lipite
    readonly property int spaceXs: 4
    readonly property int spaceXsPlus: 6
    readonly property int spaceS: 8
    readonly property int spaceSPlus: 10
    readonly property int spaceM: 12
    readonly property int spaceMPlus: 14
    readonly property int spaceL: 16
    readonly property int spaceLPlus: 18
    readonly property int spaceXl: 20
    readonly property int spaceXxl: 24

    // Colțuri (px)
    readonly property int radiusS: 12
    readonly property int radiusM: 16
    readonly property int radiusL: 20

    // Înălțimea minimă a unei zone apăsabile
    readonly property int touchTarget: 44
}
