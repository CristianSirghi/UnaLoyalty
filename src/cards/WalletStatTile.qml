import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import UnaLoyalty

// O placă mică sub card: o etichetă, o valoare mare și, opțional, o notă.
//   WalletStatTile { label: qsTr("Puncte disponibile"); value: "100" }
Item {
    id: tile

    property string label
    property string value
    property string note
    property color valueColor: Theme.textPrimary

    implicitWidth: content.implicitWidth + Theme.spaceL * 2
    implicitHeight: content.implicitHeight + Theme.spaceMPlus * 2

    RectangularShadow {
        anchors.fill: surface
        radius: surface.radius
        offset.y: 4
        blur: 14
        color: Theme.shadow
    }

    Rectangle {
        id: surface
        anchors.fill: parent
        radius: Theme.radiusM
        color: Theme.surface
    }

    ColumnLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: Theme.spaceL
            rightMargin: Theme.spaceL
            topMargin: Theme.spaceMPlus
        }
        spacing: Theme.spaceXs

        Text {
            Layout.fillWidth: true
            text: tile.label
            color: Theme.textSecondary
            font.pixelSize: Theme.fontCaption
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            text: tile.value
            color: tile.valueColor
            font.pixelSize: Theme.fontTitle
            font.weight: Font.Bold
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            visible: tile.note !== ""
            text: tile.note
            color: Theme.textSecondary
            font.pixelSize: Theme.fontSmall
            wrapMode: Text.WordWrap
        }
    }
}
