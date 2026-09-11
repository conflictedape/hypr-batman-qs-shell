import QtQuick
import QtQuick.Layouts
import Quickshell
import "../"
import "../services"

// qmllint disable uncreatable-type
// PanelWindow is a Quickshell interface type flagged as uncreatable by static
// analysis (qmllint/LSP) even though instantiating it directly is the
// documented, correct usage. See: github.com/quickshell-mirror/quickshell/issues/78
PanelWindow {
    id: root

    property var screenData

    // Component.onCompleted: {
    //     (() => {
    //         console.warn("=== TOPBAR DEBUG ===")
    //         console.log(screenData)
    //         console.warn("=====================")
    //     })()
    // }

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: Theme.background
    screen: screenData

    // workspaces
    WorkspacesBar {
        screenData: root.screenData
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
    }

    // stats
    // RowLayout {
    //     id: statsRoot
    //     property int statSpacing: 4

    //     // Only one stat popup may be open at a time (simultaneous grabbing
    //     // popups are invalid per the wlr-layer-shell popup protocol). -1
    //     // means none open; otherwise the index of the open StatButton.
    //     property int openIndex: -1

    //     anchors.right: parent.right
    //     anchors.rightMargin: 12
    //     spacing: statsRoot.statSpacing
    //     anchors.verticalCenter: parent.verticalCenter

    //     StatButton {
    //         glyph: Icons.cpu
    //         value: Cpu.usage
    //         opened: statsRoot.openIndex === 0
    //         onClicked: statsRoot.openIndex = statsRoot.openIndex === 0 ? -1 : 0
    //         onDismissRequested: statsRoot.openIndex = -1
    //         onOpenedChanged: Cpu.detailsActive = opened

    //         detail: Component {
    //             ColumnLayout {
    //                 spacing: Theme.spacingSmall

    //                 Text {
    //                     text: Cpu.model
    //                     color: Theme.foreground
    //                     font.family: Theme.fontFamily
    //                     font.pixelSize: Theme.fontSizeNormal
    //                     font.bold: true
    //                 }
    //                 DetailRow {
    //                     label: "Load avg"
    //                     value: Cpu.loadAvg
    //                 }
    //                 DetailRow {
    //                     label: "Temp"
    //                     value: Cpu.temp
    //                 }
    //                 DetailRow {
    //                     label: "Top process"
    //                     value: Cpu.topProcess
    //                 }

    //                 RowLayout {
    //                     spacing: 3
    //                     Layout.topMargin: Theme.spacingSmall

    //                     Repeater {
    //                         model: Cpu.perCore

    //                         // qmllint disable unqualified
    //                         // modelData is injected by Repeater; qmllint's
    //                         // static analysis can't always resolve it for
    //                         // array-backed models, but it works at runtime.
    //                         Rectangle {
    //                             readonly property int pct: modelData

    //                             Layout.preferredWidth: 6
    //                             Layout.preferredHeight: 32
    //                             color: "transparent"

    //                             Rectangle {
    //                                 anchors.bottom: parent.bottom
    //                                 width: parent.width
    //                                 height: parent.height * (parent.pct / 100)
    //                                 color: Theme.foreground
    //                                 radius: 1
    //                             }
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //     }

    //     StatButton {
    //         glyph: Icons.memory
    //         value: Memory.usage
    //         opened: statsRoot.openIndex === 1
    //         onClicked: statsRoot.openIndex = statsRoot.openIndex === 1 ? -1 : 1
    //         onDismissRequested: statsRoot.openIndex = -1
    //         onOpenedChanged: Memory.detailsActive = opened

    //         detail: Component {
    //             ColumnLayout {
    //                 spacing: Theme.spacingSmall

    //                 DetailRow {
    //                     label: "Used"
    //                     value: Memory.used + " / " + Memory.total
    //                     bold: true
    //                     pixelSize: Theme.fontSizeNormal
    //                 }
    //                 DetailRow {
    //                     label: "Available"
    //                     value: Memory.available
    //                 }
    //                 DetailRow {
    //                     label: "Buffers/Cache"
    //                     value: Memory.buffCache
    //                 }
    //                 DetailRow {
    //                     label: "Swap"
    //                     value: Memory.swapUsed + " / " + Memory.swapTotal
    //                 }
    //                 DetailRow {
    //                     label: "Top process"
    //                     value: Memory.topProcess
    //                 }
    //             }
    //         }
    //     }

    //     // StatButton {
    //     //     glyph: Icons.disk
    //     //     value: Disk.usage
    //     //     opened: statsRoot.openIndex === 2
    //     //     onClicked: statsRoot.openIndex = statsRoot.openIndex === 2 ? -1 : 2
    //     //     onDismissRequested: statsRoot.openIndex = -1
    //     //     onOpenedChanged: Disk.detailsActive = opened

    //     //     detail: Component {
    //     //         ColumnLayout {
    //     //             spacing: Theme.spacingSmall

    //     //             Repeater {
    //     //                 model: Disk.mounts

    //     //                 // qmllint disable unqualified
    //     //                 // modelData is injected by Repeater; qmllint's
    //     //                 // static analysis can't always resolve it for
    //     //                 // array-backed models, but it works at runtime.
    //     //                 ColumnLayout {
    //     //                     spacing: 0
    //     //                     Layout.bottomMargin: Theme.spacingSmall / 2

    //     //                     Text {
    //     //                         text: modelData.target
    //     //                         color: Theme.foreground
    //     //                         font.family: Theme.fontFamily
    //     //                         font.pixelSize: Theme.fontSizeSmall
    //     //                         font.bold: true
    //     //                     }
    //     //                     DetailRow {
    //     //                         label: "Used"
    //     //                         value: modelData.used + " / " + modelData.size + " ("
    //     //                                + modelData.percent + ")"
    //     //                     }
    //     //                 }
    //     //             }
    //     //         }
    //     //     }
    //     // }

    //     // StatButton {
    //     //     glyph: Icons.uptime
    //     //     value: Uptime.text
    //     //     opened: statsRoot.openIndex === 3
    //     //     onClicked: statsRoot.openIndex = statsRoot.openIndex === 3 ? -1 : 3
    //     //     onDismissRequested: statsRoot.openIndex = -1
    //     //     onOpenedChanged: Uptime.detailsActive = opened

    //     //     detail: Component {
    //     //         ColumnLayout {
    //     //             spacing: Theme.spacingSmall

    //     //             Text {
    //     //                 text: Uptime.distro
    //     //                 color: Theme.foreground
    //     //                 font.family: Theme.fontFamily
    //     //                 font.pixelSize: Theme.fontSizeNormal
    //     //                 font.bold: true
    //     //             }
    //     //             DetailRow {
    //     //                 label: "Booted"
    //     //                 value: Uptime.bootTime
    //     //             }
    //     //             DetailRow {
    //     //                 label: "Kernel"
    //     //                 value: Uptime.kernel
    //     //             }
    //     //             DetailRow {
    //     //                 label: "Load avg"
    //     //                 value: Uptime.loadAvg
    //     //             }
    //     //         }
    //     //     }
    //     // }

    //     StatButton {
    //         glyph: Icons.gpu
    //         value: Gpu.usage
    //         opened: statsRoot.openIndex === 4
    //         onClicked: statsRoot.openIndex = statsRoot.openIndex === 4 ? -1 : 4
    //         onDismissRequested: statsRoot.openIndex = -1
    //         onOpenedChanged: Gpu.detailsActive = opened

    //         detail: Component {
    //             ColumnLayout {
    //                 spacing: Theme.spacingSmall

    //                 Text {
    //                     text: "NVIDIA — " + Gpu.nvidiaName
    //                     color: Theme.foreground
    //                     font.family: Theme.fontFamily
    //                     font.pixelSize: Theme.fontSizeNormal
    //                     font.bold: true
    //                 }
    //                 DetailRow {
    //                     label: "Usage"
    //                     value: Gpu.nvidiaUsage
    //                 }
    //                 DetailRow {
    //                     label: "Memory"
    //                     value: Gpu.nvidiaMem
    //                 }
    //                 DetailRow {
    //                     label: "Temp"
    //                     value: Gpu.nvidiaTemp
    //                 }

    //                 Text {
    //                     text: "AMD — " + Gpu.amdName
    //                     color: Theme.foreground
    //                     font.family: Theme.fontFamily
    //                     font.pixelSize: Theme.fontSizeNormal
    //                     font.bold: true
    //                     Layout.topMargin: Theme.spacingSmall
    //                 }
    //                 DetailRow {
    //                     label: "Usage"
    //                     value: Gpu.amdUsage
    //                 }
    //                 DetailRow {
    //                     label: "Memory"
    //                     value: Gpu.amdMem
    //                 }
    //                 DetailRow {
    //                     label: "Temp"
    //                     value: Gpu.amdTemp
    //                 }
    //             }
    //         }
    //     }
    // }
}
