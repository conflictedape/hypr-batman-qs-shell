import QtQuick
import "../"
import "../services"

/**
 * One numbered workspace box. Active workspace gets an orange background;
 * an occupied-but-inactive workspace gets a subtly different shade so you
 * can see which ones have windows at a glance (still clickable either way).
 * Hovering shows a small tooltip listing the windows currently on it.
*/
Rectangle {
    id: root

    required property int wsId

    readonly property bool active: Workspaces.isActive(wsId)
    readonly property bool occupied: Workspaces.isOccupied(wsId)

    width: 40
    height: 25
    radius: 2
    color: {
        if (active)
            return Theme.workspaceActiveBackground;
        if (occupied)
            return Theme.workspaceOccupiedBackground;
        return Theme.workspaceInactiveBackground;
    }
    border.color: Theme.border
    border.width: active ? 0 : 1

    Text {
        anchors.centerIn: parent
        text: root.wsId
        color: root.active ? Theme.workspaceActiveText : Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        font.bold: root.active
    }

    MouseArea {
        id: mouseArea
        
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Workspaces.activate(root.wsId)
    }

    Tooltip {
        anchorItem: root
        text: Workspaces.windowsFor(root.wsId)
        shown: mouseArea.containsMouse
    }
}
