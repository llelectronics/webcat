/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "pages/helper/db.js" as DB

ApplicationWindow
{
    id: mainWindow
    property string siteURL: "about:bookmarks" //"http://talk.maemo.org"  // TODO: Make this configurable via db
    property bool urlLoading: false
    property string version: "0.0.8"
    property string appname: "Webcat Browser"
    property string appicon: "qrc:/harbour-webcat.png"
    property string errorText: ""
    //initialPage: tabView
    cover: undefined
    property string currentTab: ""
    property bool hasTabOpen: (tabModel.count !== 0)
    property alias tabView: tabView

    Component
    {
        id: tabView
//        Timer {
//            repeat: false
//            running: true
//            interval: 100
//            onTriggered: pageStack.push(Qt.resolvedUrl("pages/FirstPage.qml"), {bookmarks: modelUrls});
//        }
        FirstPage {
            bookmarks: modelUrls
        }
    }

    function openNewTab(pageid, url) {
        console.log("openNewTab: "+ pageid + ', currentTab: ' + currentTab);
        if (hasTabOpen) {
            console.debug("1. Pagid: " + pageid)
            //tabModel.insert(0, { "title": "Loading..", "url": url, "pageid": pageid } );
            tabModel.append({ "title": "Loading..", "url": url, "pageid": pageid });
        } else {
            console.debug("2. Pagid: " + pageid)
            tabModel.set(0, { "title": "Loading..", "url": url, "pageid": pageid } );
        }
        var webView = tabView.createObject(mainWindow, { id: pageid, objectName: pageid } );
        webView.url = url;

        currentTab = pageid;
        //tabListView.currentIndex = 0 // move highlight to top
        if (initialPage == "" || initialPage == undefined) {
            console.debug("New Page loading...");
            pageStack.push(webView, {bookmarks: modelUrls, tabModel: tabModel, pageId: pageid});
        }
    }

    function switchToTab(pageid) {
        console.log("switchToTab: "+ pageid + " , from: " + currentTab); //+ ' , at ' + tabListView.currentIndex);
        if (currentTab !== pageid ) {
            pageStack.replace(pageStack.find(function(page) {
                return page.pageId == pageid;})
                ,PageStackAction.Animated);
            currentTab = pageid;
        }
    }

    function closeTab(deleteIndex, pageid) {
        //console.log('closeTab: ' + pageid + ' at ' + deleteIndex + ': ' + tabModel.get(deleteIndex))
        //console.log('\ttabListView.model.get(deleteIndex): ' + tabListView.model.get(deleteIndex).pageid)
        tabModel.remove(deleteIndex);
        if (deleteIndex != 0) currentTab = tabModel.get(deleteIndex-1).pageid;
        else currentTab = tabModel.get(0).pageid;
//        pageStack.pop(pageStack.find(function(page) {
//            return page.pageId == currentTab;})
//            ,PageStackAction.Animated);
        pageStack.replace(pageStack.find(function(page) {
            return page.pageId == currentTab;})
                               ,PageStackAction.Animated);

        if (hasTabOpen) {
            switchToTab(currentTab)
        } else {
            currentTab = ""; // clean currentTab
        }
    }

    function salt(){
        var salt = ""
        var RandomString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        for( var i=0; i < 5; i++ ) {
            salt += RandomString.charAt(Math.floor(Math.random() * RandomString.length));
        }
        return salt
    }

    ListModel {
        id: tabModel

        function getIndex(title) {
            for (var i=0; i<count; i++) {
                if (get(i).title == title)  { // type transformation is intended here
                    return i;
                }
            }
            return 0;
        }

    }

    // Example Data
    ListModel{
        id: modelUrls

        function contains(siteUrl) {
            for (var i=0; i<count; i++) {
                if (get(i).url == siteUrl)  { // type transformation is intended here
                    return true;
                }
            }
            return false;
        }

        function removeBookmark(siteUrl) {
            for (var i=0; i<count; i++) {
                if (get(i).url === siteUrl) remove(i);
                DB.removeBookmark(siteUrl);
            }
        }

        function addBookmark(siteUrl, siteTitle) {
            append({"title":siteTitle, "url":siteUrl});
            DB.addBookmark(siteTitle,siteUrl);
        }

        ListElement {
            title: "Jolla Together"
            url: "http://together.jolla.com/"
        }
        ListElement {
            title: "Maemo forum"
            url: "http://talk.maemo.org/"
        }
        ListElement {
            title: "Jolla users"
            url: "http://jollausers.com/"
        }
        ListElement {
            title: "Jolla users forum"
            url: "http://forum.jollausers.com/"
        }
        ListElement {
            title: "Jolla Tides"
            url: "http://jollatides.com/"
        }
        ListElement {
            title: "Review Jolla"
            url: "http://reviewjolla.blogspot.se/"
        }
        // Load Bookmarks
        Component.onCompleted: {
            DB.initialize();
            DB.getBookmarks();
        }
    }

    Component.onCompleted: {
        //console.debug("Initial Page:" + initialPage)
        openNewTab("page"+salt(), "about:blank");
    }

}


