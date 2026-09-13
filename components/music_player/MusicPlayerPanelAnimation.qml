import QtQuick

ParallelAnimation {
    id: root

    property Item targetItem
    property real offset: 12
    property int duration: 180

    NumberAnimation {
        target: root.targetItem
        property: "opacity"
        from: 0
        to: 1
        duration: root.duration
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        target: root.targetItem
        property: "y"
        from: -root.offset
        to: 0
        duration: root.duration
        easing.type: Easing.OutCubic
    }
}
