import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import UnaLoyalty

// Un card din portofel: localul, codul QR (gata de scanat la casă) și codul întreg.
// Câmpurile vin din rândul modelului (CardsModel), după nume.
Item {
    id: card

    required property int cardId
    required property string localName
    required property real points
    required property string barcode
    required property color brandColor
    required property real bonusPercent
    required property real maxPayPercent

    // Clientul vrea codul mărit (atinge QR-ul sau iconița de mărire).
    signal showCodeRequested()

    implicitWidth: 300
    implicitHeight: content.implicitHeight + Theme.spaceL + Theme.spaceLPlus

    RectangularShadow {
        anchors.fill: surface
        radius: surface.radius
        offset.y: 10
        blur: 28
        color: Theme.shadow
    }

    Rectangle {
        id: surface
        anchors.fill: parent
        radius: Theme.radiusL
        color: Theme.cardSurface
    }

    ColumnLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: Theme.spaceLPlus
            rightMargin: Theme.spaceLPlus
            topMargin: Theme.spaceL
        }
        spacing: Theme.spaceSPlus

        // Localul: inițiala în culoarea lui, numele, butonul de mărire
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spaceSPlus

            LocalBadge {
                localName: card.localName
                brandColor: card.brandColor
            }
            Text {
                Layout.fillWidth: true
                text: card.localName
                color: Theme.cardText
                font.pixelSize: Theme.fontSubheading
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            AppIconButton {
                Layout.rightMargin: -Theme.spaceSPlus
                text: qsTr("Mărește codul")
                iconPath: "M 15 3 H 21 V 9 M 9 21 H 3 V 15 M 21 3 L 14 10 M 3 21 L 10 14"
                iconSize: 20
                iconColor: Theme.cardTextSecondary
                pressedColor: Theme.cardSurfaceMuted
                onClicked: card.showCodeRequested()
            }
        }

        // Codul QR: atingerea îl mărește pe tot ecranul
        AbstractButton {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 168
            implicitHeight: 168
            Accessible.name: qsTr("Codul QR al cardului; atinge ca să-l mărești")
            onClicked: card.showCodeRequested()

            contentItem: AppQrCode {
                text: card.barcode
            }
            background: null
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: card.barcode
            color: Theme.cardText
            font.pixelSize: Theme.fontBody
            font.weight: Font.Medium
            font.letterSpacing: 1.5
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Atinge codul ca să-l mărești la casă")
            color: Theme.cardTextSecondary
            font.pixelSize: Theme.fontSmall
        }
    }
}
