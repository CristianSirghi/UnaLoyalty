pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Ecranul principal, „Cardurile mele”: portofelul.
//  - sus, o bandă în culoarea localului cu cardurile, derulabile stânga/dreapta;
//    fiecare card are codul QR gata de scanat (zero atingeri până la cod);
//    ultimul din șir e „+ Adaugă un card”;
//  - sub bandă, plăcile cu punctele și regulile cardului ales;
//  - apoi ultimele bonuri ale cardului ales (sau un desen, dacă nu are).
// Datele vin din C++ (CardsService, ReceiptsModel); aici doar se afișează.
Page {
    id: page
    title: qsTr("My cards")

    background: Rectangle { color: Theme.background }

    // Cardurile: lățimea lasă să se vadă marginea următorului, ca să se înțeleagă
    // că se pot derula.
    readonly property real cardWidth: Math.min(width - 90, 340)
    readonly property real cardStep: cardWidth + Theme.spaceM
    readonly property real cardHeight: cardRepeater.count > 0 && cardRepeater.itemAt(0)
                                       ? cardRepeater.itemAt(0).implicitHeight : 320

    // Poziția în șir: 0..count-1 = un card, count = „+ Adaugă un card”.
    property int currentIndex: 0
    readonly property int slotCount: cardRepeater.count + 1
    readonly property bool onAddSlide: currentIndex >= cardRepeater.count

    // Cardul ales (null pe „+ Adaugă un card” sau când nu e niciun card).
    readonly property WalletCard selectedCard: onAddSlide ? null
                                               : cardRepeater.itemAt(currentIndex) as WalletCard
    readonly property color accent: selectedCard ? selectedCard.brandColor : Theme.primary

    // Codul mărit pe tot ecranul (atingerea QR-ului de pe card).
    CardCodePopup {
        id: codePopup
    }

    // Pagina unui bon; câmpurile i se dau la deschidere (push).
    Component {
        id: receiptDetails
        ReceiptDetailsPage {}
    }

    // Bonurile cardului ales; modelul C++ le încarcă singur de pe server, după codul cardului.
    ReceiptsModel {
        id: receipts
        barcode: page.selectedCard ? page.selectedCard.barcode : ""
    }

    AppFlickable {
        id: scroller
        anchors.fill: parent
        contentHeight: content.implicitHeight + Theme.spaceXxl

        ColumnLayout {
            id: content
            width: scroller.width
            spacing: 0

            // ---- Banda colorată, cu titlul, cardurile și punctele de pagină ----
            Rectangle {
                id: band
                Layout.fillWidth: true
                // Pe telefon banda urcă sub bara de stare; conținutul ei începe sub ea.
                readonly property real topInset: page.SafeArea.margins.top
                implicitHeight: bandContent.implicitHeight + topInset + Theme.spaceXxl + 64
                color: page.accent
                topLeftRadius: 0
                topRightRadius: 0
                bottomLeftRadius: 28
                bottomRightRadius: 28

                Behavior on color { ColorAnimation { duration: 250 } }

                ColumnLayout {
                    id: bandContent
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        topMargin: band.topInset + Theme.spaceXxl
                    }
                    spacing: Theme.spaceMPlus

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: Theme.spaceXl
                        Layout.rightMargin: Theme.spaceXl

                        Text {
                            Layout.fillWidth: true
                            text: page.title
                            color: Theme.textOnPrimary
                            font.pixelSize: Theme.fontHeadingLarge
                            font.weight: Font.Bold
                        }
                        Text {
                            text: page.onAddSlide
                                  ? qsTr("new card")
                                  : qsTr("%1 of %2").arg(page.currentIndex + 1).arg(cardRepeater.count)
                            color: Theme.textOnPrimaryMuted
                            font.pixelSize: Theme.fontCaption
                            font.weight: Font.Medium
                        }
                    }

                    // Cardurile, derulabile stânga/dreapta, câte unul pe rând
                    Flickable {
                        id: carousel
                        Layout.fillWidth: true
                        Layout.preferredHeight: page.cardHeight + 12   // loc pentru umbră
                        contentWidth: cardsRow.width + Theme.spaceXl * 2
                        contentHeight: height
                        flickableDirection: Flickable.HorizontalFlick
                        boundsBehavior: Flickable.StopAtBounds

                        // Se oprește mereu exact pe un card: o tragere scurtă duce la
                        // vecinul din direcția ei, una lentă la cel mai apropiat.
                        function snapTo(index) {
                            const i = Math.max(0, Math.min(index, page.slotCount - 1))
                            page.currentIndex = i
                            snapAnimation.to = Math.min(i * page.cardStep,
                                                        Math.max(0, contentWidth - width))
                            snapAnimation.restart()
                        }

                        // Altă lățime (rotirea telefonului): rămâne pe același card.
                        onWidthChanged: snapTo(page.currentIndex)

                        onFlickStarted: {
                            const direction = horizontalVelocity > 0 ? 1 : -1
                            cancelFlick()
                            snapTo(page.currentIndex + direction)
                        }
                        onMovementEnded: {
                            if (!snapAnimation.running)
                                snapTo(Math.round(contentX / page.cardStep))
                        }

                        NumberAnimation {
                            id: snapAnimation
                            target: carousel
                            property: "contentX"
                            duration: 250
                            easing.type: Easing.OutCubic
                        }

                        Row {
                            id: cardsRow
                            x: Theme.spaceXl
                            spacing: Theme.spaceM

                            Repeater {
                                id: cardRepeater
                                model: CardsService.cards

                                // Lista s-a schimbat (ex. a venit de la server mai scurtă):
                                // poziția rămâne în șir.
                                onCountChanged: carousel.snapTo(page.currentIndex)

                                delegate: WalletCard {
                                    id: walletCard
                                    width: page.cardWidth
                                    onShowCodeRequested: codePopup.show(walletCard.localName,
                                                                        walletCard.barcode,
                                                                        walletCard.brandColor)
                                }
                            }

                            AddCardSlide {
                                width: page.cardWidth
                                height: page.cardHeight
                            }
                        }
                    }

                    // Punctele de pagină: unde ești în șir
                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Theme.spaceXsPlus

                        Repeater {
                            model: page.slotCount
                            delegate: Rectangle {
                                required property int index
                                width: index === page.currentIndex ? 18 : 6
                                height: 6
                                radius: 3
                                color: index === page.currentIndex
                                       ? Theme.textOnPrimary : Theme.bandIndicator
                                Behavior on width { NumberAnimation { duration: 150 } }
                            }
                        }
                    }
                }
            }

            // ---- Plăcile cu puncte, urcate pe jumătate peste bandă ----
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: tiles.implicitHeight - 44
                visible: page.selectedCard !== null
                z: 1

                RowLayout {
                    id: tiles
                    x: Theme.spaceXl
                    y: -44
                    width: parent.width - Theme.spaceXl * 2
                    spacing: Theme.spaceM

                    WalletStatTile {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        label: qsTr("Available points")
                        value: page.selectedCard ? Format.points(page.selectedCard.points) : ""
                    }
                    WalletStatTile {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        readonly property bool known: page.selectedCard !== null
                                                      && page.selectedCard.bonusPercent > 0
                        label: qsTr("Bonus on every receipt")
                        value: known ? Format.percent(page.selectedCard.bonusPercent) : "—"
                        valueColor: page.accent
                        note: known && page.selectedCard.maxPayPercent > 0
                              ? qsTr("Pay with points up to %1 of the receipt")
                                    .arg(Format.percent(page.selectedCard.maxPayPercent))
                              : ""
                    }
                }
            }

            // ---- Ultimele bonuri ----
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spaceXl
                Layout.rightMargin: Theme.spaceXl
                Layout.topMargin: Theme.spaceXxl
                Layout.bottomMargin: Theme.spaceSPlus
                Layout.preferredHeight: 36
                visible: page.selectedCard !== null

                Text {
                    Layout.fillWidth: true
                    text: qsTr("Recent receipts")
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontSubheading
                    font.weight: Font.DemiBold
                }
                AppButton {
                    visible: receipts.count > 0
                    implicitHeight: 36
                    leftPadding: Theme.spaceL
                    rightPadding: Theme.spaceL
                    variant: "secondary"
                    text: qsTr("All")
                    // Istoricul complet al cardului vine mai târziu.
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spaceXl
                Layout.rightMargin: Theme.spaceXl
                spacing: Theme.spaceSPlus
                visible: page.selectedCard !== null && receipts.count > 0

                Repeater {
                    model: receipts
                    delegate: ReceiptRow {
                        id: receiptRow
                        Layout.fillWidth: true
                        accent: page.accent
                        onClicked: page.StackView.view.push(receiptDetails, {
                            barcode: receipts.barcode,
                            serverId: receiptRow.serverId,
                            receiptId: receiptRow.receiptId,
                            number: receiptRow.number,
                            dateTime: receiptRow.dateTime,
                            total: receiptRow.total,
                            paid: receiptRow.paid,
                            pointsEarned: receiptRow.pointsEarned,
                            pointsSpent: receiptRow.pointsSpent,
                            localName: page.selectedCard ? page.selectedCard.localName : ""
                        })
                    }
                }
            }

            ReceiptsEmptyState {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spaceXxl + Theme.spaceL
                Layout.rightMargin: Theme.spaceXxl + Theme.spaceL
                Layout.topMargin: Theme.spaceS
                // Nu cât încă se încarcă: altfel ar apărea o clipă „fără bonuri”.
                visible: page.selectedCard !== null && receipts.count === 0 && !receipts.loading
                accent: page.accent
            }

            // ---- Pe „+ Adaugă un card”: o explicație în loc de puncte și bonuri ----
            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spaceXxl + Theme.spaceXs
                Layout.rightMargin: Theme.spaceXxl + Theme.spaceXs
                Layout.topMargin: Theme.spaceXl
                spacing: Theme.spaceXsPlus
                visible: page.onAddSlide

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Have a card from another venue?")
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontBodyLarge
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                }
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Add it here and keep them all in one place.")
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontBodySmall
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // Pe telefon: la derulare, cardurile și bonurile trec pe sub fâșia asta (în culoarea
    // benzii), nu pe sub ora din bara de stare; iconițele albe rămân lizibile.
    AppStatusBarScrim {
        color: page.accent
    }
}
