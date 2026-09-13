import QtQuick
import QtQuick.Layouts
import Quickshell
import "../.."

// qmllint disable uncreatable-type
PanelWindow {
    id: root

    required property var musicPlayer
    property bool panelOpen: false
    property var anchorItem: null

    visible: panelOpen
    screen: musicPlayer ? musicPlayer.panelScreen : null
    color: Theme.background
    implicitWidth: 360
    implicitHeight: panelContent.implicitHeight + Theme.popupPadding * 2

    function openPanel(): void {
        panelOpen = true;
        panelContent.opacity = 0;
        panelContent.y = -openAnimation.offset;
        openAnimation.start();
    }

    function closePanel(): void {
        panelOpen = false;
        openAnimation.stop();
    }

    ColumnLayout {
        id: panelContent
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: Theme.spacingSmall

        Text {
            text: root.musicPlayer && root.musicPlayer.player ? root.musicPlayer.player.trackTitle : "Nothing playing"
            color: Theme.foreground
            font.pixelSize: Theme.fontSizeNormal
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            text: root.musicPlayer && root.musicPlayer.player ? root.musicPlayer.player.trackArtist : ""
            color: Theme.disabled
            font.pixelSize: Theme.fontSizeSmall
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            text: root.musicPlayer && root.musicPlayer.player ? `DBus: ${root.musicPlayer.player.dbusName}` : "No MPRIS player"
            color: Theme.accentGray
            font.pixelSize: Theme.fontSizeSmall
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSmall

            Text {
                text: root.musicPlayer && root.musicPlayer.isPlaying ? "Pause" : "Play"
                color: Theme.foreground
                font.pixelSize: Theme.fontSizeNormal
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.musicPlayer.togglePlayPause()
                }
            }

            Text {
                text: "Stop"
                color: Theme.foreground
                font.pixelSize: Theme.fontSizeNormal
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.musicPlayer.pauseTrack()
                }
            }
        }
    }

    MusicPlayerPanelAnimation {
        id: openAnimation
        targetItem: panelContent
    }
}
