import QtQuick
import "../"
import "../../"
import "../../services"

/**
 * One numbered workspace box. Active workspace gets an orange background;
 * an occupied-but-inactive workspace gets a subtly different shade so you
 * can see which ones have windows at a glance (still clickable either way).
 * Hovering shows a small tooltip listing the windows currently on it.
*/
Rectangle {
    id: root

    required property int wsId
    required property string wsName

    readonly property bool active: Workspaces.isActive(wsId)
    readonly property bool occupied: Workspaces.isOccupied(wsId)

    width: Theme.workspaceButtonWidth
    height: Theme.workspaceButtonHeight
    radius: 6
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
        visible: root.wsId > 0
        anchors.centerIn: parent
        text: root.wsId
        color: root.active ? Theme.workspaceActiveText : Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        font.bold: root.active
    }

    // for special workspace (id == -99)
    Icon {
        visible: root.wsId < 0
        anchors.centerIn: parent
        glyph: Icons.specialCharacter
        color: Theme.foreground
        iconSize: Theme.fontSizeIcon
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Workspaces.activate(root.wsId);
        }
    }

    Tooltip {
        anchorItem: root
        text: Workspaces.windowsFor(root.wsId)
        shown: mouseArea.containsMouse
    }
}
