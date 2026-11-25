import QtQuick
import QtQuick.Layouts
import UnaLoyalty

// Antetul paginilor deschise peste altele: săgeata „înapoi” și titlul.
// Se pune primul într-un ColumnLayout al paginii; pagina decide ce face „înapoi”:
//   AppPageHeader {
//       Layout.fillWidth: true
//       title: page.title
//       onBackClicked: page.StackView.view.pop()
//   }
RowLayout {
    id: header

    property string title

    signal backClicked()

    // Zona de apăsare a săgeții e mai lată decât săgeata: o tragem spre stânga, ca
    // săgeata să stea pe aceeași linie cu marginea conținutului de dedesubt.
    Layout.leftMargin: -Theme.spaceM
    spacing: Theme.spaceXs

    AppBackButton {
        onClicked: header.backClicked()
    }
    Text {
        Layout.fillWidth: true
        text: header.title
        color: Theme.textPrimary
        font.pixelSize: Theme.fontHeading
        font.weight: Font.Bold
        elide: Text.ElideRight
    }
}
