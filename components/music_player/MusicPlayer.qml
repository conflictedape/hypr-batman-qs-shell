import QtQuick
import Quickshell.Services.Mpris
import "../base"
import "../.."
import QtQuick.Layouts

Row {
    id: root
    spacing: 8

    property var player: null
    property bool panelOpen: false
    property var panelScreen: null

    function togglePlayPause(): void {
        if (!root.player)
            return;
        if (root.isPlaying)
            root.pauseTrack();
        else
            root.playTrack();
    }

    function selectPlayer(): var {
        const players = Mpris.players.values;

        for (const p of players) {
            if (p.playbackState === MprisPlaybackState.Playing)
                return p;
        }

        return players.length > 0 ? players[0] : null;
    }

    function refreshPlayer(): void {
        root.player = root.selectPlayer();
    }

    readonly property bool isPlaying: root.player && root.player.playbackState === MprisPlaybackState.Playing

    function pauseTrack(): void {
        if (!root.player)
            return;
        root.player.pause();
    }

    function playTrack(): void {
        if (!root.player)
            return;
        root.player.play();
    }

    function togglePanel(): void {
        root.panelOpen = !root.panelOpen;
        if (root.panelOpen)
            detailsPanel.openPanel();
        else
            detailsPanel.closePanel();
    }

    function closePanel(): void {
        root.panelOpen = false;
        detailsPanel.closePanel();
    }

    Connections {
        target: Mpris.players
        function onRowsInserted() {
            root.refreshPlayer();
        }
        function onRowsRemoved() {
            root.refreshPlayer();
        }
        function onModelReset() {
            root.refreshPlayer();
        }
    }

    Connections {
        target: root.player
        function onPlaybackStateChanged() {
            root.refreshPlayer();
        }
        function onTrackTitleChanged() {
            root.refreshPlayer();
        }
    }

    // Component.onCompleted: root.refreshPlayer()

    Component.onCompleted: {
        root.refreshPlayer()
        for(const player of Mpris.players.values){
            console.log(player)
        }
    }

    RowLayout {
        implicitWidth: musicPlayerIcon.width + root.spacing + trackTitleText.implicitWidth
        implicitHeight: Math.max(musicPlayerIcon.height, trackTitleText.implicitHeight)
        visible: root.player

        Icon {
            id: musicPlayerIcon
            glyph: root.isPlaying ? Icons.genres : Icons.pauseCircle
            filled: false
            iconSize: Theme.fontSizeIcon

            RotationAnimation {
                id: spinAnimation
                target: musicPlayerIcon
                property: "rotation"
                from: musicPlayerIcon.rotation
                to: 360
                duration: 1500
                loops: Animation.Infinite
            }

            Connections {
                target: root
                // triggers when root.isPlaying changes, no need to bind it
                function onIsPlayingChanged() {
                    if (root.isPlaying) {
                        // When playing, update 'from' to current angle so it resumes smoothly
                        spinAnimation.from = musicPlayerIcon.rotation;
                        spinAnimation.start();
                    } else {
                        // When paused, stop spinning and instantly snap back to 0
                        spinAnimation.stop();
                        musicPlayerIcon.rotation = 0;
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.togglePlayPause()
            }
        }

        RowLayout {
            id: musicPlayerItem
            implicitWidth: trackTitleText.implicitWidth + trackArtistText.implicitWidth + root.spacing
            implicitHeight: Math.max(trackTitleText.implicitHeight, trackArtistText.implicitHeight)
            Layout.margins: {
                left: 4
            }

            Text {
                id: trackTitleText
                text: root.player ? root.player.trackTitle : "Nothing playing"
                color: Theme.foreground
                font.pixelSize: 13

                Layout.minimumWidth: 10
                Layout.maximumWidth: 200
                elide: Text.ElideRight
            }

            Text {
                id: trackArtistText
                text: root.player ? `${root.player.trackArtist}` : ""
                color: Theme.disabled
                font.pixelSize: 12

                Layout.minimumWidth: 10
                Layout.maximumWidth: 100
                elide: Text.ElideRight
            }

            TapHandler {
                // acceptedButtons: Qt.LeftButton
                enabled: root.isPlaying
                onTapped: function(eventPoint, button) {
                    console.log("button:", button)
                    root.togglePanel()
                }
            }

            HoverHandler {
                enabled: root.isPlaying
                cursorShape: Qt.PointingHandCursor
            }
        }

    }

    MusicPlayerPanel {
        id: detailsPanel
        musicPlayer: root
        anchorItem: root
        panelOpen: root.panelOpen
    }
}
