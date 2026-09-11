pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Disk stats. `usage` (root filesystem percent) is polled continuously for
 * the bar. The full mount list is only polled while `detailsActive` is
 * true — set that from the detail popup.
*/
QtObject {
    id: root

    readonly property int intervalMs: 5000
    readonly property int detailIntervalMs: 3000

    property string usage: "--%"

    property bool detailsActive: false
    property var mounts: []

    property Process _summaryProc: Process {
        command: ["bash", Quickshell.shellDir + "/scripts/disk-summary.sh"]
        stdout: SplitParser {
            onRead: data => root.usage = data.trim()
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
        command: ["bash", Quickshell.shellDir + "/scripts/disk-detail.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const o = JSON.parse(text);
                    root.mounts = o.mounts ?? [];
                } catch (e) {
                    console.warn("Disk: failed to parse detail JSON:", e);
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
