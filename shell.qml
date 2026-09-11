import Quickshell
import "./components"

// quickshell will watchFiles if they're imported here.. so eventho not using I'm importing for ease of development
import "./components/workspace_switcher"

ShellRoot {
    Variants {
        model: Quickshell.screens
        TopBar {
            required property var modelData
            screenData: modelData
        }
    }
}
