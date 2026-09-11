pragma Singleton

import QtQuick
import Quickshell.Hyprland

/**
 * Thin wrapper around Quickshell's native Hyprland IPC module so UI
 * components never touch Hyprland-specific types directly. Unlike the
 * other services/ singletons (Cpu, Memory, Disk, Uptime), this one isn't
 * timer-polled — Quickshell's Hyprland connection already keeps
 * `workspaces`/`toplevels` live by parsing Hyprland's event socket itself,
 * so everything here is a plain reactive read. It still lives in services/
 * since it's the single place that knows how to talk to the compositor.
*/
QtObject {
    id: root
    property int lastActiveWorkspace: -1

    /**
     * Whether workspace `id` is the currently focused one.
    */
    function isActive(id: int): bool {
        return (Hyprland.focusedWorkspace?.id ?? -1) === id;
    }

    /**
     * Whether workspace `id` has at least one window on it.
    */
    function isOccupied(id: int): bool {
        return Hyprland.toplevels.values.some(t => t.workspace && t.workspace.id === id);
    }

    /**
     * Multi-line text listing the windows on workspace `id`, one app per
     * line, grouped by app id with a "(N)" suffix when there's more than
     * one window of the same app (e.g. "brave\nterminal (2)\nzed"). Returns
     * "Empty" if the workspace has no windows.
    */
    function windowsFor(id: int): string {
        const counts = {};
        const order = [];

        for (const t of Hyprland.toplevels.values) {
            if (!t.workspace || t.workspace.id !== id)
                continue;

            const name = t.wayland?.appId || t.title || "?";
            if (!(name in counts)) {
                counts[name] = 0;
                order.push(name);
            }
            counts[name]++;
        }

        if (order.length === 0)
            return "Empty";

        return order.map(name => counts[name] > 1 ? `${name} (${counts[name]})` : name).join("\n");
    }

    /**
     *  Function to switch to the workspace with the given `id`.
     *  Primarily used by the workspace switcher UI.
     */
    function activate(id: int): void {
        lastActiveWorkspace = Hyprland.focusedWorkspace.id
        if (id == lastActiveWorkspace) return
        console.log(`Switching Workspace -> from:: ${lastActiveWorkspace} to:: ${id}`)

        // id == -99 is assigned to special workspace in hyprland
        if (id == -99) {
            Hyprland.dispatch(`hl.dsp.workspace.toggle_special()`)
            return
        }

        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`);
    }

    readonly property int totalWorkspaceCount:
        Hyprland.workspaces.values.length

    readonly property HyprlandMonitor activeMonitor:
        Hyprland.focusedMonitor

    readonly property var activeMonitorWorkspaces: root.activeMonitor
        ? Hyprland.workspaces.values.filter(
            workspace => workspace.monitor === root.activeMonitor
        )
        : []

    // debug -- only!!
    // TODO: remove this
    Component.onCompleted : {
        const workspacesObj = {}
        for (const workspace of Hyprland.workspaces.values) {
            // if (workspace.id < 0)
            //     continue

            const monitor = workspace.monitor.name
            if (!workspacesObj[monitor])
                workspacesObj[monitor] = []

            workspacesObj[monitor].push({
                id: workspace.id,
                name: workspace.name,
                active: workspace.active
            })
        }
        console.info("workspacesObj: " + JSON.stringify(workspacesObj))
    }

    function generateWorkspacesObj(): var {
        const workspacesObj = {}
        for (const workspace of Hyprland.workspaces.values) {
            // Uncomment to filter out special workspace, special workspace id is -99
            // if (workspace.id < 0) continue

            const monitor = workspace.monitor.name
            if (!workspacesObj[monitor])
                workspacesObj[monitor] = []

            workspacesObj[monitor].push({
                id: workspace.id,
                name: workspace.name,
                active: workspace.active
            })
        }

        console.warn(JSON.stringify(workspacesObj))
        return workspacesObj
    }

    function get_workspacesObjForMonitor(monitor: string): var {
        return generateWorkspacesObj()[monitor]
    }

    readonly property int activeMonitorWorkspaceCount:
        root.activeMonitorWorkspaces.length
}
