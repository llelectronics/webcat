var ytDirectStreamUrl;
var ytfailCount;
var ytApiKey = 'AIzaSyBHWWmICLJr2-MoxRjTS7qs2vOJ5HY86so'

function checkYoutube(url) {
    // Yeah I hate RegEx. Thx user2200660 for this nice youtube regex ;)
    //if (url.match('/?.*(?:youtu.be\\/|v\\/|u/\\w/|embed\\/|watch\\?.*&?v=)')) {
    // Use more advanced regex to detect youtube video urls
    if (url.match(/https?:\/\/(?:[0-9A-Z-]+\.)?(?:youtu\.be\/|youtube(?:-nocookie)?\.com(?:\/embed\/|\/v\/|\/watch\?v=|\/ytscreeningroom\?v=|\/feeds\/api\/videos\/|\/user\S*[^\w\-\s]|\S*[^\w\-\s]))([\w\-]{11})[?=&+%\w-]*/ig) || url.match(/ytapi.com/)) {
        //console.debug("Youtube URL detected");
        return true;
    }
    else {
        return false;
    }
} 

function getYtID(url) {
    var youtube_id;
    var ytregex = new RegExp(/^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*/);
    youtube_id = ytregex.exec(url)[1];
    //console.debug("Youtube ID: " + youtube_id);
    return youtube_id;
}

function getYoutubeVid(url,firstPage,listId) {
    var youtube_id;
    youtube_id = getYtID(url);
    var ytUrl = getYoutubeStream(youtube_id,firstPage,listId);
    //if (ytUrl !== "") return ytUrl;  // XMLHttpRequest does not know synchronus in QML so I need to restructe everything if I directly want to use Youtubes server
    return("http://ytapi.com/?vid=" + youtube_id + "&format=direct");
}

function getYoutubeTitle(url,firstPage,listId) {
    var youtube_id;
    youtube_id = getYtID(url);
    var xhr = new XMLHttpRequest();
    xhr.open("GET","https://www.googleapis.com/youtube/v3/videos?id=" + youtube_id + "&key="+ ytApiKey + "&fields=items(snippet(title))&part=snippet",true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                var jsonObject = eval('(' + xhr.responseText + ')');
                console.log("Youtube Title: " + jsonObject.items[0].snippet.title);
                firstPage.mediaList.set(listId,{"mediaTitle": jsonObject.items[0].snippet.title});
            } else {
                console.log("responseText", xhr.responseText);
            }
        }
    }
    xhr.send();
}

function getYoutubeDirectStream(url,firstPage,listId) {
    ytfailCount = 0;
    try {
        var vid = getYoutubeVid(url,firstPage,listId);
    }
    catch(e) {
        //console.debug("[yt.js]: " + e)
        //console.debug("Assuming it is probably not a youtube video link")
        firstPage.ytUrlLoading = false
        firstPage.mediaYt = false
        firstPage.mediaLink = false
        firstPage.mediaDownloadRec.visible = false
        firstPage.mediaDownloadRec.mediaUrl = ""
        return;
    }
    try {
        getYoutubeTitle(url,firstPage,listId)
    }
    catch (e) {
        //console.debug("[yt.js] Youtube Stream Title not found: " + e)
        return;
    }
}


// This would be a proper way to get the youtube video stream url
function getYoutubeStream(youtube_id, firstPage, listId) {

    var doc = new XMLHttpRequest();

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {

            var videoInfo = doc.responseText;

            var videoInfoSplit = videoInfo.split("&");
            var streams;
            var paramPair;

            for (var i = 0; i < videoInfo.length; i++) {
                try {
                    paramPair = videoInfoSplit[i].split("=");
                    //console.debug(paramPair[0] + " = " +  paramPair[1]);
                } catch(e) {
                    //console.debug("[yt.js]: " + e)
                    continue;
                }
                if (paramPair[0] === "url_encoded_fmt_stream_map") {
                    //console.debug("[yt.js] Streams found")
                    streams = decodeURIComponent(paramPair[1]);
                    break;
                }
            }


            if (!streams) {
                var msg = "YouTube videoInfo parsing: url_encoded_fmt_stream_map not found";
                //console.debug(msg);
                // Last chance if we don't get the direct video stream url parse the youtube url directly to external player
                //firstPage.ytUrlLoading = false
                //firstPage.ytStreamUrl = getYoutubeVid(firstPage.url)
                //return;
            }

            try {
                var streamsSplit = streams.split(",");
            } catch(e) {
                  msg = "[yt.js]: " + e
//                console.debug(msg)
            }
            try {
                var secondSplit;
                var found = false;
                for (var i = 0; i < streamsSplit.length; i++) {
                    secondSplit = streamsSplit[i].split("&");
                    //console.debug(" --- STREAMSPLIT 2 --- : " + secondSplit[0] + " , " + secondSplit[1]);
                    //}


                    var url="", sig="", itag="";
                    var resolutionFormat;
                    for (var j = 0; j < secondSplit.length; j++) {
                        paramPair = secondSplit[j].split("=");
//                        console.debug(" --- STREAMS PARAM PAIR : " + j);
//                        console.debug(" --- STREAMS PARAM PAIR --- : " + paramPair[0] + " = " + paramPair[1]);
                        if (paramPair[0] === "url") {
                            url = decodeURIComponent(paramPair[1]);
                        } else if (paramPair[0] === "sig") {
                            sig = paramPair[1]; // do not decode, as we would have to encode it later (although decoding/encoding has currently no effect for the signature)
                        } else if (paramPair[0] === "itag") {
                            itag = paramPair[1];
                        }
                        //***********************************************//
                        //     List of video formats as of 2015.12.02    //
                        // fmt=17   144p        vq=?           ?    vorbis   //
                        // fmt=36   240p        vq=small/tiny  mp4  aac   //
                        // fmt=5    240p        vq=small/tiny  flv  mp3      //
                        // fmt=18   360p        vq=medium      mp4  aac      //
                        // fmt=34   360p        vq=medium      flv  aac      //
                        // fmt=43   360p        vq=medium      vp8  vorbis   //
                        // fmt=35   480p        vq=large       flv  aac      //
                        // fmt=44   480p        vq=large       vp8  vorbis   //
                        // fmt=22   720p        vq=hd720       mp4  aac      //
                        // fmt=45   720p        vq=hd720       vp8  vorbis   //
                        // fmt=37  1080p        vq=hd1080      mp4  aac      //
                        // fmt=46  1080p        vq=hd1080      vp8  vorbis   //
                        // fmt=38  1536p        vq=highres     mp4  aac      //
                        //***********************************************//

                        // Try to get 720p HD video stream first
                        if (itag === "22" && typeof url !== 'undefined' && url != "") { // 7 parameters per video 2 of them unidentified; itag 22 is "MP4 720p", see http://userscripts.org/scripts/review/25105
                            resolutionFormat = "MP4 720p"
                            url += "&signature=" + sig;
                            firstPage.mediaList.set(listId,{"yt720p": url});
                            found = true;
                            //console.debug("[yt.js] Found 720p video with listId: " + listId + " and stream: " + url);
                            break;
                        }
                        // If above fails try to get 480p video stream
                        else if (itag === "35" && typeof url !== 'undefined' && url != "") { // 7 parameters per video 2 of them unidentified; itag 35 is "FLV 480p", see http://userscripts.org/scripts/review/25105
                            resolutionFormat = "FLV 480p"
                            firstPage.mediaList.set(listId,{"yt480p": url += "&signature=" + sig});
                            if (found == false) url += "&signature=" + sig;
                            found = true;
                            //console.debug("[yt.js] Found 480p video")
                            break;
                        }
                        // If above fails try to get 360p video stream
                        else if (itag === "18" && typeof url !== 'undefined' && url != "") { // 7 parameters per video 2 of them unidentified; itag 18 is "MP4 360p", see http://userscripts.org/scripts/review/25105
                            resolutionFormat = "MP4 360p"
                            firstPage.mediaList.set(listId,{"yt360p": url += "&signature=" + sig});
                            if (found == false) url += "&signature=" + sig;
                            found = true;
                            //console.debug("[yt.js] Found 360p video")
                            break;
                        }
                        // If above fails try to get 240p video stream
                        else if (itag === "36" && typeof url !== 'undefined' && url != "") { // 7 parameters per video 2 of them unidentified; itag 36 is "3GPP 240p", see http://userscripts.org/scripts/review/25105
                            resolutionFormat = "FLV 240p"
                            firstPage.mediaList.set(listId,{"yt240p": url += "&signature=" + sig});
                            if (found == false) url += "&signature=" + sig;
                            found = true;
                            //console.debug("[yt.js] Found 240p video")
                            break;
                        }
                    }
                }

                if (found) {
                    //console.debug("[yt.js]: Video in format " + resolutionFormat + " found with direct URL: " + url);
                    firstPage.ytStreamUrl = url
                    firstPage.ytUrlLoading = false
                    firstPage.mediaDownloadRec.visible = true
                    return url;

                } else {
                    var msg = "Couldn't find video either in MP4 720p, FLV 480p, MP4 360p and FLV 240p";
                    //console.debug(msg);
                    firstPage.ytUrlLoading = false
                    firstPage.mediaYt = false
                    firstPage.mediaDownloadRec.visible = false
                    return;
                }
            } catch(e) {
                //console.debug("[yt.js]: " + e)
                //console.debug("[yt.js] ytfailCount: " +ytfailCount);
                ytfailCount++;
                getYoutubeStream(youtube_id, firstPage,listId);
            }

        }



    }

    if (ytfailCount == 0) {
    doc.open("GET", "https://www.youtube.com/get_video_info?video_id=" + youtube_id);
    doc.send();
    }
    else if (ytfailCount == 1) {
        doc.abort()
        doc.open("GET", "https://www.youtube.com/get_video_info?video_id=" + youtube_id + "&el=embedded");
        doc.send();
    }
    else if (ytfailCount == 2) {
        doc.abort()
        doc.open("GET", "https://www.youtube.com/get_video_info?video_id=" + youtube_id + "&el=detailpage");
        doc.send();
    }
    else if (ytfailCount == 3) {
        doc.abort()
        doc.open("GET", "https://www.youtube.com/get_video_info?video_id=" + youtube_id + "&el=vevo");
        doc.send();
    }
    else {
//        console.debug("[yt.js] ytfailCount:" + ytfailCount);
//        console.debug("Could not find video stream.")
        ytfailCount = 0
    }
}

// Damn it RegExp again :P
function getDownloadableTitleString(streamTitle) {
    if (streamTitle.match(/\//g)) streamTitle = streamTitle.replace(/\//g, "");
    if (streamTitle.match(/\?/g)) streamTitle = streamTitle.replace(/\?/g,'');
    if (streamTitle.match('!')) streamTitle = streamTitle.replace("!", "");
    if (streamTitle.match(/\*/g)) streamTitle = streamTitle.replace(/\*/g, "");
    if (streamTitle.match('`')) streamTitle = streamTitle.replace("`", "");
    if (streamTitle.match('~')) streamTitle = streamTitle.replace("~", "");
    if (streamTitle.match('@')) streamTitle = streamTitle.replace("@", "");
    if (streamTitle.match('#')) streamTitle = streamTitle.replace("#", "");
    if (streamTitle.match('$')) streamTitle = streamTitle.replace("$", "");
    if (streamTitle.match('%')) streamTitle = streamTitle.replace("%", "");
    if (streamTitle.match('^')) streamTitle = streamTitle.replace("^", "");
    if (streamTitle.match(/\\/g)) streamTitle = streamTitle.replace(/\\/g, "");
    if (streamTitle.match('|')) streamTitle = streamTitle.replace("|", "");
    if (streamTitle.match('<')) streamTitle = streamTitle.replace("<", "");
    if (streamTitle.match('>')) streamTitle = streamTitle.replace(">", "");
    if (streamTitle.match(';')) streamTitle = streamTitle.replace(";", "");
    if (streamTitle.match(':')) streamTitle = streamTitle.replace(":", "");
    if (streamTitle.match('\'')) streamTitle = streamTitle.replace("\'", "");
    if (streamTitle.match('\"')) streamTitle = streamTitle.replace("\"", "");
    if (streamTitle.match(/\[/g)) streamTitle = streamTitle.replace(/\[/g, "");
    if (streamTitle.match(/\]/g)) streamTitle = streamTitle.replace(/\]/g, "");
    if (streamTitle.match(/\{/g)) streamTitle = streamTitle.replace(/\{/g, "");
    if (streamTitle.match(/\}/g)) streamTitle = streamTitle.replace(/\}/g, "");
    return streamTitle;
}
