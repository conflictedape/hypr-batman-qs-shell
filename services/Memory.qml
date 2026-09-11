pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Memory stats. `usage` is polled continuously for the bar. The richer
 * breakdown (total/used/available/swap/topProcess) is only polled while
 * `detailsActive` is true — set that from the detail popup.
*/
QtObject {
    id: root

    readonly property int intervalMs: 3000
    readonly property int detailIntervalMs: 2000

    property string usage: "--%"

    property bool detailsActive: false
    property string total: "--"
    property string used: "--"
    property string available: "--"
    property string buffCache: "--"
    property string swapTotal: "--"
    property string swapUsed: "--"
    property string topProcess: "--"

    property Process _summaryProc: Process {
        command: ["bash", Quickshell.shellDir + "/scripts/memory-summary.sh"]
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
        command: ["bash", Quickshell.shellDir + "/scripts/memory-detail.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const o = JSON.parse(text);
                    root.total = o.total;
                    root.used = o.used;
                    root.available = o.available;
                    root.buffCache = o.buffCache;
                    root.swapTotal = o.swapTotal;
                    root.swapUsed = o.swapUsed;
                    root.topProcess = o.topProcess;
                } catch (e) {
                    console.warn("Memory: failed to parse detail JSON:", e);
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
