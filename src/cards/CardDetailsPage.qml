pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Cardul deschis: codul QR pentru casă, codul întreg și punctele.
// „Ultimele bonuri” vin la pasul următor (funcționalitatea history/).
Page {
    id: page

    required property string localName
    required property real points
    required property string barcode

    title: localName

    background: Rectangle { color: Theme.background }

    Flickable {
        anchors.fill: parent
        contentHeight: content.implicitHeight + Theme.spaceXl
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        ColumnLayout {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: Theme.spaceXl
                rightMargin: Theme.spaceXl
                topMargin: Theme.spaceL
            }
            spacing: Theme.spaceL

            // Antet: înapoi + numele localului
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: -Theme.spaceM   // săgeata aliniată vizual cu marginea
                spacing: Theme.spaceXs

                AppBackButton {
                    onClicked: page.StackView.view.pop()
                }
                Text {
                    Layout.fillWidth: true
                    text: page.title
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontHeading
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
            }

            // Codul pentru casă
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: codeColumn.implicitHeight + Theme.spaceXxl + Theme.spaceXl
                radius: Theme.radiusL
                color: Theme.surface

                ColumnLayout {
                    id: codeColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        topMargin: Theme.spaceXxl
                    }
                    spacing: Theme.spaceM

                    AppQrCode {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 240
                        Layout.preferredHeight: 240
                        text: page.barcode
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Arată codul la casă")
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontBody
                    }
                    Text {
                        // Codul întreg: casierul îl poate introduce de mână dacă
                        // scanerul nu citește ecranul.
                        Layout.alignment: Qt.AlignHCenter
                        text: page.barcode
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontBody - 1
                        font.letterSpacing: 1
                    }
                }
            }

            // Punctele
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: pointsRow.implicitHeight + Theme.spaceL * 2
                radius: Theme.radiusM
                color: Theme.surface

                RowLayout {
                    id: pointsRow
                    anchors {
                        fill: parent
                        leftMargin: Theme.spaceXl
                        rightMargin: Theme.spaceXl
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Puncte")
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontBody
                    }
                    Text {
                        text: page.points.toLocaleString(Qt.locale(), "f",
                                                         Number.isInteger(page.points) ? 0 : 2)
                        color: Theme.primary
                        font.pixelSize: Theme.fontTitle
                        font.weight: Font.Bold
                    }
                }
            }
        }
    }
}
