pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Uptime stats. `text` (human-readable uptime) is polled continuously for
 * the bar. The system info breakdown (boot time/kernel/distro/load avg) is
 * only polled while `detailsActive` is true — set that from the detail
 * popup.
*/
QtObject {
    id: root

    readonly property int intervalMs: 30000
    readonly property int detailIntervalMs: 5000

    property string text: "--"

    property bool detailsActive: false
    property string bootTime: "--"
    property string kernel: "--"
    property string distro: "--"
    property string loadAvg: "--"

    property Process _summaryProc: Process {
        command: ["bash", Quickshell.shellDir + "/scripts/uptime-summary.sh"]
        stdout: SplitParser {
            onRead: data => root.text = data.trim()
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
        command: ["bash", Quickshell.shellDir + "/scripts/uptime-detail.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const o = JSON.parse(text);
                    root.bootTime = o.bootTime;
                    root.kernel = o.kernel;
                    root.distro = o.distro;
                    root.loadAvg = o.loadAvg;
                } catch (e) {
                    console.warn("Uptime: failed to parse detail JSON:", e);
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
