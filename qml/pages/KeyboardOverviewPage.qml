import QtQuick 2.2
import Sailfish.Silica 1.0
import "helper/browserComponents"

Page {
    id: keyboardPage
    allowedOrientations: mainWindow.orient
    property bool isBB10: true
    KeyboardCommands {
        id: keyboardCommands
        isBB10: parent.isBB10
    }
    ListModel {
        id: currentShortcutsModel
    }
    function readCommands(){
        /* group current keys by method */
        var tmpObj = {};
        var commandEntry, tmpKey;
        for(var keySettingsIndex = 0; keySettingsIndex < keyboardCommands.keyboardSettings.length; keySettingsIndex++) {
            commandEntry = keyboardCommands.keyboardSettings[keySettingsIndex];
            tmpKey = commandEntry.methods.join('|');

            if(commandEntry.readableKeys && commandEntry.readableKeys.length > 0) {
                tmpObj[tmpKey] = tmpObj[tmpKey] || {
                    keys:[],
                    methods: commandEntry.methods,
                    descr: commandEntry.methods.map(function(methodName){
                        return keyboardCommands.keyCommandsOverview[methodName].text
                    }).join('<br>')
                }
                tmpObj[tmpKey].keys.push({combination: commandEntry.readableKeys.map(function(readableKey){return {key: readableKey};})})
            }
        }
        /* fill model */
        var tmpObjKeys = Object.keys(tmpObj);
        currentShortcutsModel.clear();
        for(var i = 0; i<tmpObjKeys.length;i++) {
            console.log('append', i, JSON.stringify(tmpObj[tmpObjKeys[i]]))
            currentShortcutsModel.append(tmpObj[tmpObjKeys[i]]);
        }
    }
    Connections {
        target: keyboardCommands
        onStateChanged: readCommands()
    }
    PageHeader {
        id: pageHeader
        title: qsTr('Current Keyboard Shortcuts')
        description: ''
        extraContent.height: headerLabel.height
        anchors.bottomMargin: headerLabel.height
    }
    Label {
        id: headerLabel
        anchors.top: pageHeader.bottom
        width: parent.width - Theme.horizontalPageMargin * 2
        x: Theme.horizontalPageMargin
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignRight
        color: Theme.secondaryHighlightColor
        text: keyboardPage.isBB10
              ? qsTr('You have selected BB10 (Blackberry 10) compatible keyboard shortcuts. Take a look at the list below to see what they are.')
              : qsTr('You have selected keyboard shortcuts which mimic some current popular browsers. Take a look at the list below to see what they are.')
    }
    SilicaListView {
        clip: true
        width: parent.width
        anchors.top: headerLabel.bottom
        anchors.bottom: parent.bottom
        model: currentShortcutsModel
        delegate: Column {
            width: keyboardPage.width
            Row {
                width: parent.width - Theme.horizontalPageMargin * 2
                x: Theme.horizontalPageMargin
                height: Math.max(keyColumn.height, commandLabel.height) + Theme.paddingMedium * 2
                Column {
                    id: keyColumn
                    width: Theme.itemSizeExtraLarge * 2
                    spacing: Theme.paddingMedium
                    y: Theme.paddingMedium

                    Repeater {
                        model: keys
                        delegate: Flow {
                            width: keyColumn.width
                            Repeater {
                                model: combination
                                delegate: Item {
                                    width: plusLabel.width + keyLabel.width
                                    height: keyLabel.height
                                    Label {
                                        id: plusLabel
                                        text: '+'
                                        visible: index > 0
                                        width: visible ? implicitWidth : 0
                                        horizontalAlignment: Text.AlignHCenter
                                        color: Theme.highlightColor
                                        anchors.left: parent.left
                                        anchors.verticalCenter: keyLabel.verticalCenter
                                    }
                                    Rectangle {
                                        color: 'transparent'
                                        border.color: Theme.highlightColor
                                        border.width: 2
                                        anchors.fill: keyLabel
                                        radius: Theme.paddingSmall
                                    }
                                    Label {
                                        id: keyLabel
                                        text: ' '+key+' '
                                        horizontalAlignment: Text.AlignHCenter
                                        color: Theme.highlightColor
                                        anchors.left: plusLabel.right
                                        anchors.top: parent.top

                                    }
                                }
                            }
                        }
                    }
                }
                Label {
                    id: commandLabel
                    color: Theme.highlightColor
                    width: parent.width - keyColumn.width
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: descr
                }
            }
            Separator {
                width: parent.width
            }
        }
    }
    Component.onCompleted: readCommands()
}
