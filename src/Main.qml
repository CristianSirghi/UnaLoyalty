import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import UnaLoyalty

// Doar navigarea: bara de jos (Carduri / Profil) și pagina tabului ales.
// Ce e pe fiecare pagină stă în folderul funcționalității (src/cards, src/profile).
Window {
    width: 400
    height: 800
    visible: true
    title: "UnaLoyalty"
    color: Theme.background

    // Pe telefon, aplicația desenează și sub bara de stare și bara de navigare a
    // sistemului (banda colorată urcă până sus). Fiecare pagină își lasă singură loc
    // după SafeArea; bara de jos la fel. Pe desktop fereastra rămâne obișnuită.
    flags: Qt.platform.os === "android" || Qt.platform.os === "ios"
           ? Qt.Window | Qt.ExpandedClientAreaHint
           : Qt.Window

    // Iconițele barelor telefonului: albe peste banda colorată a portofelului și în
    // tema întunecată, închise pe fondul deschis al celorlalte pagini.
    Binding {
        target: SystemBars
        property: "lightStatusBarIcons"
        value: Theme.dark || (nav.currentIndex === 0 && cardsStack.depth === 1)
    }
    Binding {
        target: SystemBars
        property: "lightNavigationBarIcons"
        value: Theme.dark
    }

    // Butonul „înapoi” al telefonului închide fereastra: întâi ne întoarcem
    // o pagină în tabul deschis; aplicația se închide doar de pe prima pagină.
    onClosing: (close) => {
        if (nav.currentIndex === 0 && cardsStack.depth > 1) {
            close.accepted = false
            cardsStack.pop()
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            // Sus și jos nu: paginile și bara de jos țin cont singure de barele sistemului.
            leftMargin: parent.SafeArea.margins.left
            rightMargin: parent.SafeArea.margins.right
        }
        spacing: 0

        // StackLayout ține ambele taburi în viață: la întoarcerea pe un tab,
        // pagina e cum a lăsat-o clientul (poziția în listă, cardul ales etc.).
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: nav.currentIndex

            // Tabul Carduri are propriul șir de pagini: portofelul → un bon.
            // Paginile deschid alte pagini prin page.StackView.view.push(...).
            StackView {
                id: cardsStack
                initialItem: WalletPage {}
            }
            ProfilePage {}
        }

        AppNavBar {
            id: nav
            Layout.fillWidth: true
            tabs: [
                { label: qsTr("Cards"), icon: "M 4 5 H 20 A 2 2 0 0 1 22 7 V 17 A 2 2 0 0 1 20 19 H 4 A 2 2 0 0 1 2 17 V 7 A 2 2 0 0 1 4 5 Z M 2 10 H 22" },
                { label: qsTr("Profile"),  icon: "M 16 8 A 4 4 0 1 1 8 8 A 4 4 0 1 1 16 8 Z M 4 21 C 4 17 8 15 12 15 C 16 15 20 17 20 21" }
            ]
        }
    }
}
