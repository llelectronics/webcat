import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property SilicaWebView flickable: parent
    property int threshold: 500
    property int extraThreshold: threshold * (Screen.width / 170)
    property bool _activeUp
    property bool _activeDown
    property bool activateFastScroll: false
    signal upScrolling
    signal downScrolling
    width: parent.width

    BackgroundItem {
        visible: opacity > 0 && activateFastScroll
        y: 0
        width: flickable.width / 8
        height: flickable.height / 2
        highlighted: pressed
        opacity: _activeUp || _activeDown ? 1 : 0
        anchors.right: parent.right

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            id: rectUp
            anchors.fill: parent
            opacity: 0.7
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: Theme.highlightColor }
            }
        }

        Image {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            anchors.horizontalCenter: rectUp.horizontalCenter
            source: "image://theme/icon-m-page-up"
            height: Theme.itemSizeExtraSmall
            width: Theme.itemSizeExtraSmall

        }

        onClicked: {
            flickable.cancelFlick();
            flickable.scrollToTop();
        }
    }

    BackgroundItem {
        visible: opacity > 0 && activateFastScroll
        y: flickable.height - height
        width: flickable.width / 8
        height: flickable.height / 2
        highlighted: pressed
        opacity: _activeDown || _activeUp ? 1 : 0
        anchors.right: parent.right

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            id: rectDown
            anchors.fill: parent
            opacity: 0.7
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.highlightColor }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Image {
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingLarge
            anchors.horizontalCenter: rectDown.horizontalCenter
            source: "image://theme/icon-m-page-down"
            height: Theme.itemSizeExtraSmall
            width: Theme.itemSizeExtraSmall
        }

        onClicked: {
            flickable.cancelFlick();
            flickable.scrollToBottom();
        }
    }

    Connections {
        target: flickable

        onVerticalVelocityChanged: {
            //console.log("velocity: " + target.verticalVelocity);

            if (target.verticalVelocity < 0)
            {
                _activeDown = false;
            }
            else
            {
                _activeUp = false;
            }

            if (target.verticalVelocity < -threshold &&
                    target.contentHeight > 3 * target.height)
            {
//                _activeUp = true;
//                _activeDown = false;
                upScrolling();
            }
            else if (target.verticalVelocity > threshold &&
                     target.contentHeight > 3 * target.height)
            {
//                _activeUp = false;
//                _activeDown = true;
                downScrolling();
            }
            else if (Math.abs(target.verticalVelocity) < 10)
            {
                _activeUp = false;
                _activeDown = false;
            }
            if (target.verticalVelocity < -extraThreshold &&
                    target.contentHeight > 3 * target.height)
            {
                _activeUp = true;
                _activeDown = false;
            }
            else if (target.verticalVelocity > extraThreshold &&
                     target.contentHeight > 3 * target.height)
            {
                _activeUp = false;
                _activeDown = true;
            }
        }
    }
}
