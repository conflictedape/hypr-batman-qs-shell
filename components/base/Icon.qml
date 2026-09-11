import QtQuick
import "../../"

/**
 * Renders a single Material Symbols Rounded glyph. Pass a codepoint from
 * the `Icons` singleton via the `glyph` property.
 *
 * `filled` toggles the variable font's FILL axis (outline vs. solid),
 * useful for active/inactive or toggled states.
 */
Text {
    id: root

    property string glyph: ""
    property bool filled: false
    property int iconSize: Theme.fontSizeIcon

    text: glyph
    color: Theme.foreground

    font.family: Icons.fontFamily
    font.pixelSize: iconSize
    font.variableAxes: ({
                            "FILL": filled ? 1 : 0,
                            "wght": 400,
                            "GRAD": 0,
                            "opsz": iconSize
                        })

    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
