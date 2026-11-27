import QtQuick
import QtQuick.Shapes
import UnaLoyalty

// Rotița de așteptare: un arc care se învârte liniștit și, la fiecare ciclu, se lungește
// și se scurtează lin (ca la Android).
//   AppBusyIndicator { color: Theme.primary }
//   AppBusyIndicator { size: 20; running: page.loading }
//
// Cum e făcut, ca să nu sară între cicluri: într-un ciclu (`progress` 0 → 1) atât capul
// arcului, cât și coada lui fac exact o tură (360°), cu accelerare și frânare, dar capul
// pornește mai devreme. Lungimea arcului e diferența dintre ele: la început și la sfârșit e
// minimă, la mijloc ajunge la vreo 200°. Fiindcă amândouă fac o tură întreagă, ciclul
// următor începe exact din același loc. Peste asta, tot arcul se rotește încet.
Item {
    id: indicator

    property color color: Theme.primary
    property real size: 24
    property bool running: visible

    implicitWidth: size
    implicitHeight: size

    // Durata unui ciclu (lungire + scurtare) și a unei ture a rotației de fond.
    // 27.11.2026: 1400 / 2400 cu InOutCubic „se rotește amețitor” (capul arcului ajungea la
    // ~1200°/s la mijlocul ciclului). Acum vârful e ~310°/s, media ~170°/s.
    readonly property int cycleDuration: 3200
    readonly property int spinDuration: 6000
    readonly property real minArc: 20      // grade, cât rămâne vizibil când arcul e cel mai scurt

    property real progress: 0

    // Accelerare și frânare blândă (InOutSine), pe un interval [from, to] din ciclu.
    // Nu InOutCubic: la mijloc e de două ori mai rapidă decât sinusul.
    function eased(t, from, to) {
        const x = Math.min(1, Math.max(0, (t - from) / (to - from)))
        return (1 - Math.cos(Math.PI * x)) / 2
    }

    // Cu intervalele astea arcul cel mai lung are ~200° (pe la jumătatea ciclului).
    readonly property real head: minArc + 360 * eased(progress, 0.0, 0.7)
    readonly property real tail: 360 * eased(progress, 0.2, 1.0)

    NumberAnimation on progress {
        running: indicator.running
        from: 0
        to: 1
        duration: indicator.cycleDuration
        loops: Animation.Infinite
    }

    Shape {
        id: shape
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        // Pe firul de desenare: rămâne lină chiar dacă interfața e ocupată.
        RotationAnimator on rotation {
            running: indicator.running
            from: 0
            to: 360
            duration: indicator.spinDuration
            loops: Animation.Infinite
        }

        ShapePath {
            id: arc
            // Linia ca la AppIcon: 2 px la 24 px.
            strokeWidth: indicator.size / 12
            strokeColor: indicator.color
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: indicator.size / 2
                centerY: indicator.size / 2
                radiusX: (indicator.size - arc.strokeWidth) / 2
                radiusY: radiusX
                // 0° e la dreapta; -90 pornește arcul de sus.
                startAngle: indicator.tail - 90
                sweepAngle: indicator.head - indicator.tail
            }
        }
    }
}
