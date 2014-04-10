import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property SilicaWebView flickable: parent
    property int threshold: 1500
    property bool _activeUp
    property bool _activeDown
    signal upScrolling
    signal downScrolling
    width: parent.width

    BackgroundItem {
        visible: opacity > 0
        y: 0
        width: upImg.width * 2
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        height: Theme.itemSizeLarge
        highlighted: pressed
        opacity: _activeUp ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            width: 64
            height: 64
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            anchors.verticalCenter: parent.verticalCenter
            radius: 75
            color: Theme.highlightBackgroundColor
            opacity: 0.8
//            gradient: Gradient {
//                GradientStop { position: 0.0; color: "transparent" }
//                GradientStop { position: 0.5; color: Theme.highlightBackgroundColor}
//                GradientStop { position: 1.0; color: "transparent" }
//            }

            Image {
                id: upImg
                anchors.centerIn: parent
                source: "image://theme/icon-l-up"
            }
        }

        onPressed: {
            flickable.scrollToTop();
        }
    }

    BackgroundItem {
        visible: opacity > 0
        y: flickable.height - height
        width: downImg.width * 2
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        height: Theme.itemSizeLarge
        highlighted: pressed
        opacity: _activeDown ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            width: 64
            height: 64
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            anchors.verticalCenter: parent.verticalCenter
            radius: 75
            color: Theme.highlightBackgroundColor
            opacity: 0.8
//            gradient: Gradient {
//                GradientStop { position: 0.0; color: "transparent" }
//                GradientStop { position: 0.5; color: Theme.highlightBackgroundColor}
//                GradientStop { position: 1.0; color: "transparent" }
//            }

            Image {
                id: downImg
                anchors.centerIn: parent
                source: "image://theme/icon-l-down"
            }
        }

        onPressed: {
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
                _activeUp = true;
                _activeDown = false;
                upScrolling();
            }
            else if (target.verticalVelocity > threshold &&
                     target.contentHeight > 3 * target.height)
            {
                _activeUp = false;
                _activeDown = true;
                downScrolling();
            }
            else if (Math.abs(target.verticalVelocity) < 10)
            {
                _activeUp = false;
                _activeDown = false;
            }
        }
    }
}
