import QtQuick
import QtQuick.Controls
import UnaLoyalty

// Cardurile mele: lista cardurilor clientului și „+ Adaugă card”.
// Deocamdată doar titlul; lista vine cu serviciul de carduri din C++.
Page {
    id: page
    title: qsTr("Cardurile mele")

    background: Rectangle { color: Theme.background }

    Label {
        anchors.centerIn: parent
        text: page.title
        color: Theme.textPrimary
        font.pixelSize: Theme.fontHeading
        font.weight: Font.Bold
    }
}
