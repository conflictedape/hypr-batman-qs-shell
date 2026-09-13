import QtQuick
import Quickshell.Services.Mpris
import "../base"
import '../..'

Row {
    id: root
    spacing: 8

    property var player: null

    function togglePlayPause(): void {
        if (!root.player)
            return
        if (root.isPlaying){
            root.pauseTrack()
            console.log(`MusicPlayer:: Paused ${root.player.dbusName}`)
        }
        else {
            root.playTrack()
            console.log(`MusicPlayer:: Playing ${root.player.dbusName}`)
        }
    }

    function selectPlayer(): var {
        const players = Mpris.players.values

        for (const p of players) {
            if (p.playbackState === MprisPlaybackState.Playing)
                return p
        }

        return players.length > 0 ? players[0] : null
    }

    function refreshPlayer(): void {
        root.player = root.selectPlayer()
        console.log(`MusicPlayer:: refresh, players=${Mpris.players.values.length}, selected=${root.player ? root.player.dbusName : "none"}`)
    }

    readonly property bool isPlaying: root.player
        && root.player.playbackState === MprisPlaybackState.Playing

    function pauseTrack(): void {
        if (!root.player)
            return

        console.log(`MusicPlayer:: stopping ${root.player.dbusName}`)
        root.player.pause()
    }

    function playTrack(): void {
        if (!root.player)
            return

        console.log(`MusicPlayer:: playing ${root.player.dbusName}`)
        root.player.play()
    }


    Connections {
        target: Mpris.players
        function onRowsInserted() { root.refreshPlayer() }
        function onRowsRemoved() { root.refreshPlayer() }
        function onModelReset() { root.refreshPlayer() }
    }

    Connections {
        target: root.player
        function onPlaybackStateChanged() { root.refreshPlayer() }
        function onTrackTitleChanged() { root.refreshPlayer() }
    }

    Component.onCompleted: {
        console.log(`MusicPlayer:: initialized, players=${Mpris.players.values.length}`)
        for (const player of Mpris.players.values) {
            console.log(`MusicPlayer:: player ${player.dbusName}`)
            console.log(JSON.stringify(player))
        }
        root.refreshPlayer()
    }


    Item {
        implicitWidth: musicPlayerIcon.width + root.spacing + musicPlayerText.implicitWidth
        implicitHeight: Math.max(musicPlayerIcon.height, musicPlayerText.implicitHeight)

        Icon {
            id: musicPlayerIcon
            glyph: root.isPlaying ? Icons.genres : Icons.pauseCircle
            filled: false
            iconSize: Theme.fontSizeIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            RotationAnimation {
                id: spinAnimation
                target: musicPlayerIcon
                property: "rotation"
                from: musicPlayerIcon.rotation
                to: 360
                duration: 1300
                loops: Animation.Infinite
            }

            Connections {
                 target: root
                 // triggers when root.isPlaying changes, no need to bind it
                 function onIsPlayingChanged() {
                     if (root.isPlaying) {
                         // When playing, update 'from' to current angle so it resumes smoothly
                         spinAnimation.from = musicPlayerIcon.rotation
                         spinAnimation.start()
                     } else {
                         // When paused, stop spinning and instantly snap back to 0
                         spinAnimation.stop()
                         musicPlayerIcon.rotation = 0
                     }
                 }
             }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.togglePlayPause()
            }
        }

        Text {
            id: musicPlayerText
            text: root.player
                ? root.player.trackTitle
                : "Nothing playing"
            color: Theme.foreground
            font.pixelSize: 13
            anchors.left: musicPlayerIcon.right
            anchors.leftMargin: root.spacing
            anchors.verticalCenter: parent.verticalCenter
        }

        MouseArea {
            id: musicPlayerMouseArea
            // hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.fill: musicPlayerText
            onClicked: console.log("MusicPlayer:: title clicked")
        }
    }

    // Text {
    //     text: root.player
    //         ? root.player.trackArtist
    //         : ""
    //     color: Theme.foreground
    //     opacity: 0.55
    // }
}
