import Quickshell
import "./components"

ShellRoot {
    Variants {
            model: Quickshell.screens
            TopBar {
                required property var modelData
                screenData: modelData
            }
        }
}
