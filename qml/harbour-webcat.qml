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
import "pages/helper/tabhelper.js" as Tab

ApplicationWindow
{
    id: mainWindow

    // default settings
    property string siteURL: "about:bookmarks" //"http://talk.maemo.org"
    property string homepage: "about:bookmarks"
    property string userAgent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
    property int defaultFontSize: 24
    property int defaultFixedFontSize: 22
    property int minimumFontSize: 20 // We need readable fonts on g+, youtube and so on. This might hurt tmo though
    property bool loadImages: true
    property bool dnsPrefetch: true
    property bool privateBrowsing: false
    property bool offlineWebApplicationCache: true
    property string userAgentName: "Default Jolla Webkit"
    property string searchEngine: "http://www.google.com/search?q=%s"
    property string searchEngineName: "Google"


    property bool urlLoading: false
    property string version: "0.9"
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


    signal clearCookies()
    signal openNewWindow(string hrefUrl)

    Component {
        id: tabView
        FirstPage {
            bookmarks: modelUrls
        }
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
        if (deleteIndex != 0) currentTab = tabModel.get(deleteIndex-1).pageid;
        else currentTab = tabModel.get(0).pageid;

        if (hasTabOpen) {
            switchToTab(currentTab)
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

    }

    // Example Data
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

        function removeBookmark(siteUrl) {
            for (var i=0; i<count; i++) {
                if (get(i).url === siteUrl) remove(i);
                DB.removeBookmark(siteUrl);
            }
        }

        function addBookmark(siteUrl, siteTitle, agent) {
            append({"title":siteTitle, "url":siteUrl, "agent":agent});
            DB.addBookmark(siteTitle,siteUrl,agent);
        }


    // No more default bookmarks as on users request
//        ListElement {
//            title: "Jolla Together"
//            url: "http://together.jolla.com/"
//            agent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
//        }
//        ListElement {
//            title: "Maemo forum"
//            url: "http://talk.maemo.org/"
//            agent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
//        }
//        ListElement {
//            title: "Jolla users"
//            url: "http://jollausers.com/"
//            agent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
//        }
//        ListElement {
//            title: "Jolla users forum"
//            url: "http://forum.jollausers.com/"
//            agent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
//        }
//        ListElement {
//            title: "Jolla Tides"
//            url: "http://jollatides.com/"
//            agent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
//        }
//        ListElement {
//            title: "Review Jolla"
//            url: "http://reviewjolla.blogspot.se/"
//            agent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
//        }
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
                    if (get(i).url == str.substring(0, str.length-1)) return true;
                }
            }
            return false;
        }

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
}


