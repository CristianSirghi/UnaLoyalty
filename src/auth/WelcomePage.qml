import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Prima pagină, fără cont: ce e aplicația și două drumuri, „Create account” / „Sign in”.
// Două butoane, nu un singur câmp de telefon: cine a primit un număr folosit înainte de
// altcineva apasă firesc „Create account” și nu intră din greșeală în contul vechi.
Page {
    id: page

    background: Rectangle { color: Theme.background }

    Component { id: registerPage; RegisterPage {} }
    Component { id: signInPage; SignInPage {} }

    ColumnLayout {
        anchors {
            fill: parent
            leftMargin: Theme.spaceXl
            rightMargin: Theme.spaceXl
            topMargin: page.SafeArea.margins.top + Theme.spaceXxl
            bottomMargin: page.SafeArea.margins.bottom + Theme.spaceXxl
        }
        spacing: Theme.spaceM

        Item { Layout.fillHeight: true }

        // Cardul, în cercul în culoarea aplicației
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Theme.spaceXl
            implicitWidth: 88
            implicitHeight: 88
            radius: width / 2
            color: Theme.primarySubtle

            AppIcon {
                anchors.centerIn: parent
                size: 40
                color: Theme.primary
                path: "M 4 5 H 20 A 2 2 0 0 1 22 7 V 17 A 2 2 0 0 1 20 19 H 4 A 2 2 0 0 1 2 17 V 7 A 2 2 0 0 1 4 5 Z M 2 10 H 22"
            }
        }

        Text {
            Layout.fillWidth: true
            text: qsTr("All your loyalty cards in one place")
            color: Theme.textPrimary
            font.pixelSize: Theme.fontHeadingLarge
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            text: qsTr("Points, receipts and the card code for the cashier, for every place where you have a card.")
            color: Theme.textSecondary
            font.pixelSize: Theme.fontBody
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Item { Layout.fillHeight: true }

        AppButton {
            Layout.fillWidth: true
            text: qsTr("Create account")
            onClicked: page.StackView.view.push(registerPage)
        }

        AppButton {
            Layout.fillWidth: true
            text: qsTr("Sign in")
            variant: "secondary"
            onClicked: page.StackView.view.push(signInPage)
        }
    }
}
