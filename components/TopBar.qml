import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import "../"

// qmllint disable uncreatable-type
// PanelWindow is a Quickshell interface type flagged as uncreatable by static
// analysis (qmllint/LSP) even though instantiating it directly is the
// documented, correct usage. See: github.com/quickshell-mirror/quickshell/issues/78
PanelWindow {
    id: root

    property var screenData
    // WlrLayershell.namespace: "quickshell-topbar"
    property var hyprMonitor: Hyprland.monitorFor(screenData)

    visible: !hyprMonitor?.activeWorkspace?.hasFullscreen

    anchors {
        top: true
        left: true
        right: true
    }

    // qmllint disable unresolved-type unqualified
    margins {
        top: 4
        left: 8
        right: 8
    }

    implicitHeight: Theme.barHeight
    screen: screenData
    color: "transparent"
    surfaceFormat.opaque: false

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.85)
    }

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
