import QtQuick
import QtQuick.Controls
import UnaLoyalty

// Un rând apăsabil dintr-o placă a Profilului: text și, opțional, săgeata ›.
// Rândurile se pun unul sub altul într-o placă (Rectangle cu Theme.radiusM); `first` și
// `last` rotunjesc colțurile fondului apăsat ca pe placă, iar sub fiecare rând, în afară
// de ultimul, e o linie de despărțire.
//   ProfileRow { text: qsTr("About the app"); showArrow: true; first: true }
AbstractButton {
    id: row

    property bool showArrow: false
    property bool first: false
    property bool last: false

    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Theme.touchTarget + Theme.spaceS

    leftPadding: Theme.spaceXl
    rightPadding: Theme.spaceXl

    font.pixelSize: Theme.fontBody

    contentItem: Item {
        implicitWidth: label.implicitWidth + (arrow.visible ? arrow.width + Theme.spaceS : 0)
        implicitHeight: label.implicitHeight

        Text {
            id: label
            anchors {
                left: parent.left
                right: arrow.visible ? arrow.left : parent.right
                rightMargin: arrow.visible ? Theme.spaceS : 0
                verticalCenter: parent.verticalCenter
            }
            text: row.text
            font: row.font
            color: Theme.textPrimary
            elide: Text.ElideRight
        }

        AppIcon {
            id: arrow
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            visible: row.showArrow
            size: 20
            color: Theme.textSecondary
            path: "M 9 18 L 15 12 L 9 6"
        }
    }

    background: Rectangle {
        color: row.down ? Theme.surfaceMuted : "transparent"
        topLeftRadius: row.first ? Theme.radiusM : 0
        topRightRadius: row.first ? Theme.radiusM : 0
        bottomLeftRadius: row.last ? Theme.radiusM : 0
        bottomRightRadius: row.last ? Theme.radiusM : 0

        // Linia de despărțire de rândul următor
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            visible: !row.last
            color: Theme.border
        }
    }
}
