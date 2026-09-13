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
        lastActiveWorkspace = Hyprland.focusedWorkspace?.id ?? -1;
        if (id == lastActiveWorkspace)
            return;

        // id == -99 is assigned to special workspace in hyprland
        if (id == -99) {
            Hyprland.dispatch(`hl.dsp.workspace.toggle_special()`);
            return;
        }

        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`);
    }

    readonly property int totalWorkspaceCount: Hyprland.workspaces.values.length

    readonly property HyprlandMonitor activeMonitor: Hyprland.focusedMonitor

    readonly property var activeMonitorWorkspaces: root.activeMonitor ? Hyprland.workspaces.values.filter(workspace => workspace.monitor === root.activeMonitor) : []

    // Workspaces grouped by monitor name. A plain readonly property (not a
    // function) so QML's binding system computes it once per
    // Hyprland.workspaces.values change and shares the result across every
    // monitor's WorkspaceSwitcher, instead of every switcher re-scanning
    // and re-grouping all workspaces on its own.
    readonly property var workspacesByMonitor: {
        const byMonitor = {};
        for (const workspace of Hyprland.workspaces.values) {
            // ignore gaming workspace
            if (workspace.id == -1337)
                continue;
            // a workspace can briefly have no monitor assigned (e.g. during
            // a monitor hotplug/reconfigure) — skip it rather than crash
            if (!workspace.monitor)
                continue;
            const monitor = workspace.monitor.name;
            if (!byMonitor[monitor])
                byMonitor[monitor] = [];

            byMonitor[monitor].push({
                id: workspace.id,
                name: workspace.name,
                active: workspace.active
            });
        }
        return byMonitor;
    }

    function get_workspacesObjForMonitor(monitor: string): var {
        return root.workspacesByMonitor[monitor];
    }

    readonly property int activeMonitorWorkspaceCount: root.activeMonitorWorkspaces.length
}
