import QtQuick
import UnaLoyalty.Theme

Window {
    width: 400
    height: 800
    visible: true
    title: "UnaLoyalty"
    color: Theme.background

    // Conținutul stă în zona sigură (fără bara de stare și bara de navigare a
    // telefonului); fundalul ferestrei rămâne pe tot ecranul.
    Item {
        anchors {
            fill: parent
            topMargin: parent.SafeArea.margins.top
            leftMargin: parent.SafeArea.margins.left
            rightMargin: parent.SafeArea.margins.right
            bottomMargin: parent.SafeArea.margins.bottom
        }

        Text {
            anchors.centerIn: parent
            text: "UnaLoyalty"
            color: Theme.textPrimary
            font.pixelSize: Theme.fontTitle
            font.weight: Font.Bold
        }
    }
}
