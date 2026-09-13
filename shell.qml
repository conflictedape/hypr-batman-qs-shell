import Quickshell
import "./components"
import QtQuick
import Quickshell.Wayland

// TODO: remove unused imports
// quickshell will watchFiles if they're imported here.. so eventho not using I'm importing for ease of development
import "./components/workspace_switcher"
import "./components/music_player"

ShellRoot {
    Variants {
        model: Quickshell.screens

        Item{
            id: qtObjectRoot
            required property var modelData

            TopBar {
                screenData: qtObjectRoot.modelData
            }

            // PanelWindow {
            //     WlrLayershell.layer: WlrLayer.Top
            //     implicitHeight: 100
            //     screen: qtObjectRoot.modelData

            //     anchors { bottom: false; top: topBar.height;  }

            //     color: Theme.background

            // }

        }
    }
}
