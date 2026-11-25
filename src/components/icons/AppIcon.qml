import QtQuick
import QtQuick.Shapes
import UnaLoyalty

// Iconița aplicației: un contur SVG desenat cu linie (ca iconițele din schema ecranelor).
//   AppIcon { path: "M 15 6 L 9 12 L 15 18"; color: Theme.textPrimary }
//   AppIcon { path: "..."; size: 20 }   // mai mică
// Calea se scrie mereu pe o zonă de 24×24; `size` micșorează sau mărește tot desenul,
// inclusiv grosimea liniei, ca iconița să-și păstreze proporțiile.
Item {
    id: icon

    property string path
    property color color: Theme.textPrimary
    property real size: 24

    implicitWidth: size
    implicitHeight: size

    Shape {
        anchors.centerIn: parent
        width: 24
        height: 24
        scale: icon.size / 24
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: icon.color
            strokeWidth: 2
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: icon.path }
        }
    }
}
