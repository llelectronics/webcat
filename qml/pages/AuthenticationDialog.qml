// Code parts borrowed from Jollas Sailfish-Browser Code

/****************************************************************************
** Original Author
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    property string hostname
    property string realm
    property alias username: username.text
    property alias password: password.text

    allowedOrientations: mainWindow.firstPage.allowedOrientations

    canAccept: username.text.length > 0

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width

            DialogHeader {
                id: header
                acceptText: qsTr("Authenticate")
            }

            Item {
                id: promptContent
                width: dialog.width
                height: Math.max(childrenRect.height, dialog.height - header.height) - Theme.paddingLarge * 2

                Column {
                    width: parent.width
                    spacing: Theme.paddingMedium

                    Label {
                        x: Theme.paddingLarge
                        width: parent.width - Theme.paddingLarge * 2
                        text: qsTr("The server %1 requires authentication. The server says: %2").arg(hostname).arg(realm)
                        wrapMode: Text.Wrap
                        color: Theme.highlightColor
                    }

                    TextField {
                        id: username

                        width: parent.width
                        focus: true
                        placeholderText: qsTr("Enter your user name")
                        label: qsTr("User name")
                        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: password.focus = true
                    }

                    TextField {
                        id: password

                        width: parent.width
                        echoMode: TextInput.Password
                        placeholderText: qsTr("Enter password")
                        label: qsTr("Password")
                        EnterKey.iconSource: (username.text.length > 0 && text.length > 0) ? "image://theme/icon-m-enter-accept"
                                                                                           : "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: {
                            if (username.text.length > 0) {
                                dialog.accept()
                            } else {
                                username.focus = true
                            }
                        }
                    }
                }
            }
        }
    }
}
