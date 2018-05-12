import QtQuick 2.0
import Sailfish.Silica 1.0
import "helper/otherComponents"

Page
{
    id: urlPage
    //anchors.fill: parent
    allowedOrientations: mainWindow.orient
    showNavigationIndicator: true
    forwardNavigation: false

    // Needs to be set as dialog behaves buggy somehow
    //width: urlPage.orientation == Orientation.Portrait ? screen.Width : screen.Height
    //height: urlPage.orientation == Orientation.Portrait ? screen.Height : screen.Width

    property string siteURL
    property string siteTitle
    property QtObject dataContainer
    property ListModel bookmarks

    //property ListModel tabModel


    BookmarkList {
        color: "transparent"
        width: {
            if (urlPage.orientation == Orientation.Landscape || urlPage.orientation == Orientation.LandscapeInverted) urlPage.width / 2
            else urlPage.width
        }
        height: {
            if (urlPage.orientation == Orientation.Landscape || urlPage.orientation == Orientation.LandscapeInverted) urlPage.height
            else urlPage.height - (tabBar.height + Theme.paddingLarge)  //- entryURL.height - 2*65 //- bottomBar.height
        }
        bookmarks: urlPage.bookmarks
        onBookmarkClicked: {
            siteURL = url;
            dataContainer.url = siteURL;
            dataContainer.agent = agent;
            pageStack.pop();
        }
    }

    TabBar {
        id: tabBar

        dataContainer: parent.dataContainer

        height: {
            if (parent.orientation == Orientation.Landscape || parent.orientation == Orientation.LandscapeInverted) {
                parent.height
            }
            else {
                if (Theme.itemSizeExtraSmall + (tabModel.count * Theme.itemSizeSmall) < Screen.height / 2.25)
                    Theme.itemSizeExtraSmall + (tabModel.count * Theme.itemSizeSmall) + Theme.paddingMedium
                else
                    parent.height / 2.25
            }
        }
        width: {
            if (parent.orientation == Orientation.Landscape || parent.orientation == Orientation.LandscapeInverted) parent.width / 2
            else parent.width
        }

        anchors.bottom: parent.bottom
        anchors.right: if (parent.orientation == Orientation.Landscape || parent.orientation == Orientation.LandscapeInverted) parent.right
        anchors.left: if (parent.orientation == Orientation.Portrait || parent.orientation == Orientation.PortraitInverted) parent.left
        onTabClicked: {
            if (_tabListView.currentIndex == idx) { pageStack.pop() }
            else {
                _tabListView.currentIndex = idx;
                mainWindow.switchToTab(pageId);
            }
        }
        onNewWindowClicked: {
            mainWindow.openNewWindow("about:blank");
        }
        onNewTabClicked: {
            mainWindow.openNewTab("page-"+mainWindow.salt(), "about:blank", false);
        }
    }
}
