import QtQuick
import QtQuick.Layouts
import "../"
import "../../"
import "../../services"

RowLayout {
    id: root

    property var screenData

    Component.onCompleted: {
        console.warn("=== WORKSPACES DEBUG - " + screenData.name + " ===")
        // console.warn("screenData:", root.screenData)
        // console.warn("screen name:", root.screenData?.name)

        const workspaces = Workspaces.get_workspacesObjForMonitor(
            root.screenData.name
        )

        console.warn("workspaces:", workspaces)
        console.warn("workspace count:", workspaces?.length)

        if (workspaces) {
            for (let i = 0; i < workspaces.length; i++) {
                console.warn(
                    "workspace[" + i + "]:",
                    workspaces[i]?.id
                )
            }
        }

        console.warn("========================")
    }

    spacing: Theme.spacingSmall / 2

    Repeater {
        model: Workspaces.get_workspacesObjForMonitor(root.screenData.name)

        WorkspaceButton {
            required property int index
            required property var modelData
            wsId: modelData.id
            wsName: modelData.name
        }
    }
}
