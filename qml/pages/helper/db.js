//db.js
.import QtQuick.LocalStorage 2.0 as LS
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
                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT, value TEXT)');
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
        }
    })
}
