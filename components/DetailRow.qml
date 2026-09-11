import QtQuick
import QtQuick.Layouts
import "../"

/**
 * A single "label: value" line used inside stat detail popups. The label
 * is shown in the accent/orange color, the value in the normal detail text
 * color — matches the look requested for all stat detail cards.
*/
RowLayout {
    id: root

    property string label: ""
    property string value: ""
    property bool bold: false
    property int pixelSize: Theme.fontSizeSmall

    spacing: 4

    Text {
        text: root.label + ":"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: root.pixelSize
        font.bold: root.bold
    }

    Text {
        text: root.value
        color: Theme.accentGray
        font.family: Theme.fontFamily
        font.pixelSize: root.pixelSize
        font.bold: root.bold
    }
}
