import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property SilicaWebView flickable: parent
    property int threshold: 500
    property bool _activeUp
    property bool _activeDown
    signal upScrolling
    signal downScrolling
    width: parent.width

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
