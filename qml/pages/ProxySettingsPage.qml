import QtQuick 2.1
import Sailfish.Silica 1.0
import harbour.webcat.Network 1.0

Dialog
{
    property bool proxyEnabled: (proxymanager.host.length > 0) && (proxymanager.port > 0)

    id: dlgproxysettings
    allowedOrientations: defaultAllowedOrientations
    acceptDestinationAction: PageStackAction.Pop
    canAccept: tsproxydisabled.checked || ((tfhost.text.length > 0) && (tfport.text.length > 0))

    onAccepted: {
        mainWindow.infoBanner.showText(qsTr("Please restart Webcat"))
        if(tsproxydisabled.checked) {
            proxymanager.unset();
            proxymanager.remove();
            return;
        }

        proxymanager.host = tfhost.text;
        proxymanager.port = parseInt(tfport.text);
        proxymanager.save();
    }

    ProxyManager
    {
        id: proxymanager
        Component.onCompleted: load()
    }

    SilicaFlickable
    {
        anchors.fill: parent

        Column
        {
            id: content
            anchors { left: parent.left; right: parent.right }

            DialogHeader {
                acceptText: qsTr("Save")
            }

            TextSwitch
            {
                id: tsproxydisabled
                text: qsTr("Proxy Disabled")
                description: qsTr("You need to restart Webcat")
                checked: !dlgproxysettings.proxyEnabled
            }

            SectionHeader {
                text: qsTr("Proxy Settings (Restart needed)")
                visible: !tsproxydisabled.checked
            }

            Row
            {
                width: parent.width
                visible: !tsproxydisabled.checked
                spacing: Theme.paddingSmall

                TextField
                {
                    id: tfhost
                    width: parent.width - tfport.width
                    placeholderText: qsTr("Host or Ip Address")
                    text: proxymanager.host
                }

                Label { text: ":" }

                TextField
                {
                    id: tfport
                    width: parent.width / 3
                    placeholderText: qsTr("Port")
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: ((proxymanager.port > 0) ? proxymanager.port.toString() : "")
                }
            }
        }
    }
}

