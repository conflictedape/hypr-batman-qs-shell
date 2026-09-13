import Quickshell
import QtQuick
import Quickshell.Wayland
import "./components"

pragma ComponentBehavior: Bound

// TODO: remove unused imports
// Quickshell watches imported files, so these imports keep the components available during development.
import "./components/workspace_switcher"
import "./components/music_player"

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: QtObject {
            id: screenDelegate
            required property var modelData

            property TopBar topBar: TopBar {
                screenData: screenDelegate.modelData
            }

            // property PanelWindow lowerPanel: PanelWindow {
            //     screen: screenDelegate.modelData
            //     WlrLayershell.layer: WlrLayer.Top
            //     implicitHeight: 100
            //     color: Theme.background
            // }
        }
    }
}
