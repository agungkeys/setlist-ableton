// Setlist Manager for Max for Live
// Author: Hermes Agent
// Description: Powerful setlist management for Ableton Live

autowatch = 1;
inlets = 1;
outlets = 1;

// --- State ---
var setlist = [];
var currentIndex = 0;
var sections = [];
var isPlaying = false;

// --- Live API ---
var liveSet = null;
var transport = null;
var scenes = null;

// --- UI References (dari patcher) ---
var uiPlaylist = null;
var uiNowPlaying = null;
var uiSectionList = null;
var uiCurrentSection = null;

// =====================
// INITIALIZATION
// =====================

function init() {
    // Initialize Live API
    liveSet = new LiveAPI("live_set");
    transport = new LiveAPI("live_set transport");
    scenes = new LiveAPI("live_set scenes");

    // Setup UI references (akan dikaitkan via patcher)
    // uiPlaylist = this.patcher.getnamed("playlist_list");
    // uiNowPlaying = this.patcher.getnamed("now_playing");

    loadDefaultSetlist();
    updateUI();
    post("Setlist Manager initialized.\n");
}

// =====================
// SETLIST MANAGEMENT
// =====================

function addSong(title, sceneIndex, color) {
    var song = {
        id: Date.now(),
        title: title || "Untitled",
        sceneIndex: sceneIndex || 0,
        color: color || "#ff6b9d",
        notes: "",
        bpm: 120,
        key: "Cmaj",
        duration: 0
    };
    setlist.push(song);
    updateUI();
    return song;
}

function removeSong(id) {
    for (var i = 0; i < setlist.length; i++) {
        if (setlist[i].id === id) {
            setlist.splice(i, 1);
            if (currentIndex >= setlist.length && setlist.length > 0) {
                currentIndex = setlist.length - 1;
            }
            updateUI();
            return true;
        }
    }
    return false;
}

function moveSong(fromIndex, toIndex) {
    if (fromIndex < 0 || fromIndex >= setlist.length) return false;
    if (toIndex < 0 || toIndex >= setlist.length) return false;

    var song = setlist.splice(fromIndex, 1)[0];
    setlist.splice(toIndex, 0, song);
    updateUI();
    return true;
}

function clearSetlist() {
    setlist = [];
    currentIndex = 0;
    updateUI();
}

function loadDefaultSetlist() {
    setlist = [
        { id: 1, title: "SONG 1", sceneIndex: 0, color: "#4a90d9", notes: "Opening set", bpm: 128, key: "Am", duration: 0 },
        { id: 2, title: "SONG 2", sceneIndex: 1, color: "#4a90d9", notes: "", bpm: 124, key: "C", duration: 0 },
        { id: 3, title: "SONG 3", sceneIndex: 2, color: "#4a90d9", notes: "", bpm: 122, key: "G", duration: 0 },
        { id: 4, title: "SONG 4", sceneIndex: 3, color: "#ff6b9d", notes: "NOW PLAYING", bpm: 120, key: "F", duration: 0 },
        { id: 5, title: "SONG 5", sceneIndex: 4, color: "#4a90d9", notes: "", bpm: 118, key: "Em", duration: 0 },
        { id: 6, title: "SONG 6", sceneIndex: 5, color: "#4a90d9", notes: "", bpm: 116, key: "D", duration: 0 },
        { id: 7, title: "SONG 7", sceneIndex: 6, color: "#4a90d9", notes: "Break song", bpm: 114, key: "Bm", duration: 0 },
        { id: 8, title: "SONG 8", sceneIndex: 7, color: "#4a90d9", notes: "", bpm: 112, key: "A", duration: 0 },
        { id: 9, title: "SONG 9", sceneIndex: 8, color: "#4a90d9", notes: "", bpm: 110, key: "E", duration: 0 },
        { id: 10, title: "SONG 10", sceneIndex: 9, color: "#4a90d9", notes: "", bpm: 108, key: "Am", duration: 0 },
        { id: 11, title: "SONG 11", sceneIndex: 10, color: "#4a90d9", notes: "Closing", bpm: 106, key: "C", duration: 0 }
    ];
    currentIndex = 3; // SONG 4 playing
}

// =====================
// PLAYBACK CONTROL
// =====================

function play() {
    if (setlist.length === 0) return;
    var song = setlist[currentIndex];

    // Jump to scene in Ableton
    scenes.set("scene", song.sceneIndex);

    // Start transport
    transport.call("fire");

    isPlaying = true;
    updateUI();
    outlet(0, "play", song.title);
}

function stop() {
    transport.call("stop");
    isPlaying = false;
    updateUI();
    outlet(0, "stop");
}

function resume() {
    transport.call("continue");
    isPlaying = true;
    updateUI();
    outlet(0, "resume");
}

function next() {
    if (setlist.length === 0) return;
    currentIndex = (currentIndex + 1) % setlist.length;
    play();
}

function prev() {
    if (setlist.length === 0) return;
    currentIndex = (currentIndex - 1 + setlist.length) % setlist.length;
    play();
}

function jumpToSong(index) {
    if (index < 0 || index >= setlist.length) return;
    currentIndex = index;
    play();
}

function refresh() {
    // Re-sync with Ableton - check current playing scene
    var currentScene = scenes.get("scene");
    for (var i = 0; i < setlist.length; i++) {
        if (setlist[i].sceneIndex === currentScene) {
            currentIndex = i;
            break;
        }
    }
    updateUI();
    outlet(0, "refresh");
}

// =====================
// SECTION MANAGEMENT
// =====================

function addSection(name, startIndex, endIndex) {
    var section = {
        id: Date.now(),
        name: name || "Section",
        startIndex: startIndex || 0,
        endIndex: endIndex || setlist.length - 1,
        color: "#9b59b6"
    };
    sections.push(section);
    updateUI();
    return section;
}

function removeSection(id) {
    for (var i = 0; i < sections.length; i++) {
        if (sections[i].id === id) {
            sections.splice(i, 1);
            updateUI();
            return true;
        }
    }
    return false;
}

function playSection(id) {
    for (var i = 0; i < sections.length; i++) {
        if (sections[i].id === id) {
            currentIndex = sections[i].startIndex;
            play();
            return true;
        }
    }
    return false;
}

// =====================
// UI UPDATE
// =====================

function updateUI() {
    if (!uiPlaylist) return;

    // Update playlist display
    var playlistText = "";
    for (var i = 0; i < setlist.length; i++) {
        var marker = (i === currentIndex) ? "▶ " : "  ";
        playlistText += marker + setlist[i].title + "\n";
    }
    uiPlaylist.set(playlistText);

    // Update now playing
    if (setlist.length > 0 && uiNowPlaying) {
        uiNowPlaying.set(setlist[currentIndex].title);
    }

    // Update section list
    if (uiSectionList) {
        var sectionText = "";
        for (var j = 0; j < sections.length; j++) {
            sectionText += sections[j].name + "\n";
        }
        uiSectionList.set(sectionText);
    }
}

// =====================
// PERSISTENCE (JSON)
// =====================

function saveSetlist(filepath) {
    var data = {
        setlist: setlist,
        currentIndex: currentIndex,
        sections: sections,
        savedAt: new Date().toISOString()
    };

    // In Max, use File object to save
    var f = new File(filepath, "write", "TEXT");
    if (f.isopen) {
        f.writeline(JSON.stringify(data));
        f.close();
        return true;
    }
    return false;
}

function loadSetlist(filepath) {
    var f = new File(filepath, "read");
    if (f.isopen) {
        var content = "";
        while (f.position < f.eof) {
            content += f.readline();
        }
        f.close();

        var data = JSON.parse(content);
        if (data.setlist) {
            setlist = data.setlist;
            currentIndex = data.currentIndex || 0;
            sections = data.sections || [];
            updateUI();
            return true;
        }
    }
    return false;
}

// =====================
// UTILITY
// =====================

function getSetlist() {
    return setlist;
}

function getCurrentSong() {
    if (setlist.length === 0) return null;
    return setlist[currentIndex];
}

function getSections() {
    return sections;
}

// =====================
// MESSAGE HANDLERS
// =====================

function msg_int(v) {
    // Handle integer messages from UI (list indices, etc.)
    if (v >= 0 && v < setlist.length) {
        jumpToSong(v);
    }
}

function anything() {
    var args = arrayfromargs(messagename, arguments);
    var command = args[0];

    switch (command) {
        case "add":
            addSong(args[1], args[2], args[3]);
            break;
        case "remove":
            removeSong(args[1]);
            break;
        case "move":
            moveSong(args[1], args[2]);
            break;
        case "clear":
            clearSetlist();
            break;
        case "save":
            saveSetlist(args[1]);
            break;
        case "load":
            loadSetlist(args[1]);
            break;
        case "addSection":
            addSection(args[1], args[2], args[3]);
            break;
        case "playSection":
            playSection(args[1]);
            break;
    }
}

// Initialize on load
init();
