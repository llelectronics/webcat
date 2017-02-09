import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

MouseArea {
    id: videoItem

    property MediaPlayer player
    property bool active
    property url source
    property string mimeType
    property int duration
    onDurationChanged: positionSlider.maximumValue = duration
    property alias controls: controls
    property alias position: positionSlider.value
    signal playClicked;

    property bool transpose

    property bool playing: active && videoItem.player && videoItem.player.playbackState == MediaPlayer.PlayingState
    readonly property bool _loaded: active
                                    && videoItem.player
                                    && videoItem.player.status >= MediaPlayer.Loaded
                                    && videoItem.player.status < MediaPlayer.EndOfMedia

    function play() {
        videoItem.playClicked();
        videoItem.player.source = videoItem.source;
        videoItem.player.play();
    }

    Connections {
        target: videoItem._loaded ? videoItem.player : null

        onPositionChanged: positionSlider.value = videoItem.player.position / 1000
        onDurationChanged: positionSlider.maximumValue = videoItem.player.duration / 1000
    }

    onActiveChanged: {
        if (!active) {
            positionSlider.value = 0
        }
    }

    Item {
        id: controls
        width: videoItem.width
        height: videoItem.height

        opacity: 1.0
        Behavior on opacity { FadeAnimation { id: controlFade } }

        visible: videoItem.player || controlFade.running //(!videoItem.playing || controlFade.running)

        Rectangle {
            anchors.centerIn: parent
            width: playPauseImg.width + 64
            height: playPauseImg.height + 64
            color: "black"
            opacity: 0.4
            radius: width / 2
            border.color: "white"
            border.width: 2
        }

        Image {
            id: playPauseImg
            anchors.centerIn: parent
            source: {
                if (videoItem.player && (!videoItem.playing)) return "image://theme/icon-cover-play"
                else return "image://theme/icon-cover-pause"
            }
            width: height
            height: Theme.iconSizeMedium
            MouseArea {
                anchors.centerIn: parent
                width: parent.width + 64
                height: parent.height + 64
                enabled: !videoItem.playing
                onClicked: {
                    //console.debug("VideoItem.source length = " + videoItem.source.toString().length)
                    if (videoItem.source.toString().length !== 0) {
                        //console.debug("Yeah we have a video source")
                        videoItem.playClicked();
                        videoItem.player.source = videoItem.source;
                        videoItem.player.play();
                    }
                }
            }
        }

        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            enabled: { if (controls.opacity == 1.0) return true; else return false; }
            height: positionSlider.height + (2 * Theme.paddingLarge)
            //color: "black"
            //opacity: 0.5
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "black" } //Theme.highlightColor} // Black seems to look and work better
            }
            Label {
                id: maxTime
                anchors.right: parent.right
                anchors.rightMargin: (2 * Theme.paddingLarge)
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.paddingLarge
                text: {
                    if (positionSlider.maximumValue > 3599) return Format.formatDuration(maximumValue, Formatter.DurationLong)
                    else return Format.formatDuration(positionSlider.maximumValue, Formatter.DurationShort)
                }
                visible: videoItem._loaded
            }

            Slider {
                id: positionSlider

                anchors {
                    left: parent.left;
                    right: {
                        if (maxTime.visible) maxTime.left
                        else parent.right;
                    }
                    bottom: parent.bottom
                }
                anchors.bottomMargin: Theme.paddingLarge + Theme.paddingMedium
                enabled: { if (controls.opacity == 1.0) return true; else return false; }
                height: Theme.itemSizeSmall
                width: {
                    if (maxTime.visible) parent.width - (maxTime.width)
                    else parent.width
                }
                handleVisible: down ? true : false
                minimumValue: 0

                valueText: {
                    if (value > 3599) return Format.formatDuration(value, Formatter.DurationLong)
                    else return Format.formatDuration(value, Formatter.DurationShort)
                }
                onReleased: {
                    if (videoItem.active) {
                        videoItem.player.source = videoItem.source
                        videoItem.player.seek(value * 1000)
                        //videoItem.player.pause()
                    }
                }
            }
        }
    }
}
