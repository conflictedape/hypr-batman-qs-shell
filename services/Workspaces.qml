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
     * Switches Hyprland to workspace `id`. Uses the Lua dispatcher syntax
     * (`hl.dsp.focus({ workspace = ... })`) required by Hyprland >= 0.55,
     * which replaced the old plain-text `dispatch workspace N` syntax —
     * confirmed against this machine's own hypr/config/binds.lua convention.
    */
    function activate(id: int): void {
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

    readonly property int activeMonitorWorkspaceCount:
        root.activeMonitorWorkspaces.length
}