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
                function(tx) {
                    // Create the history table if it doesn't already exist
                    // If the table exists, this is skipped
                    tx.executeSql('CREATE TABLE IF NOT EXISTS bookmarks(title TEXT, url TEXT)');
                });
}

// This function is used to write bookmarks into the database
function addBookmark(title,url) {
    var date = new Date();
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        // Remove and readd if url already in history
        removeBookmark(url);
        console.debug("Adding to bookmarks db:" + title + " " + url);

        var rs = tx.executeSql('INSERT OR REPLACE INTO bookmarks VALUES (?,?);', [title,url]);
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
            modelUrls.append({"title" : rs.rows.item(i).title, "url" : rs.rows.item(i).url});
            //console.debug("Get Bookmarks from db:" + rs.rows.item(i).title, rs.rows.item(i).url)
        }
    })
}
