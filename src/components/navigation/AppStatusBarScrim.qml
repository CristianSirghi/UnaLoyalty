import QtQuick

// Fâșia fixă de sub bara de stare a telefonului (ora, bateria). Aplicația desenează
// și sub bara de stare; fără fâșia asta, conținutul derulat ar trece pe sub oră și
// iconițele n-ar mai fi lizibile (ex. iconițe albe peste un card alb).
// Se pune ultima în pagină, ca să fie deasupra conținutului:
//   AppStatusBarScrim { color: Theme.background }
// Pe desktop nu există bară de stare: înălțimea e 0.
Rectangle {
    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
    }
    // Zona sigură a părintelui (pagina, pe tot ecranul), nu a fâșiei: fâșia își ia
    // înălțimea din ea.
    height: parent.SafeArea.margins.top
    z: 100

    Behavior on color { ColorAnimation { duration: 250 } }
}
