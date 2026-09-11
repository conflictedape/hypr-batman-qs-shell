import QtQuick
import QtQuick.Layouts
import "../"

/**
 * Left-docked row of numbered workspace boxes (1..Theme.workspaceCount).
 * Sits opposite the click-to-open stat buttons on the right side of the bar.
 * Named "WorkspacesBar" (not "Workspaces") to avoid colliding with the
 * `Workspaces` service singleton this component reads from.
*/
RowLayout {
    id: root

    spacing: Theme.spacingSmall / 2

    Repeater {
        model: Theme.workspaceCount

        WorkspaceButton {
            required property int index

            wsId: index + 1
        }
    }
}
