//db.js
.import QtQuick.LocalStorage 2.0 as LS

var defaultAgent="Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"
// First, let's create a short helper function to get the database connection
function getDatabase() {
    return LS.LocalStorage.openDatabaseSync("webcatbrowser", "0.8", "StorageDatabase", 100000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx,er) {
                    // Create the bookmarks table if it doesn't already exist
                    // If the table exists, this is skipped
                    tx.executeSql('CREATE TABLE IF NOT EXISTS bookmarks(title TEXT, url TEXT, agent TEXT)');
                    var table  = tx.executeSql("SELECT * FROM bookmarks");
                    // Insert default bookmarks if no bookmarks are set / empty bookmarks db
                    if (table.rows.length === 0) {
                        tx.executeSql('INSERT INTO bookmarks VALUES (?,?,?);', ["Jolla Together", "http://together.jolla.com/", defaultAgent]);
                        tx.executeSql('INSERT INTO bookmarks VALUES (?,?,?);', ["Maemo forum", "http://talk.maemo.org/", defaultAgent]);
                        tx.executeSql('INSERT INTO bookmarks VALUES (?,?,?);', ["Jolla users", "http://jollausers.com/", defaultAgent]);
                        tx.executeSql('INSERT INTO bookmarks VALUES (?,?,?);', ["Jolla users forum", "http://forum.jollausers.com/", defaultAgent]);
                        tx.executeSql('INSERT INTO bookmarks VALUES (?,?,?);', ["Jolla Tides", "http://jollatides.com/", defaultAgent]);
                        tx.executeSql('INSERT INTO bookmarks VALUES (?,?,?);', ["Review Jolla", "http://reviewjolla.blogspot.se/", defaultAgent]);
                    }
                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT, value TEXT)');

                    tx.executeSql('CREATE TABLE IF NOT EXISTS history(uid INTEGER UNIQUE, url TEXT)');
                    // Limit history entries to 100
                    tx.executeSql('CREATE TRIGGER IF NOT EXISTS delete_till_100 INSERT ON history WHEN (select count(*) from history)>99 \
                    BEGIN \
                        DELETE FROM history WHERE history.uid IN (SELECT history.uid FROM history ORDER BY history.uid limit (select count(*) -100 from history)); \
                    END;')
                });
}

// This function is used to write bookmarks into the database
function addBookmark(title,url,agent) {
    var date = new Date();
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        // Remove and readd if url already in history
        removeBookmark(url);
        console.debug("Adding to bookmarks db:" + title + " " + url);

        var rs = tx.executeSql('INSERT OR REPLACE INTO bookmarks VALUES (?,?,?);', [title,url,agent]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Saved to database");
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to remove a bookmark from database
function removeBookmark(url) {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM bookmarks WHERE url=(?);', [url]);
        if (rs.rowsAffected > 0) {
            console.debug("Url found and removed");
        } else {
            console.debug("Url not found");
        }
    })
}

// This function is used to retrieve bookmarks from database
function getBookmarks() {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM bookmarks ORDER BY bookmarks.title;');
        for (var i = 0; i < rs.rows.length; i++) {
            // For compatibility reasons with older versions
            if (rs.rows.item(i).agent) modelUrls.append({"title" : rs.rows.item(i).title, "url" : rs.rows.item(i).url, "agent" : rs.rows.item(i).agent});
            else modelUrls.append({"title" : rs.rows.item(i).title, "url" : rs.rows.item(i).url, "agent" : "Mozilla/5.0 (Maemo; Linux; Jolla; Sailfish; Mobile) AppleWebKit/534.13 (KHTML, like Gecko) NokiaBrowser/8.5.0 Mobile Safari/534.13"});
            //console.debug("Get Bookmarks from db:" + rs.rows.item(i).title, rs.rows.item(i).url)
        }
    })
}

// This function is used to write settings into the database
function addSetting(setting,value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Setting written to database");
        } else {
            res = "Error";
            console.log ("Error writing setting to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

function stringToBoolean(str) {
    switch(str.toLowerCase()){
    case "true": case "yes": case "1": return true;
    case "false": case "no": case "0": case null: return false;
    default: return Boolean(string);
    }
}

// This function is used to retrieve settings from database
function getSettings() {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM settings;');
        for (var i = 0; i < rs.rows.length; i++) {
            if (rs.rows.item(i).setting == "minimumFontSize") mainWindow.minimumFontSize = parseInt(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "defaultFontSize") mainWindow.defaultFontSize = parseInt(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "defaultFixedFontSize") mainWindow.defaultFixedFontSize = parseInt(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "loadImages") mainWindow.loadImages = stringToBoolean(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "privateBrowsing") mainWindow.privateBrowsing = stringToBoolean(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "dnsPrefetch") mainWindow.dnsPrefetch = stringToBoolean(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "userAgent") mainWindow.userAgent = rs.rows.item(i).value
            else if (rs.rows.item(i).setting == "homepage") mainWindow.siteURL = rs.rows.item(i).value
            else if (rs.rows.item(i).setting == "offlineWebApplicationCache") mainWindow.offlineWebApplicationCache = stringToBoolean(rs.rows.item(i).value)
            else if (rs.rows.item(i).setting == "userAgentName") mainWindow.userAgentName = rs.rows.item(i).value
            else if (rs.rows.item(i).setting == "searchEngine") mainWindow.searchEngine = rs.rows.item(i).value
            else if (rs.rows.item(i).setting == "searchEngineName") mainWindow.searchEngineName = rs.rows.item(i).value
        }
    })
}

// This function is used to write history into the database
function addHistory(url) {
    var date = new Date();
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        // Remove and readd if url already in history
        var rs0 = tx.executeSql('delete from history where url=(?);',[url]);
        if (rs0.rowsAffected > 0) {
            console.debug("Url already found and removed to readd it");
        } else {
            console.debug("Url not found so add it newly");
        }

        var rs = tx.executeSql('INSERT OR REPLACE INTO history VALUES (?,?);', [date.getTime(),url]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Saved to database");
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

function searchHistory(searchTerm) {
    var db = getDatabase();
    db.transaction(function(tx) {
        // Search history first
        var rs = tx.executeSql("SELECT url FROM history WHERE url LIKE ?;", ["%" + searchTerm + "%"]);
//        if (rs.rowsAffected > 0) {
//            console.debug("Successfully executed")
//            console.debug(rs.rows.item(0).url)
//        }
//        else console.debug("Not working")

        if (rs.rows.length > 0) {
            // Clear previous historySuggestions here
            mainWindow.historyModel.clear();
            // And show history suggestions
            page.suggestionView.visible = true;
        }
        for (var i = 0; i < rs.rows.length; i++) {
            // Add to historySuggestions here
            mainWindow.historyModel.append({"url" : rs.rows.item(i).url});
            //console.debug(rs.rows.item(i).url);
        }
        // Search bookmarks second
        var rs1 = tx.executeSql("SELECT url FROM bookmarks WHERE url LIKE ?;", ["%" + searchTerm + "%"]);
        if (rs1.rows.length > 0) {
            // Show bookmarks suggestions
            if (page.suggestionView.visible == false) page.suggestionView.visible = true;
        }
        for (var i = 0; i < rs1.rows.length; i++) {
            // Add to historySuggestions here
            if (! historyModel.contains(rs1.rows.item(i).url)) mainWindow.historyModel.append({"url" : rs1.rows.item(i).url});
            //console.debug(rs.rows.item(i).url);
        }
    }
    );
}
