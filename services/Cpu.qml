pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * CPU stats. `usage` is polled continuously for the bar. The richer detail
 * fields (perCore, model, temp, loadAvg, topProcess) are only polled while
 * `detailsActive` is true — set that from the detail popup so we're not
 * running extra processes when nobody is looking.
*/
QtObject {
    id: root

    readonly property int intervalMs: 3000
    readonly property int detailIntervalMs: 2000

    property string usage: "--%"

    property bool detailsActive: false
    property string model: "--"
    property int cores: 0
    property string loadAvg: "--"
    property string temp: "--"
    property var perCore: []
    property string topProcess: "--"

    property Process _summaryProc: Process {
        command: ["bash", Quickshell.shellDir + "/scripts/cpu-summary.sh"]
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
        command: ["bash", Quickshell.shellDir + "/scripts/cpu-detail.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const o = JSON.parse(text);
                    root.model = o.model;
                    root.cores = o.cores;
                    root.loadAvg = o.loadAvg;
                    root.temp = o.temp ?? "N/A";
                    root.perCore = o.perCore ?? [];
                    root.topProcess = o.topProcess;
                } catch (e) {
                    console.warn("Cpu: failed to parse detail JSON:", e);
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
