// Bound: componentele din interior (antetul listei, rândurile) pot folosi id-urile
// din pagină, iar qmllint le verifică.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import UnaLoyalty

// Cardurile mele: lista cardurilor clientului și „+ Adaugă card”.
// Datele vin din CardsService (C++); aici doar se afișează.
Page {
    id: page
    title: qsTr("Cardurile mele")

    background: Rectangle { color: Theme.background }

    ListView {
        id: cardList
        anchors {
            fill: parent
            leftMargin: Theme.spaceXl
            rightMargin: Theme.spaceXl
        }
        spacing: Theme.spaceL
        model: CardsService.cards

        header: Text {
            width: ListView.view.width
            topPadding: Theme.spaceXxl + Theme.spaceS
            bottomPadding: Theme.spaceXl
            text: page.title
            color: Theme.textPrimary
            font.pixelSize: Theme.fontTitle
            font.weight: Font.Bold
        }

        delegate: CardTile {
            width: ListView.view.width
            // Deschiderea cardului (CardDetailsPage) vine la pasul următor.
        }

        footer: Item {
            width: ListView.view.width
            height: addCard.height + Theme.spaceL * 2

            // „+ Adaugă card”: contur punctat, desenat cu Shape (Rectangle nu are
            // bordură punctată). Deocamdată nu face nimic.
            AbstractButton {
                id: addCard
                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: Theme.spaceL }
                // Mărimea vine doar din text: conturul (Shape) se ia după buton, nu invers.
                implicitWidth: implicitContentWidth + leftPadding + rightPadding
                implicitHeight: 56
                text: qsTr("+ Adaugă card")
                font.pixelSize: Theme.fontBody + 1
                font.weight: Font.DemiBold

                contentItem: Text {
                    text: addCard.text
                    font: addCard.font
                    color: Theme.primary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Shape {
                    preferredRendererType: Shape.CurveRenderer

                    ShapePath {
                        strokeColor: Theme.textSecondary
                        strokeWidth: 2
                        strokeStyle: ShapePath.DashLine
                        dashPattern: [3, 2]
                        fillColor: addCard.down ? Theme.surfaceMuted : "transparent"

                        PathRectangle {
                            x: 1
                            y: 1
                            width: addCard.width - 2
                            height: addCard.height - 2
                            radius: Theme.radiusM
                        }
                    }
                }
            }
        }
    }
}
