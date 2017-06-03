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
import QtQuick.Window 2.1
import "pages"
import "pages/helper/db.js" as DB
import "pages/helper/tabhelper.js" as Tab
import harbour.webcat.DBus.TransferEngine 1.0
import harbour.webcat.DBus 1.0

ApplicationWindow
{
    id: mainWindow

    allowedOrientations: defaultAllowedOrientations

    // default settings
    property string siteURL: "about:bookmarks" //"http://talk.maemo.org"
    property string homepage: "about:bookmarks"
    property string userAgent: "Mozilla/5.0 (Maemo; Linux; U; Jolla; Sailfish; like Android) AppleWebKit/538.1 (KHTML, like Gecko) Mobile Safari/538.1 (compatible)"

    property int defaultFontSize: 16
    property int defaultFixedFontSize: 12
    property int minimumFontSize: 11
    property bool loadImages: true
    property bool dnsPrefetch: true
    property bool privateBrowsing: false
    property bool offlineWebApplicationCache: true
    property string userAgentName: "Default Jolla Webkit"
    property string searchEngine: "http://www.google.com/search?q=%s"
    property string searchEngineName: "Google"
    property int orient: Orientation.All


    property bool urlLoading: false
    property string version: "2.8"
    property string appname: "Webcat Browser"
    property string appicon: "qrc:/harbour-webcat.png"
    property string errorText: ""
    cover: undefined
    property string currentTab: ""
    property string currentTabBg: ""
    property bool hasTabOpen: (tabModel.count !== 0)
    property alias tabView: tabView
    property alias tabModel: tabModel
    property int currentTabIndex: 1
    property alias historyModel: historyModel
    property alias bookmarkModel: modelUrls
    property alias downloadModel: downloadModel
    property bool vPlayerExists
    property bool vPlayerExternal
    property alias infoBanner: infoBanner

    property var firstPage
    property TransferEngine transferEngine: TransferEngine { }

    //signal clearCookies()
    signal clearCache()
    signal openNewWindow(string hrefUrl)
    signal openPrivateNewWindow(string hrefUrl)
    signal openWithvPlayerExternal(string url)
    signal setDefaultBrowser()
    signal resetDefaultBrowser()
    signal createDesktopLauncher(string favIcon,string title, string url)

    property WebCatInterface webcatinterface: WebCatInterface { }

    Component {
        id: tabView
        FirstPage {
            id: fPage
            bookmarks: modelUrls

            Component.onCompleted: {
                mainWindow.firstPage = fPage
            }
        }
    }

    Connections
    {
        target: webcatinterface
        onUrlRequested: {
            for(var i = 0; i < args.length; i++) {
                loadInNewTab(args[i]);
                if (!mainWindow.applicationActive) mainWindow.activate();
            }
        }
    }

    function unicodeBlackDownPointingTriangle()
    {
        return "\u25bc"; // unicode for down pointing triangle symbol
    }

    function isUrl(url) {
        var pattern = new RegExp(/^(([\w]+:)?\/\/)?(([\d\w]|%[a-fA-f\d]{2,2})+(:([\d\w]|%[a-fA-f\d]{2,2})+)?@)?([\d\w][-\d\w]{0,253}[\d\w]\.)+[\w]{2,4}(:[\d]+)?(\/([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)*(\?(&?([-+_~.\d\w]|%[a-fA-f\d]{2,2})=?)*)?(#([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)?$/);
        if(!pattern.test(url)) {
            //console.debug("Not a valid URL.");
            return false;
        } else {
            return true;
        }
    }

    // Deactivated as long as gstreamer is so crashy. I don't want the browser to be unusable just because gstreamer crashed again
    function openWithvPlayer(url,title) {
        if (!vPlayerExternal) pageStack.push(Qt.resolvedUrl("pages/VideoPlayer.qml"), {dataContainer: firstPage, streamUrl: url, streamTitle: title});
        else openWithvPlayerExternal(url);
    }

    function clearCookies() {
        firstPage.webview.experimental.deleteAllCookies();
    }

    function saveSession(sessionName) {
        for (var i = 0; i < tabModel.count; i++) {
            DB.addSession(sessionName,i,tabModel.get(i).url,tabModel.count)
        }
    }

    function loadSession(sessionName) {
        DB.getSession(sessionName)
    }

    function addDefaultBookmarks() {
        modelUrls.addBookmark("http://together.jolla.com/", "Jolla Together", userAgent);
        modelUrls.addBookmark("http://talk.maemo.org/","Maemo forum", userAgent);
        modelUrls.addBookmark("http://jollausers.com/","Jolla users", userAgent);
        modelUrls.addBookmark("http://forum.jollausers.com/","Jolla users forum", userAgent);
        modelUrls.addBookmark("http://jollatides.com/", "Jolla Tides", userAgent);
        modelUrls.addBookmark("http://reviewjolla.blogspot.se/", "Review Jolla", userAgent);
    }

    function loadInitialTab() {
        openNewTab("page"+salt(), siteURL, false);
    }

    function loadInNewTab(url) {
        openNewTab("page"+salt(), url, false);
    }

    function openNewTab(pageid, url, inBackground) {
        console.log("openNewTab: "+ pageid + ', currentTab: ' + currentTab);
        var webView = tabView.createObject(mainWindow, { id: pageid, objectName: pageid } );
        webView.url = url;
        webView.pageId = pageid;
        Tab.itemMap[pageid] = webView;
        if (hasTabOpen) {
            //console.debug("Other Tab loading with Pagid: " + pageid)
            //tabModel.insert(0, { "title": "Loading..", "url": url, "pageid": pageid } );
            tabModel.append({ "title": "Loading..", "url": url, "pageid": pageid });
            currentTabBg = pageid;
            if (!inBackground) {
                pageStack.clear();
                pageStack.push(Tab.itemMap[pageid], {bookmarks: modelUrls, tabModel: tabModel, pageId: pageid, loadHP: false});
                currentTab = pageid;
                currentTabBg = "";
            }
        } else {
            //console.debug("First Tab loading with Pageid: " + pageid)
            tabModel.set(0, { "title": "Loading..", "url": url, "pageid": pageid } );
            pageStack.push(Tab.itemMap[pageid], {bookmarks: modelUrls, tabModel: tabModel, pageId: pageid, loadHP: true})
            currentTab = pageid;
            currentTabBg = "";
        }
    }

    function switchToTab(pageid) {
        //console.log("switchToTab: "+ pageid + " , from: " + currentTab); //+ ' , at ' + tabListView.currentIndex);
        pageStack.replaceAbove(null, Tab.itemMap[pageid],{bookmarks: modelUrls, tabModel: tabModel, pageId: pageid}); // Nice 'null' trick for replaceAbove thanks to jpnurmi from irc for pointing that out
        currentTab = pageid;
    }

    function closeTab(deleteIndex, pageid) {
        //console.log('closeTab: ' + pageid + ' at ' + deleteIndex + ': ' + tabModel.get(deleteIndex))
        //console.log('\ttabListView.model.get(deleteIndex): ' + tabListView.model.get(deleteIndex).pageid)
        tabModel.remove(deleteIndex);
        var curTab = currentTab
        if (deleteIndex != 0) currentTab = tabModel.get(deleteIndex-1).pageid;
        else currentTab = tabModel.get(0).pageid;

        if (hasTabOpen) {
            if (curTab != currentTab) switchToTab(currentTab)
        } else {
            currentTab = ""; // clean currentTab
        }

        Tab.itemMap[pageid].destroy();
        delete(Tab.itemMap[pageid]);
    }

    function salt(){
        var salt = ""
        for( var i=0; i < 5; i++ ) {
            salt += Tab.RandomString.charAt(Math.floor(Math.random() * Tab.RandomString.length));
        }
        return salt
    }

    function findBaseName(url) {
        url = url.toString();
        var fileName = url.substring(url.lastIndexOf('/') + 1);
        var dot = fileName.lastIndexOf('.');
        return dot == -1 ? fileName : fileName.substring(0, dot);
    }

    function findHostname(url) {
        var f = /:\/\/(.[^/]+)/;
        return url.toString().match(f)[1];
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

        function getIndexFromId(id) {
            for (var i=0; i<count; i++) {
                if (get(i).pageid == id)  { // type transformation is intended here
                    return i;
                }
            }
            return 0;
        }

        function contains(id) {
            for (var i=0; i<count; i++) {
                if (get(i).pageid == id)  { // type transformation is intended here
                    return true;
                }
            }
            return false;
        }

        function updateUrl(id,url) {
            var idx = getIndexFromId(id);
            //console.debug("Updating index:" + idx + " with url:" + url);
            setProperty(idx, "url", String(url));
        }

    }

    ListModel{
        id: modelUrls

        function contains(siteUrl) {
            var suffix = "/";
            var str = siteUrl.toString();
            for (var i=0; i<count; i++) {
                if (get(i).url == str)  {
                    return true;
                }
                // check if url endswith '/' and return true if url-'/' = models url
                else if (str.indexOf(suffix, str.length - suffix.length) !== -1) {
                    if (get(i).url == str.substring(0, str.length-1)) return true;
                }
            }
            return false;
        }

        function editBookmark(oldTitle, siteTitle, siteUrl, agent) {
            for (var i=0; i<count; i++) {
                if (get(i).title === oldTitle) set(i,{"title":siteTitle, "url":siteUrl, "agent": agent});
            }
            DB.editBookmark(oldTitle,siteTitle,siteUrl,agent);
        }

        function removeBookmark(siteUrl) {
            for (var i=0; i<count; i++) {
                if (get(i).url === siteUrl) remove(i);
            }
            DB.removeBookmark(siteUrl);
        }

        function addBookmark(siteUrl, siteTitle, agent) {
            append({"title":siteTitle, "url":siteUrl, "agent":agent});
            DB.addBookmark(siteTitle,siteUrl,agent);
        }
    }

    UserAgents {
        id: userAgentModel
    }

    SearchEngines {
        id: searchEngineModel
    }

    ListModel {
        id: historyModel

        function contains(siteUrl) {
            var suffix = "/";
            var str = siteUrl.toString();
            for (var i=0; i<count; i++) {
                if (get(i).url == str)  {
                    return true;
                }
                // check if url endswith '/' and return true if url-'/' = models url
                else if (str.indexOf(suffix, str.length - suffix.length) !== -1) {
                    if (get(i).url === str.substring(0, str.length-1)) return true;
                }
            }
            return false;
        }
        function removeHistory(siteUrl) {
            for (var i=0; i<count; i++) {
                if (get(i).url === siteUrl) remove(i);
            }
            DB.removeHistory(siteUrl);
        }

    }

    ListModel {
        id: downloadModel

        // Example data
        //        ListElement {
        //            name: "foobar"
        //            url: "http://download/foo.bar"
        //            downLocation: "home/nemo/Downloads/foo.bar"
        //        }
    }



    Component.onCompleted: {
        //console.debug("Initial Page:" + initialPage)
        // Load Bookmarks
        DB.initialize();
        DB.getBookmarks();
        // Load Settings
        DB.getSettings();
        //openNewTab("page"+salt(), siteURL, false);
    }

    // Let time run to save session every minute
    // TODO: make configurable and somehow
    Timer {
        interval: 60000;
        running: mainWindow.applicationActive ? true : false;
        repeat: true
        onTriggered: saveSession("lastSession")
    }
    // What a hack to create a on Closing behavior
    Window {
        visible: false
        onClosing: {
            saveSession("lastSession")
        }
    }
    InfoBanner {
        id: infoBanner
        z:1
    }
}


