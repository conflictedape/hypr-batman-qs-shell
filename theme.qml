pragma Singleton

import QtQuick
// import Quickshell.Hyprland
// import "services"



/**
 * Central theme definition: colors, fonts, and spacing used across the
 * whole shell. Change values here to re-skin every widget at once.
*/
QtObject {
    id: root

    // --- Fonts ---------------------------------------------------------
    readonly property string fontFamily: "Hack Nerd Font Mono"
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeNormal: 14
    readonly property int fontSizeIcon: 18
    readonly property string iconFontFamily: "Material Symbols Rounded"

    // --- Base palette ----------------------------------------------------
    readonly property color background: "#111111"
    readonly property color foreground: "#d9822b"
    readonly property color disabled: "#6c7086"

    // --- Accent palette ---------------------
    readonly property color accentGray: "#9aa3b2"

    // --- Interactive states (buttons, popups) -----------------------------
    readonly property color surface: "#1c1c1c"
    readonly property color border: "#333333"
    readonly property color hoverBackground: "#2a2a2a"

    // --- Workspaces --------------------------------------------------------
    // readonly property int workspaceCount: 7
    readonly property int workspaceButtonWidth: 40
    readonly property int workspaceButtonHeight: 24
    readonly property int workspaceButtonBorderRadius: 2
    readonly property color workspaceActiveBackground: foreground
    readonly property color workspaceActiveText: background
    readonly property color workspaceInactiveBackground: "transparent"
    readonly property color workspaceOccupiedBackground: "#333333"
    readonly property color specialWorkspaceBackground: "#143286"

    // --- Layout ----------------------------------------------------------
    readonly property int barHeight: 40
    readonly property int spacingSmall: 6
    readonly property int spacingNormal: 18
    readonly property int radiusSmall: 6
    readonly property int radiusNormal: 8
    readonly property int popupPadding: 12
}
