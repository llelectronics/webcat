import QtQuick 2.1
import Sailfish.Silica 1.0

BackgroundItem
{
    property string source

    id: imagebutton

    Image
    {
        anchors.centerIn: parent
        width: Theme.iconSizeMedium
        height: Theme.iconSizeMedium
        opacity: imagebutton.enabled ? 1.0 : 0.4

        source: {
            if(imagebutton.pressed)
                return imagebutton.source + "?" + Theme.highlightColor;

            return imagebutton.source;
        }
    }
}
