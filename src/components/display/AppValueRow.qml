import QtQuick
import QtQuick.Layouts
import UnaLoyalty

// Un rând „etichetă ... valoare”: eticheta la stânga (secundară), valoarea la dreapta
// (mare, îngroșată). Pentru sume și cifre pe o placă:
//   AppValueRow { label: qsTr("Points used"); value: "−" + Format.points(2.27) }
//   AppValueRow { label: qsTr("Cash"); value: Format.money(42.08) }
// Textul valorii îl formatează pagina; rândul doar îl arată.
RowLayout {
    id: row

    property string label
    property string value
    property color valueColor: Theme.textPrimary

    spacing: Theme.spaceM

    Text {
        Layout.fillWidth: true
        text: row.label
        color: Theme.textSecondary
        font.pixelSize: Theme.fontBody
        elide: Text.ElideRight
    }
    Text {
        text: row.value
        color: row.valueColor
        font.pixelSize: Theme.fontHeadingSmall
        font.weight: Font.Bold
    }
}
