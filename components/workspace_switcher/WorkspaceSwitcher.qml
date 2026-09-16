import QtQuick
import QtQuick.Layouts
import "../../"
import "../../services"

RowLayout {
    id: root

    property var screenData

    spacing: 3.5

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
