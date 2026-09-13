import QtQuick
import Quickshell
import "../"

// qmllint disable uncreatable-type
// PanelWindow is a Quickshell interface type flagged as uncreatable by static
// analysis (qmllint/LSP) even though instantiating it directly is the
// documented, correct usage. See: github.com/quickshell-mirror/quickshell/issues/78
PanelWindow {
    id: root

    property var screenData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: Theme.background
    screen: screenData

    // workspaces
    WorkspaceSwitcher {
        id: workspaceSwitcher
        screenData: root.screenData
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
    }

    MusicPlayer {
        anchors.left: parent.left
        anchors.leftMargin: workspaceSwitcher.width + 40
        anchors.verticalCenter: parent.verticalCenter
    }
}
