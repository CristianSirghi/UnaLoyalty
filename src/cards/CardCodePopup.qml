import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import UnaLoyalty

// Codul cardului mărit pe tot ecranul, pentru casier: QR mare pe alb, codul întreg
// (dacă scanerul nu citește, îl tastează) și luminozitatea la maximum cât e deschis.
//   CardCodePopup { id: code }  ...  code.show(localName, barcode, brandColor)
// Se închide cu X sau cu butonul „înapoi” al telefonului.
Popup {
    id: popup

    property string localName
    property string barcode
    property color brandColor: Theme.primary

    function show(name, code, color) {
        localName = name
        barcode = code
        brandColor = color
        open()
    }

    parent: Overlay.overlay
    x: 0
    y: 0
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    padding: 0
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape   // Escape și butonul „înapoi” de pe Android

    // Cât e deschis: ecranul la maximum și iconițele de sus închise (fondul e alb).
    onOpened: {
        ScreenBrightness.setMaximum(true)
        SystemBars.whiteOverlay = true
    }
    onClosed: {
        ScreenBrightness.setMaximum(false)
        SystemBars.whiteOverlay = false
    }

    enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 } }

    // Mereu alb (și în tema întunecată): QR-ul se scanează pe fond deschis.
    background: Rectangle { color: Theme.cardSurface }

    contentItem: Item {
        id: codeContent

        ColumnLayout {
            anchors {
                fill: parent
                leftMargin: Theme.spaceXxl
                rightMargin: Theme.spaceXxl
                // Pe telefon, sub bara de stare și deasupra barei de navigare.
                topMargin: codeContent.SafeArea.margins.top + Theme.spaceXxl
                bottomMargin: codeContent.SafeArea.margins.bottom + Theme.spaceXxl
            }
            spacing: Theme.spaceL

            // Localul și butonul de închidere
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceS + 2

                Rectangle {
                    implicitWidth: 36
                    implicitHeight: 36
                    radius: 18
                    color: popup.brandColor

                    Text {
                        anchors.centerIn: parent
                        text: popup.localName.replace(/^[^0-9A-Za-zÀ-ɏЀ-ӿ]+/, "")
                                             .charAt(0).toUpperCase()
                        color: "#FFFFFF"
                        font.pixelSize: Theme.fontBody + 1
                        font.weight: Font.Bold
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: popup.localName
                    color: Theme.cardText
                    font.pixelSize: Theme.fontBody + 3
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                AbstractButton {
                    id: closeButton
                    implicitWidth: Theme.touchTarget
                    implicitHeight: Theme.touchTarget
                    Accessible.name: qsTr("Închide")
                    onClicked: popup.close()

                    background: Rectangle {
                        radius: width / 2
                        color: closeButton.down ? "#D5DBE3" : "#E9EDF2"
                    }
                    contentItem: Item {
                        Shape {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            scale: 20 / 24
                            preferredRendererType: Shape.CurveRenderer

                            ShapePath {
                                strokeColor: Theme.cardText
                                strokeWidth: 2
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap
                                PathSvg { path: "M 6 6 L 18 18 M 18 6 L 6 18" }
                            }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            AppQrCode {
                Layout.alignment: Qt.AlignHCenter
                readonly property real side: Math.min(popup.width - Theme.spaceXxl * 2, 340)
                Layout.preferredWidth: side
                Layout.preferredHeight: side
                text: popup.barcode
                Accessible.name: qsTr("Codul QR al cardului, mărit")
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: popup.barcode
                color: Theme.cardText
                font.pixelSize: Theme.fontHeading
                font.weight: Font.DemiBold
                font.letterSpacing: 2
            }
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Casierul scanează codul sau îl introduce de mână.")
                color: Theme.cardTextSecondary
                font.pixelSize: Theme.fontBody - 1
                wrapMode: Text.WordWrap
            }

            Item { Layout.fillHeight: true }
        }
    }
}
