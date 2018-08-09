import QtQuick 2.0

Item {
    id: keyboardRoot
    property alias debounceMilliseconds: debounceTimer.interval
    //overwriteable for preview page
    property bool isBB10: mainWindow.useBB10KeyboardShortcuts
    StateGroup {
        state: "BB10"
        states: [
            State {
                name: "BB10" //default BB10 style keyboard commands
                when: keyboardRoot.isBB10
                PropertyChanges {
                    target: keyboardRoot
                    keyboardSettings: ([
                                        /* scrolling / page navigation */
                                        { key: Qt.Key_B, modifiers: Qt.NoModifier,
                                            methods:['scrollToBottom'], readableKeys:['B']},
                                        { key: Qt.Key_T, modifiers: Qt.NoModifier,
                                            methods:['scrollToTop'], readableKeys:['T']},
                                        { key: Qt.Key_L, modifiers: Qt.NoModifier,
                                            methods:['reloadWebView'], readableKeys:['L']},
                                        { key: Qt.Key_P, modifiers: Qt.NoModifier,
                                            methods:['goBack'], readableKeys:['P']},
                                        { key: Qt.Key_N, modifiers: Qt.NoModifier,
                                            methods:['goForward'], readableKeys:['N']},
                                        { key: Qt.Key_Escape, modifiers: Qt.NoModifier,
                                            methods:['stopLoading', 'hideSearchBar'], readableKeys:[qsTr('Esc', 'Key')]},

                                        /* bookmarks */
                                        { key: Qt.Key_A, modifiers: Qt.NoModifier,
                                            methods:['addBookmark'], readableKeys:['A']},
                                        { key: Qt.Key_K, modifiers: Qt.NoModifier,
                                            methods:['showBookmarks'], readableKeys:['K']},
                                        { key: Qt.Key_Q, modifiers: Qt.NoModifier,
                                            methods:['showBookmarks'], readableKeys:['Q']},

                                        /* tabs/windows */
                                        { key: Qt.Key_W, modifiers: Qt.NoModifier,
                                            methods:['openNewTab'], readableKeys:['W']},
                                        { key: Qt.Key_T, modifiers: Qt.ControlModifier,
                                            methods:['openNewTab'], readableKeys:[qsTr('Ctrl', 'Key'),'B']},
                                        { key: Qt.Key_W, modifiers: Qt.ShiftModifier,
                                            methods:['openNewWindow'], readableKeys:[qsTr('Shift', 'Key'),'W']},
                                        { key: Qt.Key_N, modifiers: Qt.ControlModifier,
                                            methods:['openNewWindow'], readableKeys:[qsTr('Ctrl', 'Key'),'N']},
                                        { key: Qt.Key_W, modifiers: Qt.ControlModifier,
                                            requirements: mainWindow.tabModel.count > 1,
                                            methods:['closeCurrentTab'], readableKeys:[qsTr('Ctrl', 'Key'),'W']},
                                        { key: Qt.Key_Tab, modifiers: Qt.ControlModifier,
                                            requirements: mainWindow.tabModel.count > 1,
                                            methods:['focusNextTab'], readableKeys:[qsTr('Ctrl', 'Key'),qsTr('Tab', 'Key')]},
                                        { key: Qt.Key_Backtab, modifiers: Qt.ControlModifier + Qt.ShiftModifier,
                                            requirements: mainWindow.tabModel.count > 1,
                                            methods:['focusPreviousTab'], readableKeys:[qsTr('Ctrl', 'Key'),qsTr('Shift', 'Key'), qsTr('Tab', 'Key')]},
                                        //no private window shortcut in bb10

                                        /* in-page search */
                                        { key: Qt.Key_S, modifiers: Qt.NoModifier,
                                            methods:['showSearchBar'], readableKeys:['S']},
                                        { key: Qt.Key_Enter, modifiers: Qt.NoModifier,
                                            requirements:  typeof searchBar !== 'undefined' && searchBar.visible,
                                            methods:['submitSearchBar'], readableKeys:[]},
                                        { key: Qt.Key_Return, modifiers: Qt.NoModifier,
                                            requirements:  typeof searchBar !== 'undefined' && searchBar.visible,
                                            methods:['submitSearchBar'], readableKeys:[]},

                                        /* misc */
                                        { key: Qt.Key_R, modifiers: Qt.NoModifier,
                                            methods:['toggleReaderMode'], readableKeys:['R']},
                                        { key: Qt.Key_U, modifiers: Qt.NoModifier,
                                            methods:['focusUrlBar'], readableKeys:['U']}
                                       ])
                }
            },
            State {
                name: "Ffx"
                when: !keyboardRoot.isBB10
                PropertyChanges {
                    target: keyboardRoot
                    keyboardSettings: ([
                                           /* scrolling / page navigation */
                                           { key: Qt.Key_End, modifiers: Qt.NoModifier,
                                               methods:['scrollToBottom'], readableKeys:[qsTr('End', 'Key')]},
                                           { key: Qt.Key_Home, modifiers: Qt.NoModifier,
                                               methods:['scrollToTop'], readableKeys:[qsTr('Home', 'Key')]},
                                           { key: Qt.Key_R, modifiers: Qt.ControlModifier,
                                               methods:['reloadWebView'], readableKeys:[qsTr('Ctrl', 'Key'),'R']},
                                           { key: Qt.Key_Left, modifiers: Qt.AltModifier,
                                               methods:['goBack'], readableKeys:[qsTr('Alt', 'Key'),'←']},
                                           { key: Qt.Key_Right, modifiers: Qt.AltModifier,
                                               methods:['goForward'], readableKeys:[qsTr('Alt', 'Key'),'→']},
                                           { key: Qt.Key_Escape, modifiers: Qt.NoModifier,
                                               methods:['stopLoading', 'hideSearchBar'], readableKeys:[qsTr('Esc', 'Key')]},

                                           /* bookmarks */
                                           { key: Qt.Key_D, modifiers: Qt.ControlModifier,
                                               methods:['addBookmark'], readableKeys:[qsTr('Ctrl', 'Key'),'D']},
                                           // firefox "bookmarks sidebar"
                                           { key: Qt.Key_B, modifiers: Qt.ControlModifier,
                                               methods:['showBookmarks'], readableKeys:[qsTr('Ctrl', 'Key'),'B']},
                                           { key: Qt.Key_O, modifiers: Qt.ControlModifier + Qt.ShiftModifier,
                                               methods:['showBookmarks'], readableKeys:[qsTr('Ctrl', 'Key'),qsTr('Shift', 'Key'),'O']},

                                           /* tabs/windows */
                                           { key: Qt.Key_T, modifiers: Qt.ControlModifier,
                                               methods:['openNewTab'], readableKeys:[qsTr('Ctrl', 'Key'),'T']},
                                           { key: Qt.Key_N, modifiers: Qt.ControlModifier,
                                               methods:['openNewWindow'], readableKeys:[qsTr('Ctrl', 'Key'),'N']},
                                           { key: Qt.Key_W, modifiers: Qt.ControlModifier,
                                               requirements: mainWindow.tabModel.count > 1,
                                               methods:['closeCurrentTab'], readableKeys:[qsTr('Ctrl', 'Key'),'W']},
                                           { key: Qt.Key_Tab, modifiers: Qt.ControlModifier,
                                               requirements: mainWindow.tabModel.count > 1,
                                               methods:['focusNextTab'], readableKeys:[qsTr('Ctrl', 'Key'),qsTr('Tab', 'Key')]},
                                           { key: Qt.Key_Backtab, modifiers: Qt.ControlModifier + Qt.ShiftModifier,
                                               requirements: mainWindow.tabModel.count > 1,
                                               methods:['focusPreviousTab'], readableKeys:[qsTr('Ctrl', 'Key'),qsTr('Shift', 'Key'),qsTr('Tab', 'Key')]},
                                           // firefox variant
                                           { key: Qt.Key_P, modifiers: Qt.ControlModifier,
                                               methods:['openPrivateNewWindow'], readableKeys:[qsTr('Ctrl', 'Key'),'P']},
                                           // chrome variant
                                           { key: Qt.Key_N, modifiers: Qt.ControlModifier + Qt.ShiftModifier,
                                               methods:['openPrivateNewWindow'], readableKeys:[qsTr('Ctrl', 'Key'),qsTr('Shift', 'Key'),'N']},

                                           /* in-page search */
                                           { key: Qt.Key_F, modifiers: Qt.ControlModifier,
                                               methods:['showSearchBar'], readableKeys:[qsTr('Ctrl', 'Key'),'F']},
                                           { key: Qt.Key_Enter, modifiers: Qt.NoModifier,
                                               requirements:  typeof searchBar !== 'undefined' && searchBar.visible,
                                               methods:['submitSearchBar'], readableKeys:[]},
                                           { key: Qt.Key_Return, modifiers: Qt.NoModifier,
                                               requirements:  typeof searchBar !== 'undefined' && searchBar.visible,
                                               methods:['submitSearchBar'], readableKeys:[]},

                                           /* misc */
                                           { key: Qt.Key_R, modifiers: Qt.ControlModifier + Qt.AltModifier,
                                               methods:['toggleReaderMode'], readableKeys:[qsTr('Ctrl', 'Key'),qsTr('Alt', 'Key'),'R']},
                                           { key: Qt.Key_D, modifiers: Qt.AltModifier,
                                               methods:['focusUrlBar'], readableKeys:[qsTr('Alt', 'Key'),'D']},
                                           { key: Qt.Key_L, modifiers: Qt.ControlModifier,
                                               methods:['focusUrlBar'], readableKeys:[qsTr('Ctrl', 'Key'),'L']},
                                           { key: Qt.Key_Q, modifiers: Qt.ControlModifier,
                                               methods:['exit'], readableKeys:[qsTr('Ctrl', 'Key'),'Q']}
                                       ])
                }
            }

        ]
    }
    property var keyCommandsOverview: ({
                                           // scrolling / page navigation
                                           scrollToBottom: {text:qsTr("Scroll current website to bottom"), method:function(){ webview.scrollToBottom()}},
                                           scrollToTop: {text:qsTr("Scroll current website to top"), method:function(){ webview.scrollToTop()}},
                                           reloadWebView: {text:qsTr("Reload current website"), method:function(){ webview.reload()}},
                                           goBack: {text:qsTr("Page History: Go back"), method:function(){webview.goBack()}},
                                           goForward: {text:qsTr("Page History: Go forward"), method:function(){webview.goForward()}},
                                           stopLoading: {text:qsTr("Stop loading the current website"), method:function(){webview.stop();}},

                                           // bookmarks
                                           addBookmark: {text:qsTr("Add current website as a bookmark"), method:function(){toolbar.bookmarkButton.addFavorite()}},
                                           showBookmarks: {text:qsTr("Show list of bookmarks"), method:function(){ toolbar.gotoButton.clicked(undefined)}},

                                           // tabs/windows
                                           openNewTab: {text:qsTr("Open new tab"), method:function(){ mainWindow.loadInNewTab("about:bookmarks");}},
                                           openNewWindow: {text:qsTr("Open new window"), method:function(){ mainWindow.openNewWindow("about:bookmarks")}},
                                           closeCurrentTab: {text:qsTr("Close current tab"), method:function(){ mainWindow.closeTab(mainWindow.tabModel.getIndexFromId(mainWindow.currentTab),mainWindow.currentTab)}},
                                           focusNextTab: {text:qsTr("Switch to next tab"), method:function(){ mainWindow.switchToTab(mainWindow.tabModel.get(mainWindow.tabModel.nextTab()).pageid)}},
                                           focusPreviousTab: {text:qsTr("Switch to previous tab"), method:function(){mainWindow.switchToTab(mainWindow.tabModel.get(mainWindow.tabModel.prevTab()).pageid)}},
                                           openPrivateNewWindow: {text:qsTr("Open new private window"), method:function(){mainWindow.openPrivateNewWindow("http://about:blank")}},

                                           // in-page search
                                           showSearchBar: {text:qsTr("Show in-page search"), method:function(){ extraToolbar.searchModeButton.clicked(undefined)}},
                                           hideSearchBar: {text:qsTr("Hide in-page search"), method:function(){ page.searchMode = false}},
                                           submitSearchBar: {text:qsTr("Start in-page search"), method:function(){ searchIcon.clicked(undefined)}},

                                           // misc
                                           toggleReaderMode: {text:qsTr("Toggle reader mode"), method:function(){ extraToolbar.readerModeButton.clicked(undefined)}},
                                           focusUrlBar: {text:qsTr("Focus URL bar"), method:function(){ toolbar.state = "expanded"; toolbar.urlText.forceActiveFocus()}},
                                           exit: {text:qsTr("Close current WebCat window"), method:function(){ Qt.quit()}},

                                       })
    property var keyboardSettings:([]) //overridden in state
    function handleKeyPress(event) {
        if(debounceTimer.running) {
            return;
        }

        for (var i=0; i<keyboardSettings.length; i++) {
            if(event.key === keyboardSettings[i].key) {
                console.log('at least key matches',
                            keyboardSettings[i].methods.join('|'),
                            event.modifiers,
                            keyboardSettings[i].modifiers,
                            'b:', keyboardSettings[i].requirements)
            }

            if(event.key === keyboardSettings[i].key
                    && (typeof keyboardSettings[i].modifiers !== 'undefined' ? event.modifiers === keyboardSettings[i].modifiers : true)
                    && (typeof keyboardSettings[i].requirements !== 'undefined' ? keyboardSettings[i].requirements : true)) {
                for(var methodsIndex=0;methodsIndex < keyboardSettings[i].methods.length; methodsIndex++) {
                    keyCommandsOverview[keyboardSettings[i].methods[methodsIndex]].method();
                }

                event.accepted = true;
                debounceTimer.start()
                break;
            }
        }
    }
    Timer {
        id: debounceTimer
        interval: 600
    }
}
