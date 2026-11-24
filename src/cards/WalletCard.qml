import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
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
    implicitHeight: content.implicitHeight + Theme.spaceL + Theme.spaceL + 2

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
            leftMargin: Theme.spaceL + 2
            rightMargin: Theme.spaceL + 2
            topMargin: Theme.spaceL
        }
        spacing: Theme.spaceS + 2

        // Localul: inițiala în culoarea lui, numele, butonul de mărire
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spaceS + 2

            LocalBadge {
                localName: card.localName
                brandColor: card.brandColor
            }
            Text {
                Layout.fillWidth: true
                text: card.localName
                color: Theme.cardText
                font.pixelSize: Theme.fontBody + 2
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            AbstractButton {
                id: expandButton
                Layout.rightMargin: -Theme.spaceS - 2
                implicitWidth: Theme.touchTarget
                implicitHeight: Theme.touchTarget
                Accessible.name: qsTr("Mărește codul")
                onClicked: card.showCodeRequested()

                background: Rectangle {
                    radius: width / 2
                    color: expandButton.down ? Theme.cardSurfaceMuted : "transparent"
                }
                contentItem: Item {
                    Shape {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        scale: 20 / 24
                        preferredRendererType: Shape.CurveRenderer

                        ShapePath {
                            strokeColor: Theme.cardTextSecondary
                            strokeWidth: 2
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            joinStyle: ShapePath.RoundJoin
                            PathSvg { path: "M 15 3 H 21 V 9 M 9 21 H 3 V 15 M 21 3 L 14 10 M 3 21 L 10 14" }
                        }
                    }
                }
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
