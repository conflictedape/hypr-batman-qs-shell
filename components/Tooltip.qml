import QtQuick
import Quickshell
import "../"

/**
 * A small hover-triggered popup showing plain multi-line text below the
 * anchored item (used for the workspace hover window-list preview).
 * Deliberately separate from StatButton's click-toggled popup: a tooltip is
 * a transient, mouse-follows preview with no outside-click dismissal
 * semantics, so it never grabs focus and doesn't fight over Wayland's
 * popup-grab protocol the way a `grabFocus` popup would.
*/
PopupWindow {
    id: root

    property Item anchorItem: null
    property string text: ""
    // Driven by the caller's hover state. Separate from `visible` so a
    // short delay can be inserted before actually showing (avoids a flash
    // of tooltips while the mouse just passes over several boxes).
    property bool shown: false
    property int showDelay: 250

    // Deliberately not touching anchor.rect (see StatButton.qml for the
    // full explanation) — leaving it untouched lets it auto-match
    // anchorItem's real bounds instead of freezing into a broken 1x1 box.
    anchor.item: anchorItem
    // qmllint disable missing-type
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.Slide
    // qmllint enable missing-type

    readonly property int gap: Theme.spacingSmall * 2

    color: "transparent"
    grabFocus: false

    // qmllint disable missing-property
    implicitWidth: label.implicitWidth + Theme.popupPadding * 2
    implicitHeight: label.implicitHeight + Theme.popupPadding * 2 + gap
    // qmllint enable missing-property

    Timer {
        id: showTimer
        interval: root.showDelay
        onTriggered: root.visible = true
    }

    onShownChanged: {
        if (shown) {
            showTimer.start();
        } else {
            showTimer.stop();
            root.visible = false;
        }
    }

    onVisibleChanged: {
        if (visible)
            // qmllint disable unresolved-type
            anchor.updateAnchor();
        // qmllint enable unresolved-type
    }

    Rectangle {
        id: card

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: root.gap
        height: parent.height - root.gap
        color: Theme.surface
        radius: Theme.radiusNormal
        border.color: Theme.border
        border.width: 1

        Text {
            id: label

            anchors.centerIn: parent
            text: root.text
            color: Theme.accentGray
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
