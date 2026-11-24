pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Detaliul bonului: localul și data, produsele, totalul, punctele.
Page {
    id: page

    required property int receiptId
    required property string number
    required property date dateTime
    required property real total
    required property real pointsEarned
    required property real pointsSpent
    required property string localName

    title: qsTr("Bon nr. %1").arg(number)

    background: Rectangle { color: Theme.background }

    // Produsele bonului; modelul C++ le încarcă singur după receiptId.
    ReceiptLinesModel {
        id: lines
        receiptId: page.receiptId
    }

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
                // Pe telefon pagina începe sub bara de stare.
                topMargin: page.SafeArea.margins.top + Theme.spaceL
            }
            spacing: Theme.spaceL

            // Antet: înapoi + numărul bonului
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: -Theme.spaceM
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
                        font.pixelSize: Theme.fontBody + 3
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: Format.dateTime(page.dateTime)
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontBody - 1
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
                                    spacing: 2

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

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: Theme.spaceM + 2
                        Layout.bottomMargin: Theme.spaceS

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Total")
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontBody + 1
                            font.weight: Font.Bold
                        }
                        Text {
                            text: Format.money(page.total)
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontBody + 3
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // Punctele primite (și cele folosite, dacă s-a plătit cu puncte)
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: pointsColumn.implicitHeight + Theme.spaceL * 2
                radius: Theme.radiusM
                color: Theme.surface

                ColumnLayout {
                    id: pointsColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: Theme.spaceXl
                        rightMargin: Theme.spaceXl
                    }
                    spacing: Theme.spaceS

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Puncte primite")
                            color: Theme.textSecondary
                            font.pixelSize: Theme.fontBody
                        }
                        Text {
                            text: "+" + Format.points(page.pointsEarned)
                            color: Theme.primary
                            font.pixelSize: Theme.fontHeading - 2
                            font.weight: Font.Bold
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        visible: page.pointsSpent > 0
                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Puncte folosite")
                            color: Theme.textSecondary
                            font.pixelSize: Theme.fontBody
                        }
                        Text {
                            text: "−" + Format.points(page.pointsSpent)
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontHeading - 2
                            font.weight: Font.Bold
                        }
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
