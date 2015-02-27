import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "helper"

Page {
    id: videoPlayerPage
    objectName: "videoPlayerPage"
    allowedOrientations: Orientation.All

    property QtObject dataContainer

    property string videoDuration: {
        if (videoPoster.duration > 3599) return Format.formatDuration(videoPoster.duration, Formatter.DurationLong)
        else return Format.formatDuration(videoPoster.duration, Formatter.DurationShort)
    }
    property string videoPosition: {
        if (videoPoster.position > 3599) return Format.formatDuration(videoPoster.position, Formatter.DurationLong)
        else return Format.formatDuration(videoPoster.position, Formatter.DurationShort)
    }
    property string originalUrl
    property string streamUrl
    property bool youtubeDirect: true;
    property bool isYtUrl
    property string streamTitle
    property string title: videoPoster.player.metaData.title ? videoPoster.player.metaData.title : ""
    property string artist: videoPoster.player.metaData.albumArtist ? videoPoster.player.metaData.albumArtist : ""
    property bool liveView: true
    property Page dPage
    property bool autoplay: true

    property alias showTimeAndTitle: showTimeAndTitle
    property alias pulley: pulley
    property alias onlyMusic: onlyMusic
    property alias videoPoster: videoPoster

    Component.onCompleted: {
        if (autoplay) {
            videoPoster.play();
            pulley.visible = false;
            showNavigationIndicator = false;
        }
    }


    function findBaseName(url) {
        var fileName = url.substring(url.lastIndexOf('/') + 1);
        var dot = fileName.lastIndexOf('.');
        return dot == -1 ? fileName : fileName.substring(0, dot);
    }

    onStreamUrlChanged: {
        if (errorDetail.visible && errorTxt.visible) { errorDetail.visible = false; errorTxt.visible = false }
        videoPoster.showControls();
        if (streamTitle == "") streamTitle = findBaseName(streamUrl)
    }

    Rectangle {
        id: headerBg
        width:urlHeader.width
        height: urlHeader.height
        visible: {
            if (urlHeader.visible || titleHeader.visible) return true
            else return false
        }
        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: "transparent" } //Theme.highlightColor} // Black seems to look and work better
        }
    }

    PageHeader {
        id: urlHeader
        title: findBaseName(streamUrl)
        visible: {
            if (titleHeader.visible == false && pulley.visible && mainWindow.applicationActive) return true
            else return false
        }
        _titleItem.font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeLarge : Theme.fontSizeHuge
        states: [
            State {
                name: "cover"
                PropertyChanges {
                    target: urlHeader
                    visible: true
                }
            }
        ]
    }
    PageHeader {
        id: titleHeader
        title: streamTitle
        visible: {
            if (streamTitle != "" && pulley.visible && mainWindow.applicationActive) return true
            else return false
        }
        _titleItem.font.pixelSize: mainWindow.applicationActive ? Theme.fontSizeLarge : Theme.fontSizeHuge
        states: [
            State {
                name: "cover"
                PropertyChanges {
                    target: titleHeader
                    visible: true
                }
            }
        ]
    }

    function videoPauseTrigger() {
        // this seems not to work somehow
        if (videoPoster.player.playbackState == MediaPlayer.PlayingState) videoPoster.player.pause();
        else if (videoPoster.source.toString().length !== 0) videoPoster.player.play();
        if (videoPoster.controls.opacity === 0.0) videoPoster.toggleControls();

    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            id: pulley
            opacity: downloadPulleyItem.visible ? 1.0 : 0.0
            MenuItem {
                id: downloadPulleyItem
                text: qsTr("Download")
                visible: {
                    if ((/^https?:\/\/.*$/).test(streamUrl)) return true
                    else return false
                }
                // Alternatively use direct youtube url instead of ytapi for downloads (ytapi links not always download with download manager)
                onClicked: {
                    // Filter out all chars that might stop the download manager from downloading the file
                    // Illegal chars: `~!@#$%^&*()-=+\|/?.>,<;:'"[{]}
                    //console.debug("[FileDetails -> Download YT Video]: " + mainWindow.firstPage.youtubeDirectUrl)
                    pageStack.push(Qt.resolvedUrl("DownloadManager.qml"), {"downloadUrl": streamUrl});
                }
            }
        }

        Image {
            id: onlyMusic
            anchors.centerIn: parent
            source: Qt.resolvedUrl("img/audio.png")
            opacity: 0.0
            Behavior on opacity { FadeAnimation { } }
        }

        ProgressCircle {
            id: progressCircle

            anchors.centerIn: parent
            visible: false

            Timer {
                interval: 32
                repeat: true
                onTriggered: progressCircle.value = (progressCircle.value + 0.005) % 1.0
                running: visible
            }
        }

        Column {
            id: errorBox
            anchors.top: parent.top
            anchors.topMargin: 65
            spacing: 15
            width: parent.width
            height: parent.height
            visible: {
                if (errorTxt.text !== "" || errorDetail.text !== "" ) return true;
                else return false;
            }
            Label {
                // TODO: seems only show error number. Maybe disable in the future
                id: errorTxt
                text: ""

                //            anchors.top: parent.top
                //            anchors.topMargin: 65
                font.bold: true
            }


            TextArea {
                id: errorDetail
                text: ""
                width: parent.width
                height: parent.height / 3
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: false
            }
        }
        MouseArea {
            id: errorClick
            anchors.fill: errorBox
            enabled: {
                if (errorTxt.text != "") return true
                else return false
            }
            onClicked: {
                errorTxt.text = ""
                errorDetail.text = ""
                errorBox.visible = false
            }
            z:99  // above all to hide error message
        }

        Item {
            id: mediaItem
            property bool active : true
            visible: active && mainWindow.applicationActive
            anchors.fill: parent

            VideoPoster {
                id: videoPoster
                width: videoPlayerPage.orientation === Orientation.Portrait ? Screen.width : Screen.height
                height: videoPlayerPage.height

                player: mediaPlayer

                //duration: videoDuration
                active: mediaItem.active
                source: streamUrl
                onSourceChanged: {
                    player.stop();
                    //play();  // autoPlay TODO: add config for it
                    position = 0;
                    player.seek(0);
                }

                onPlayClicked: {
                    toggleControls();
                }

                function toggleControls() {
                    //console.debug("Controls Opacity:" + controls.opacity);
                    if (controls.opacity === 0.0) {
                        console.debug("Show controls");
                        controls.opacity = 1.0;
                    }
                    else {
                        console.debug("Hide controls");
                        controls.opacity = 0.0;
                    }
                    videoPlayerPage.showNavigationIndicator = !videoPlayerPage.showNavigationIndicator
                    pulley.visible = !pulley.visible
                }

                function hideControls() {
                    controls.opacity = 0.0
                    pulley.visible = false
                    videoPlayerPage.showNavigationIndicator = false
                }

                function showControls() {
                    controls.opacity = 1.0
                    pulley.visible = true
                    videoPlayerPage.showNavigationIndicator = true
                }


                onClicked: {
                    if (drawer.open) drawer.open = false
                    else {
                        if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                            //console.debug("Mouse values:" + mouse.x + " x " + mouse.y)
                            var middleX = width / 2
                            var middleY = height / 2
                            //console.debug("MiddleX:" + middleX + " MiddleY:"+middleY + " mouse.x:"+mouse.x + " mouse.y:"+mouse.y)
                            if ((mouse.x >= middleX - 64 && mouse.x <= middleX + 64) && (mouse.y >= middleY - 64 && mouse.y <= middleY + 64)) {
                                mediaPlayer.pause();
                                if (controls.opacity === 0.0) toggleControls();
                                progressCircle.visible = false;
                                if (! mediaPlayer.seekable) mediaPlayer.stop();
                            }
                            else {
                                toggleControls();
                            }
                        } else {
                            //mediaPlayer.play()
                            //console.debug("clicked something else")
                            toggleControls();
                        }
                    }
                }
            }
        }
    }
    Drawer {
        id: drawer
        width: parent.width
        height: parent.height
        anchors.bottom: parent.bottom
        dock: Dock.Bottom
        foreground: flick
        backgroundSize: {
            if (videoPlayerPage.orientation === Orientation.Portrait) return parent.height / 8
            else return parent.height / 6
        }
        background: Rectangle {
            anchors.fill: parent
            anchors.bottom: parent.bottom
            color: Theme.secondaryHighlightColor
            Button {
                id: ytDownloadBtn
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                text: "Download video"
                visible: {
                    if ((/^http:\/\/ytapi.com/).test(streamUrl)) return true
                    else if (isYtUrl) return true
                    else return false
                }
                // Alternatively use direct youtube url instead of ytapi for downloads (ytapi links not always download with download manager)
                onClicked: {
                    // Filter out all chars that might stop the download manager from downloading the file
                    // Illegal chars: `~!@#$%^&*()-=+\|/?.>,<;:'"[{]}
                    streamTitle = YT.getDownloadableTitleString(streamTitle)
                    pageStack.push(Qt.resolvedUrl("ytQualityChooser.qml"), {"streamTitle": streamTitle, "url720p": url720p, "url480p": url480p, "url360p": url360p, "url240p": url240p, "ytDownload": true});
                    drawer.open = !drawer.open
                }
            }
        }

    }

    children: [

        // Always use a black background
        Rectangle {
            anchors.fill: parent
            color: "black"
            visible: video.visible
        },

        VideoOutput {
            id: video
            anchors.fill: parent

            source: mediaPlayer

            visible: mediaPlayer.status >= MediaPlayer.Loaded && mediaPlayer.status <= MediaPlayer.EndOfMedia
            width: parent.width
            height: parent.height
            anchors.centerIn: videoPlayerPage

            ScreenBlank {
                suspend: mediaPlayer.playbackState == MediaPlayer.PlayingState
            }

        }
    ]

    // Need some more time to figure that out completely
    Timer {
        id: showTimeAndTitle
        property int count: 0
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            ++count
            if (count >= 5) {
                stop()
                coverTime.fadeOut.start()
                urlHeader.state = ""
                titleHeader.state = ""
                count = 0
            } else {
                coverTime.visible = true
                if (title.toString().length !== 0 && !mainWindow.applicationActive) titleHeader.state = "cover";
                else if (streamUrl.toString().length !== 0 && !mainWindow.applicationActive) urlHeader.state = "cover";
            }
        }
    }

    Rectangle {
        width: parent.width
        height: Theme.fontSizeHuge
        y: coverTime.y + 10
        color: "black"
        opacity: 0.4
        visible: coverTime.visible
    }

    Item {
        id: coverTime
        property alias fadeOut: fadeout
        //visible: !mainWindow.applicationActive && liveView
        visible: false
        onVisibleChanged: {
            if (visible) fadein.start()
        }
        anchors.top: titleHeader.bottom
        anchors.topMargin: 15
        x : (parent.width / 2) - ((curPos.width/2) + (dur.width/2))
        NumberAnimation {
            id: fadein
            target: coverTime
            property: "opacity"
            easing.type: Easing.InOutQuad
            duration: 500
            from: 0
            to: 1
        }
        NumberAnimation {
            id: fadeout
            target: coverTime
            property: "opacity"
            duration: 500
            easing.type: Easing.InOutQuad
            from: 1
            to: 0
            onStopped: coverTime.visible = false;
        }
        Label {
            id: dur
            text: videoDuration
            anchors.left: curPos.right
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeHuge
            font.bold: true
        }
        Label {
            id: curPos
            text: videoPosition + " / "
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeHuge
            font.bold: true
        }
    }

    MediaPlayer {
        id: mediaPlayer

        onDurationChanged: {
            //console.debug("Duration(msec): " + duration);
            videoPoster.duration = (duration/1000);
            if (hasAudio === true && hasVideo === false) onlyMusic.opacity = 1.0
            else onlyMusic.opacity = 0.0;
        }
        onStatusChanged: {
            //errorTxt.visible = false     // DEBUG: Always show errors for now
            //errorDetail.visible = false
            //console.debug("[videoPlayer.qml]: mediaPlayer.status: " + mediaPlayer.status)
            if (mediaPlayer.status === MediaPlayer.Loading || mediaPlayer.status === MediaPlayer.Buffering || mediaPlayer.status === MediaPlayer.Stalled) progressCircle.visible = true;
            else if (mediaPlayer.status === MediaPlayer.EndOfMedia) videoPoster.showControls();
            else  { progressCircle.visible = false; }
            if (metaData.title) dPage.title = metaData.title
        }
        onError: {
            errorTxt.text = error;
            errorDetail.text = errorString;
            errorBox.visible = true;
            /* Avoid MediaPlayer undefined behavior */
            stop();
        }
    }

    CoverActionList {
        id: coverAction
        enabled: liveView

        //        CoverAction {
        //            iconSource: "image://theme/icon-cover-next"
        //        }

        CoverAction {
            iconSource: {
                if (videoPoster.player.playbackState === MediaPlayer.PlayingState) return "image://theme/icon-cover-pause"
                else return "image://theme/icon-cover-play"
            }
            onTriggered: {
                //console.debug("Pause triggered");
                videoPauseTrigger();
                if (!showTimeAndTitle.running) showTimeAndTitle.start();
                else showTimeAndTitle.count = 0;
                videoPoster.hideControls();
            }
        }
    }
}
