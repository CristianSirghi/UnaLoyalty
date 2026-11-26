pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Detaliul bonului: localul și data, produsele, totalul, punctele.
Page {
    id: page

    required property string barcode   // codul cardului
    required property int serverId     // casa bonului
    required property int receiptId    // bonul pe casa lui
    required property string number
    required property date dateTime
    required property real total
    required property real paid        // în bani (total - puncte folosite)
    required property real pointsEarned
    required property real pointsSpent
    required property string localName

    title: qsTr("Receipt no. %1").arg(number)

    background: Rectangle { color: Theme.background }

    // Produsele bonului; modelul C++ le încarcă singur de pe server (de pe casa bonului).
    ReceiptLinesModel {
        id: lines
        barcode: page.barcode
        serverId: page.serverId
        receiptId: page.receiptId
    }

    AppFlickable {
        anchors.fill: parent
        contentHeight: content.implicitHeight + Theme.spaceXl

        ColumnLayout {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: Theme.spaceXl
                rightMargin: Theme.spaceXl
                // Pe telefon pagina începe sub bara de stare.
                topMargin: page.SafeArea.margins.top + Theme.spaceL
            }
            spacing: Theme.spaceL

            // Antet: înapoi + numărul bonului
            AppPageHeader {
                Layout.fillWidth: true
                title: page.title
                onBackClicked: page.StackView.view.pop()
            }

            // Localul și data
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: placeColumn.implicitHeight + Theme.spaceXl * 2
                radius: Theme.radiusM
                color: Theme.surface

                ColumnLayout {
                    id: placeColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: Theme.spaceXl
                        rightMargin: Theme.spaceXl
                    }
                    spacing: Theme.spaceXs

                    Text {
                        Layout.fillWidth: true
                        text: page.localName
                        color: Theme.textPrimary
                        font.pixelSize: Theme.fontSubheading
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: Format.dateTime(page.dateTime)
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontBodySmall
                    }
                }
            }

            // Produsele și totalul
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: linesColumn.implicitHeight + Theme.spaceS * 2
                radius: Theme.radiusM
                color: Theme.surface

                ColumnLayout {
                    id: linesColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: Theme.spaceXl
                        rightMargin: Theme.spaceXl
                    }
                    spacing: 0

                    Repeater {
                        model: lines
                        // Un produs: denumirea și „cantitate × preț” la stânga, suma la
                        // dreapta; dedesubt linia despărțitoare.
                        delegate: ColumnLayout {
                            id: line
                            required property string name
                            required property real quantity
                            required property real price
                            required property real sum

                            Layout.fillWidth: true
                            spacing: 0

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: Theme.spaceM
                                Layout.bottomMargin: Theme.spaceM
                                spacing: Theme.spaceM

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.spaceXxs

                                    Text {
                                        Layout.fillWidth: true
                                        text: line.name
                                        color: Theme.textPrimary
                                        font.pixelSize: Theme.fontBody
                                        wrapMode: Text.WordWrap
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: Format.points(line.quantity) + " × "
                                              + Format.money(line.price)
                                        color: Theme.textSecondary
                                        font.pixelSize: Theme.fontCaption
                                    }
                                }
                                Text {
                                    Layout.alignment: Qt.AlignTop
                                    text: Format.money(line.sum)
                                    color: Theme.textPrimary
                                    font.pixelSize: Theme.fontBody
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 1
                                color: Theme.border
                            }
                        }
                    }

                    // Produsele stau doar pe casa localului: dacă nu răspunde, o spunem
                    // (totalul și punctele de mai jos vin din Back, deci rămân corecte).
                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: Theme.spaceM
                        visible: lines.failed
                        text: qsTr("The products of this receipt can't be shown right now.")
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontBodySmall
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: Theme.spaceMPlus
                        Layout.bottomMargin: Theme.spaceS

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Total")
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontBodyLarge
                            font.weight: Font.Bold
                        }
                        Text {
                            text: Format.money(page.total)
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontSubheading
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // Punctele și plata; fiecare rând doar dacă nu e 0
            Rectangle {
                id: paymentCard

                // Plata (numerar / card bancar) vine de pe casă, odată cu produsele.
                readonly property bool paymentKnown: !lines.loading && !lines.failed
                                                     && (lines.cash > 0 || lines.card > 0)

                Layout.fillWidth: true
                visible: page.pointsEarned > 0 || page.pointsSpent > 0 || paymentKnown
                implicitHeight: paymentColumn.implicitHeight + Theme.spaceL * 2
                radius: Theme.radiusM
                color: Theme.surface

                ColumnLayout {
                    id: paymentColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: Theme.spaceXl
                        rightMargin: Theme.spaceXl
                    }
                    spacing: Theme.spaceS

                    AppValueRow {
                        Layout.fillWidth: true
                        visible: page.pointsEarned > 0
                        label: qsTr("Points earned")
                        value: "+" + Format.points(page.pointsEarned)
                        valueColor: Theme.primary
                    }
                    AppValueRow {
                        Layout.fillWidth: true
                        visible: page.pointsSpent > 0
                        label: qsTr("Points used")
                        value: "−" + Format.points(page.pointsSpent)
                    }
                    // Plata în bani, după tip (de pe casă). La plata mixtă apar amândouă.
                    AppValueRow {
                        Layout.fillWidth: true
                        visible: paymentCard.paymentKnown && lines.cash > 0
                        label: qsTr("Cash")
                        value: Format.money(lines.cash)
                    }
                    AppValueRow {
                        Layout.fillWidth: true
                        visible: paymentCard.paymentKnown && lines.card > 0
                        label: qsTr("Bank card")
                        value: Format.money(lines.card)
                    }
                    // Cât timp plata de pe casă nu se știe (se încarcă / casa nu răspunde):
                    // suma în bani din Back, doar dacă s-a plătit și cu puncte (altfel e
                    // chiar totalul de mai sus).
                    AppValueRow {
                        Layout.fillWidth: true
                        visible: !paymentCard.paymentKnown && page.pointsSpent > 0
                        label: qsTr("Paid")
                        value: Format.money(page.paid)
                    }
                }
            }
        }
    }

    // Pe telefon: conținutul derulat trece pe sub fâșia asta, nu pe sub ora din bara de stare.
    AppStatusBarScrim {
        color: Theme.background
    }
}
