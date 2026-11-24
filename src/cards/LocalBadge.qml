import QtQuick
import UnaLoyalty

// Cercul localului: inițiala numelui, albă, pe culoarea localului.
//   LocalBadge { localName: "Etalonus"; brandColor: "#516894" }
Rectangle {
    id: badge

    property string localName
    property color brandColor: Theme.primary

    implicitWidth: 36
    implicitHeight: 36
    radius: width / 2
    color: brandColor

    Text {
        anchors.centerIn: parent
        text: Format.initial(badge.localName)
        color: Theme.textOnPrimary
        font.pixelSize: Theme.fontBody + 1
        font.weight: Font.Bold
    }
}
