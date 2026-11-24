import QtQuick

// Zona derulabilă (verticală) a paginilor. Toate paginile care se derulează o folosesc,
// ca derularea să se simtă la fel peste tot și să se regleze dintr-un singur loc.
//
// Viteza maximă: Qt (5 și 6, pe toate platformele) o plafonează la 2500 px/s, iar Android
// nativ permite cam 8000 dp/s; cu plafonul Qt, o aruncare rapidă cu degetul pornește mai
// „leneș” decât într-o aplicație nativă. Frânarea rămâne cea din Qt (1500, ca în Qt 5 /
// UnaWaiter). Verificat în codul Qt 6 (24.11.2026): pe Android valorile vin din tema de
// bază, fără reglaje proprii și fără scalare după densitate.
Flickable {
    boundsBehavior: Flickable.StopAtBounds
    clip: true
    maximumFlickVelocity: 8000
}
