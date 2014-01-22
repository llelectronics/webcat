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
    property string siteURL: "about:bookmarks" //"http://talk.maemo.org"  // TODO: Make this configurable via db
    property string userAgent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
    property int defaultFontSize: 20
    property int defaultFixedFontSize: 18
    property int minimumFontSize: 16 // We need readable fonts on g+, youtube and so on. This might hurt tmo though
    property bool loadImages: true
    property bool dnsPrefetch: true
    property bool privateBrowsing: false
    property bool offlineWebApplicationCache: false
    property string userAgentName: "Default Jolla Webkit"
    property string searchEngine: "http://www.google.com/search?q=%s"


    property bool urlLoading: false
    property string version: "0.8"
    property string appname: "Webcat Browser"
    property string appicon: "qrc:/harbour-webcat.png"
    property string errorText: ""
    cover: undefined
    property string currentTab: ""
    property string currentTabBg: ""
    property bool hasTabOpen: (tabModel.count !== 0)
    property alias tabView: tabView
    property alias tabModel: tabModel
    property SilicaListView tabListView

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

    ListModel {
        id: userAgentModel
        ListElement {
            title: "Default Jolla Webkit"
            agent: "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
        }
        ListElement {
            title: "Jolla Sailfish Browser"
            agent: "Mozilla/5.0 (Maemo; Linux; U; Jolla; Sailfish; Mobile; rv:26.0) Gecko/26.0 Firefox/26.0 SailfishBrowser/1.0 like Safari/538.1"
        }
        ListElement {
            title: "Android 2.2"
            agent: "Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
        }
        ListElement {
            title: "Android 4.4"
            agent: "Mozilla/5.0 (Linux; Android 4.4; Nexus 4 Build/KRT16H) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36"
        }
        ListElement {
            title: "N900"
            agent: "Mozilla/5.0 (X11; U; Linux armv7l; en-GB; rv:1.9.2b6pre) Gecko/20100318 Firefox/3.5 Maemo Browser 1.7.4.8 RX-51 N900"
        }
        ListElement {
            title: "N9"
            agent: "Mozilla/5.0 (MeeGo; NokiaN9) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
        }
        ListElement {
            title: "Fennec (Firefox Mobile) 9"
            agent: "Mozilla/5.0 (Maemo; Linux armv7l; rv:9.0) Gecko/20111216 Firefox/9.0 Fennec/9.0"
        }
        ListElement {
            title: "Internet Explorer Mobile 9"
            agent: "Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)"
        }
        ListElement {
            title: "Opera Mini 9"
            agent: "Opera/9.80 (J2ME/MIDP; Opera Mini/9 (Compatible; MSIE:9.0; iPhone; BlackBerry9700; AppleWebKit/24.746; U; en) Presto/2.5.25 Version/10.54"
        }
        ListElement {
            title: "Blackberry 10"
            agent: "Mozilla/5.0 (BB10; Kbd) AppleWebKit/537.35+ (KHTML, like Gecko) Version/10.2.0.1803 Mobile Safari/537.35+"
        }
        ListElement {
            title: "NTT Docomo Browser"
            agent: "DoCoMo/2.0 SH901iC(c100;TB;W24H12)"
        }
        ListElement {
            title: "Firefox 25.0 Desktop Version"
            agent: "Mozilla/5.0 (X11; U; Linux i686; rv:25.0) Gecko/20100101 Firefox/25.0"
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


