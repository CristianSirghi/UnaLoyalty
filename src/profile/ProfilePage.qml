import QtQuick
import QtQuick.Controls
import UnaLoyalty

// Profil: nume, telefon, limba, despre aplicație, ieșire, ștergerea contului.
// Deocamdată doar titlul.
Page {
    id: page
    title: qsTr("Profil")

    background: Rectangle { color: Theme.background }

    Label {
        anchors.centerIn: parent
        text: page.title
        color: Theme.textPrimary
        font.pixelSize: Theme.fontHeading
        font.weight: Font.Bold
    }
}
