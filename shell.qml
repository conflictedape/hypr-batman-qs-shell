pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import "./components"

// Quickshell only watches files reachable via import statements from
// shell.qml. TopBar.qml is reached through "./components" above, but it
// doesn't import these two subdirectories itself (they're pulled in via
// the components/qmldir module), so list them here explicitly — otherwise
// editing WorkspaceSwitcher/MusicPlayer during development won't trigger
// a hot reload. Verified: removing these stops reload on edits to files
// under workspace_switcher/ and music_player/.
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
        }
    }
}
