pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * GPU stats for a dual-GPU (NVIDIA discrete + AMD integrated) machine.
 * `usage` (NVIDIA utilisation %) is polled continuously for the bar — the
 * discrete GPU is what's normally doing the interesting work, so that's
 * the "at a glance" number. The richer fields for both GPUs are only
 * polled while `detailsActive` is true, same gating pattern as Cpu/Memory.
*/
QtObject {
    id: root

    readonly property int intervalMs: 3000
    readonly property int detailIntervalMs: 2000

    property string usage: "--%"

    property bool detailsActive: false
    property string nvidiaName: "--"
    property string nvidiaUsage: "--"
    property string nvidiaMem: "--"
    property string nvidiaTemp: "--"
    property string amdName: "--"
    property string amdUsage: "--"
    property string amdMem: "--"
    property string amdTemp: "--"

    property Process _summaryProc: Process {
        command: ["bash", Quickshell.shellDir + "/scripts/gpu-summary.sh"]
        stdout: SplitParser {
            onRead: data => root.usage = data.trim() + "%"
        }
    }

    property Timer _summaryTimer: Timer {
        interval: root.intervalMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._summaryProc.running = true
    }

    property Process _detailProc: Process {
        command: ["bash", Quickshell.shellDir + "/scripts/gpu-detail.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const o = JSON.parse(text);
                    root.nvidiaName = o.nvidia?.name ?? "N/A";
                    root.nvidiaUsage = o.nvidia?.usage ?? "N/A";
                    root.nvidiaMem = o.nvidia?.mem ?? "N/A";
                    root.nvidiaTemp = o.nvidia?.temp ?? "N/A";
                    root.amdName = o.amd?.name ?? "N/A";
                    root.amdUsage = o.amd?.usage ?? "N/A";
                    root.amdMem = o.amd?.mem ?? "N/A";
                    root.amdTemp = o.amd?.temp ?? "N/A";
                } catch (e) {
                    console.warn("Gpu: failed to parse detail JSON:", e);
                }
            }
        }
    }

    property Timer _detailTimer: Timer {
        interval: root.detailIntervalMs
        running: root.detailsActive
        repeat: true
        triggeredOnStart: true
        onTriggered: root._detailProc.running = true
    }
}
