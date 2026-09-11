import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../"

/**
 * A single top-bar stat: an icon + value that, when clicked, opens a small
 * attached popup below the bar with more detail. The detail content is
 * supplied by the caller via the `detail` Component property, and is only
 * instantiated while the popup is open (so backing services can also gate
 * their expensive polling on `opened`).
*/
Item {
    id: root

    property string glyph: ""
    property string value: ""
    property Component detail: null

    // `opened` is intentionally NOT self-toggled on click — only one stat
    // popup may be open at a time (simultaneous grabbing popups break the
    // Wayland layer-shell popup protocol). The parent (TopBar) owns the
    // single "which one is open" state and binds `opened` to it; we just
    // report clicks upward via the `clicked` signal.
    property bool opened: false
    property bool hovered: false

    signal clicked
    signal dismissRequested

    implicitWidth: rowLayout.implicitWidth + Theme.spacingSmall * 2
    implicitHeight: Theme.barHeight - Theme.spacingSmall

    // Imperative push rather than a declarative `visible: root.opened`
    // binding on the popup: `PopupWindow.grabFocus` dismisses the popup
    // itself (sets `visible` to false) whenever the user clicks outside of
    // it, which would permanently sever a plain binding. Re-applying our
    // state explicitly on every change keeps it correct even after that
    // happens (see PopupWindow.onVisibleChanged below).
    onOpenedChanged: popup.visible = opened

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: root.hovered || root.opened ? Theme.hoverBackground : "transparent"
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        Icon {
            glyph: root.glyph
            color: Theme.accentGray
        }

        Text {
            text: root.value
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.clicked()
    }

    // qmllint disable uncreatable-type
    PopupWindow {
        id: popup

        anchor.item: root
        // qmllint disable missing-type
        // PopupAnchor is a non-creatable interface type; qmllint can't
        // resolve its grouped Edges/PopupAdjustment property types even
        // though they work fine at runtime (same class of false positive
        // as the uncreatable-type warning on PanelWindow above).
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.Slide
        // qmllint enable missing-type
        // Deliberately NOT touching anchor.rect (not even a single
        // sub-property like `.y`) to add a gap below the bar: per
        // Quickshell's own source (PopupAnchor::setRect/updateAnchor),
        // `rect` defaults to auto-matching the anchored item's bounds only
        // as long as it has never been assigned to. Setting so much as
        // `anchor.rect.y` reads-modifies-writes the whole rect, which
        // permanently freezes it to a fixed (and, since width/height were
        // never given, 1x1 pixel) box instead of the button's real bounds —
        // that was the actual cause of the popup showing up in the wrong
        // place. The gap is created below (see `gap`) by making the window
        // itself taller than the visible card instead.
        readonly property int gap: Theme.spacingSmall * 2

        color: "transparent"
        // grabFocus alone already dismisses the popup (sets visible: false)
        // whenever the user clicks outside of it — that's a complete,
        // built-in mechanism. Do NOT also add a HyprlandFocusGrab here: two
        // competing Wayland focus-grab mechanisms on the same popup was the
        // actual cause of it failing to become a real xdg_popup at all
        // (visible flickering closed immediately, and falling back to an
        // unpositioned window instead of anchoring below the bar).
        grabFocus: true

        onVisibleChanged: {
            if (visible) {
                // Auto-anchoring doesn't reliably (re-)apply itself just from
                // the window becoming visible — it must be explicitly
                // recomputed each time we show the popup.
                // qmllint disable unresolved-type
                anchor.updateAnchor();
                // qmllint enable unresolved-type
            } else if (root.opened) {
                // visible went false without us setting `opened` to false
                // first — grabFocus just dismissed us because of an outside
                // click. Tell the parent so its openIndex stays in sync.
                root.dismissRequested();
            }
        }

        // The content Loader is always active (not gated on `opened`) so its
        // natural size is already known *before* the popup is first shown —
        // Wayland popup geometry is fixed at creation time, so sizing the
        // window after mapping doesn't reliably work. Safe fallback sizes
        // cover the one frame before the loaded item reports real numbers.
        // qmllint disable missing-property
        // loader.item is typed as a generic QObject by qmllint since Loader
        // can host any component; the ColumnLayout we actually load always
        // has implicitWidth/implicitHeight at runtime.
        implicitWidth: (loader.item ? loader.item.implicitWidth : 240) + Theme.popupPadding * 2
        implicitHeight: (loader.item ? loader.item.implicitHeight : 80) + Theme.popupPadding * 2
                        + gap

        // qmllint enable missing-property

        // Soft drop shadow behind the card — gives it a floating "attached
        // pane" look (like macOS/Ubuntu top-bar menus) instead of a flat
        // rectangle sitting directly on the bar's background.
        RectangularShadow {
            anchors.fill: card
            radius: card.radius
            color: Qt.rgba(0, 0, 0, 0.45)
            blur: 24
            offset: Qt.vector2d(0, 6)
        }

        Rectangle {
            id: card

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: popup.gap
            height: parent.height - popup.gap
            color: Theme.surface
            radius: Theme.radiusNormal
            border.color: Theme.border
            border.width: 1

            // Simple fade + slide-down entrance. Closing stays instant
            // (Wayland popup surfaces disappear immediately on hide, so a
            // fade-out isn't visible anyway without extra "keep the window
            // alive during the animation" plumbing).
            opacity: popup.visible ? 1 : 0
            transform: Translate {
                y: popup.visible ? 0 : -6
                Behavior on y {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }

            Loader {
                id: loader
                anchors.fill: parent
                anchors.margins: Theme.popupPadding
                // Always active: sizing must be known before the popup is
                // ever shown (see note on implicitWidth/Height above). The
                // service singletons still gate their own expensive polling
                // Process calls on `detailsActive`, so this stays cheap.
                active: true
                sourceComponent: root.detail
            }
        }
    }
}
