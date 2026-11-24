import QtQuick
import QtQuick.Controls
import UnaLoyalty

// Placa unui card în „Cardurile mele”: localul, punctele, ultimele cifre ale codului.
// Câmpurile vin din rândul modelului (CardsModel), după nume.
AbstractButton {
    id: tile

    required property string localName
    required property real points
    required property string barcode

    implicitHeight: 190
    padding: Theme.spaceXl

    background: Rectangle {
        radius: Theme.radiusL
        color: tile.down ? Theme.primaryPressed : Theme.primary
    }

    contentItem: Item {
        Text {
            anchors { left: parent.left; top: parent.top; right: parent.right }
            text: tile.localName
            color: Theme.textOnPrimary
            font.pixelSize: Theme.fontHeading - 2
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Column {
            anchors { left: parent.left; bottom: parent.bottom }
            spacing: 2

            Text {
                text: qsTr("Puncte")
                color: Theme.textOnPrimaryMuted
                font.pixelSize: Theme.fontCaption
            }
            Text {
                // Punctele pot fi fracționare (5% din bon): zecimale doar când există.
                text: tile.points.toLocaleString(Qt.locale(), "f",
                                                 Number.isInteger(tile.points) ? 0 : 2)
                color: Theme.textOnPrimary
                font.pixelSize: 36
                font.weight: Font.Bold
            }
        }

        Text {
            anchors { right: parent.right; bottom: parent.bottom }
            // Doar ultimele 4 cifre; codul întreg apare pe cardul deschis.
            text: "•••• " + tile.barcode.slice(-4)
            color: Theme.textOnPrimaryMuted
            font.pixelSize: Theme.fontBody - 1
            font.letterSpacing: 1
        }
    }
}
