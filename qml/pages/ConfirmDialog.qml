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
    allowedOrientations: mainWindow.firstPage.allowedOrientations
    property alias acceptText: header.acceptText
    property alias label: lbl.text
    property alias title: title.text
    default property alias defaultContent: promptContent.children

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width

            DialogHeader {
                id: header
            }

            Item {
                id: promptContent
                width: dialog.width
                height: Math.max(childrenRect.height, dialog.height - header.height) - Theme.paddingLarge * 2

                Label {
                    id: title
                    font.pixelSize: Theme.fontSizeLarge
                    anchors {
                        top: parent.top
                        topMargin: Theme.paddingLarge
                    }
                }

                Label {
                    id: lbl
                    property bool largeFont: true

                    x: Theme.paddingLarge
                    width: parent.width - (2 * Theme.paddingLarge)
                    anchors {
                        top: title.bottom
                        topMargin: !largeFont ? Theme.paddingLarge : Theme.itemSizeSmall
                    }
                    font.pixelSize: largeFont ? Theme.fontSizeExtraLarge : Theme.fontSizeMedium
                    color: Theme.highlightColor
                    text: qsTr("Accept ?")

                    onContentWidthChanged: {
                        // We want to get contentWidth text width only once. When wrapping
                        // goes enabled we get contentWidth that is less than width.
                        // Greater than ~ three liner will be rendered with smaller font.
                        if (contentWidth > width * 3 && wrapMode == Text.NoWrap) {
                            largeFont = false
                            wrapMode = Text.Wrap
                        } else if (contentWidth > width && wrapMode == Text.NoWrap) {
                            wrapMode = Text.Wrap
                        }
                    }
                }

                Label {
                    id: certInfoText
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: Theme.paddingLarge
                        left: parent.left
                        leftMargin: Theme.paddingMedium
                        right: parent.right
                        rightMargin: Theme.paddingMedium
                    }
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    text: qsTr("Certificates are used to identify and make sure that the website you see is provided by the author you expect.
Unknown certificates are either ones that are missing in the global configuration of your browser. Outdated ones or compromised ones.
If you are unsure reject the certificate. That might lead to a non loading website though.")
                }
            }
        }
    }
}
