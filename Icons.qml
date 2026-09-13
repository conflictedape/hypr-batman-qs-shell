pragma Singleton

import QtQuick

/**
 * Loads the bundled Material Symbols Rounded variable font and exposes a
 * semantic name -> glyph map so components never need to hardcode raw
 * codepoints. Add new icons here as they're needed.
 *
 * Codepoints sourced from google/material-design-icons (variablefont).
 */
QtObject {
    id: root

    readonly property FontLoader _loader: FontLoader {
        source: "./assets/fonts/MaterialSymbolsRounded.ttf"
    }

    readonly property string fontFamily: _loader.name

    // --- Glyphs ----------------------------------------------------------
    readonly property string cpu: "\ue30d" // developer_board
    readonly property string memory: "\ue322" // memory
    readonly property string disk: "\ue1db" // storage
    readonly property string uptime: "\uefd6" // schedule
    readonly property string gpu: "\uf7a3" // memory_alt
    readonly property string specialCharacter: "\uf74a" // special_character
    readonly property string genres: "\ue022" // genres
    readonly property string pauseCircle: "\ue1a2" // pause_circle
}
