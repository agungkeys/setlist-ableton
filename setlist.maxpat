{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 8,
      "minor": 6,
      "revision": 2,
      "architecture": "x64",
      "modernui": 1
    },
    "classnamespace": "box",
    "rect": [
      100,
      100,
      900,
      700
    ],
    "bgcolor": [
      0.15,
      0.15,
      0.15,
      1.0
    ],
    "openinpresentation": 1,
    "defaultpatcherview": 1,
    "bglocked": 0,
    "openrect": [
      0,
      0,
      900,
      700
    ],
    "defaultel": 1,
    "gridsize": [
      15,
      15
    ],
    "boxes": [
      {
        "maxclass": "comment",
        "text": "SETLIST MANAGER v1.0",
        "patching_rect": [
          30,
          20,
          250,
          25
        ],
        "textcolor": [
          1.0,
          0.42,
          0.62,
          1.0
        ],
        "fontsize": 18.0,
        "fontname": "Arial Bold",
        "id": "comment_title"
      },
      {
        "maxclass": "newobj",
        "text": "js setlist.js",
        "patching_rect": [
          30,
          60,
          120,
          22
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "setlist_js",
        "saved_object_attributes": {
          "embed": 1,
          "source": "// Setlist Manager for Max for Live\n// Author: Hermes Agent\n// Description: Powerful setlist management for Ableton Live\n\nautowatch = 1;\ninlets = 1;\noutlets = 1;\n\n// --- State ---\nvar setlist = [];\nvar currentIndex = 0;\nvar sections = [];\nvar isPlaying = false;\n\n// --- Live API ---\nvar liveSet = null;\nvar transport = null;\nvar scenes = null;\n\n// --- UI References (dari patcher) ---\nvar uiPlaylist = null;\nvar uiNowPlaying = null;\nvar uiSectionList = null;\nvar uiCurrentSection = null;\n\n// =====================\n// INITIALIZATION\n// =====================\n\nfunction init() {\n    // Initialize Live API\n    liveSet = new LiveAPI(\"live_set\");\n    transport = new LiveAPI(\"live_set transport\");\n    scenes = new LiveAPI(\"live_set scenes\");\n\n    // Setup UI references (akan dikaitkan via patcher)\n    // uiPlaylist = this.patcher.getnamed(\"playlist_list\");\n    // uiNowPlaying = this.patcher.getnamed(\"now_playing\");\n\n    loadDefaultSetlist();\n    updateUI();\n    post(\"Setlist Manager initialized.\\n\");\n}\n\n// =====================\n// SETLIST MANAGEMENT\n// =====================\n\nfunction addSong(title, sceneIndex, color) {\n    var song = {\n        id: Date.now(),\n        title: title || \"Untitled\",\n        sceneIndex: sceneIndex || 0,\n        color: color || \"#ff6b9d\",\n        notes: \"\",\n        bpm: 120,\n        key: \"Cmaj\",\n        duration: 0\n    };\n    setlist.push(song);\n    updateUI();\n    return song;\n}\n\nfunction removeSong(id) {\n    for (var i = 0; i < setlist.length; i++) {\n        if (setlist[i].id === id) {\n            setlist.splice(i, 1);\n            if (currentIndex >= setlist.length && setlist.length > 0) {\n                currentIndex = setlist.length - 1;\n            }\n            updateUI();\n            return true;\n        }\n    }\n    return false;\n}\n\nfunction moveSong(fromIndex, toIndex) {\n    if (fromIndex < 0 || fromIndex >= setlist.length) return false;\n    if (toIndex < 0 || toIndex >= setlist.length) return false;\n\n    var song = setlist.splice(fromIndex, 1)[0];\n    setlist.splice(toIndex, 0, song);\n    updateUI();\n    return true;\n}\n\nfunction clearSetlist() {\n    setlist = [];\n    currentIndex = 0;\n    updateUI();\n}\n\nfunction loadDefaultSetlist() {\n    setlist = [\n        { id: 1, title: \"SONG 1\", sceneIndex: 0, color: \"#4a90d9\", notes: \"Opening set\", bpm: 128, key: \"Am\", duration: 0 },\n        { id: 2, title: \"SONG 2\", sceneIndex: 1, color: \"#4a90d9\", notes: \"\", bpm: 124, key: \"C\", duration: 0 },\n        { id: 3, title: \"SONG 3\", sceneIndex: 2, color: \"#4a90d9\", notes: \"\", bpm: 122, key: \"G\", duration: 0 },\n        { id: 4, title: \"SONG 4\", sceneIndex: 3, color: \"#ff6b9d\", notes: \"NOW PLAYING\", bpm: 120, key: \"F\", duration: 0 },\n        { id: 5, title: \"SONG 5\", sceneIndex: 4, color: \"#4a90d9\", notes: \"\", bpm: 118, key: \"Em\", duration: 0 },\n        { id: 6, title: \"SONG 6\", sceneIndex: 5, color: \"#4a90d9\", notes: \"\", bpm: 116, key: \"D\", duration: 0 },\n        { id: 7, title: \"SONG 7\", sceneIndex: 6, color: \"#4a90d9\", notes: \"Break song\", bpm: 114, key: \"Bm\", duration: 0 },\n        { id: 8, title: \"SONG 8\", sceneIndex: 7, color: \"#4a90d9\", notes: \"\", bpm: 112, key: \"A\", duration: 0 },\n        { id: 9, title: \"SONG 9\", sceneIndex: 8, color: \"#4a90d9\", notes: \"\", bpm: 110, key: \"E\", duration: 0 },\n        { id: 10, title: \"SONG 10\", sceneIndex: 9, color: \"#4a90d9\", notes: \"\", bpm: 108, key: \"Am\", duration: 0 },\n        { id: 11, title: \"SONG 11\", sceneIndex: 10, color: \"#4a90d9\", notes: \"Closing\", bpm: 106, key: \"C\", duration: 0 }\n    ];\n    currentIndex = 3; // SONG 4 playing\n}\n\n// =====================\n// PLAYBACK CONTROL\n// =====================\n\nfunction play() {\n    if (setlist.length === 0) return;\n    var song = setlist[currentIndex];\n\n    // Jump to scene in Ableton\n    scenes.set(\"scene\", song.sceneIndex);\n\n    // Start transport\n    transport.call(\"fire\");\n\n    isPlaying = true;\n    updateUI();\n    outlet(0, \"play\", song.title);\n}\n\nfunction stop() {\n    transport.call(\"stop\");\n    isPlaying = false;\n    updateUI();\n    outlet(0, \"stop\");\n}\n\nfunction resume() {\n    transport.call(\"continue\");\n    isPlaying = true;\n    updateUI();\n    outlet(0, \"resume\");\n}\n\nfunction next() {\n    if (setlist.length === 0) return;\n    currentIndex = (currentIndex + 1) % setlist.length;\n    play();\n}\n\nfunction prev() {\n    if (setlist.length === 0) return;\n    currentIndex = (currentIndex - 1 + setlist.length) % setlist.length;\n    play();\n}\n\nfunction jumpToSong(index) {\n    if (index < 0 || index >= setlist.length) return;\n    currentIndex = index;\n    play();\n}\n\nfunction refresh() {\n    // Re-sync with Ableton - check current playing scene\n    var currentScene = scenes.get(\"scene\");\n    for (var i = 0; i < setlist.length; i++) {\n        if (setlist[i].sceneIndex === currentScene) {\n            currentIndex = i;\n            break;\n        }\n    }\n    updateUI();\n    outlet(0, \"refresh\");\n}\n\n// =====================\n// SECTION MANAGEMENT\n// =====================\n\nfunction addSection(name, startIndex, endIndex) {\n    var section = {\n        id: Date.now(),\n        name: name || \"Section\",\n        startIndex: startIndex || 0,\n        endIndex: endIndex || setlist.length - 1,\n        color: \"#9b59b6\"\n    };\n    sections.push(section);\n    updateUI();\n    return section;\n}\n\nfunction removeSection(id) {\n    for (var i = 0; i < sections.length; i++) {\n        if (sections[i].id === id) {\n            sections.splice(i, 1);\n            updateUI();\n            return true;\n        }\n    }\n    return false;\n}\n\nfunction playSection(id) {\n    for (var i = 0; i < sections.length; i++) {\n        if (sections[i].id === id) {\n            currentIndex = sections[i].startIndex;\n            play();\n            return true;\n        }\n    }\n    return false;\n}\n\n// =====================\n// UI UPDATE\n// =====================\n\nfunction updateUI() {\n    if (!uiPlaylist) return;\n\n    // Update playlist display\n    var playlistText = \"\";\n    for (var i = 0; i < setlist.length; i++) {\n        var marker = (i === currentIndex) ? \"\u25b6 \" : \"  \";\n        playlistText += marker + setlist[i].title + \"\\n\";\n    }\n    uiPlaylist.set(playlistText);\n\n    // Update now playing\n    if (setlist.length > 0 && uiNowPlaying) {\n        uiNowPlaying.set(setlist[currentIndex].title);\n    }\n\n    // Update section list\n    if (uiSectionList) {\n        var sectionText = \"\";\n        for (var j = 0; j < sections.length; j++) {\n            sectionText += sections[j].name + \"\\n\";\n        }\n        uiSectionList.set(sectionText);\n    }\n}\n\n// =====================\n// PERSISTENCE (JSON)\n// =====================\n\nfunction saveSetlist(filepath) {\n    var data = {\n        setlist: setlist,\n        currentIndex: currentIndex,\n        sections: sections,\n        savedAt: new Date().toISOString()\n    };\n\n    // In Max, use File object to save\n    var f = new File(filepath, \"write\", \"TEXT\");\n    if (f.isopen) {\n        f.writeline(JSON.stringify(data));\n        f.close();\n        return true;\n    }\n    return false;\n}\n\nfunction loadSetlist(filepath) {\n    var f = new File(filepath, \"read\");\n    if (f.isopen) {\n        var content = \"\";\n        while (f.position < f.eof) {\n            content += f.readline();\n        }\n        f.close();\n\n        var data = JSON.parse(content);\n        if (data.setlist) {\n            setlist = data.setlist;\n            currentIndex = data.currentIndex || 0;\n            sections = data.sections || [];\n            updateUI();\n            return true;\n        }\n    }\n    return false;\n}\n\n// =====================\n// UTILITY\n// =====================\n\nfunction getSetlist() {\n    return setlist;\n}\n\nfunction getCurrentSong() {\n    if (setlist.length === 0) return null;\n    return setlist[currentIndex];\n}\n\nfunction getSections() {\n    return sections;\n}\n\n// =====================\n// MESSAGE HANDLERS\n// =====================\n\nfunction msg_int(v) {\n    // Handle integer messages from UI (list indices, etc.)\n    if (v >= 0 && v < setlist.length) {\n        jumpToSong(v);\n    }\n}\n\nfunction anything() {\n    var args = arrayfromargs(messagename, arguments);\n    var command = args[0];\n\n    switch (command) {\n        case \"add\":\n            addSong(args[1], args[2], args[3]);\n            break;\n        case \"remove\":\n            removeSong(args[1]);\n            break;\n        case \"move\":\n            moveSong(args[1], args[2]);\n            break;\n        case \"clear\":\n            clearSetlist();\n            break;\n        case \"save\":\n            saveSetlist(args[1]);\n            break;\n        case \"load\":\n            loadSetlist(args[1]);\n            break;\n        case \"addSection\":\n            addSection(args[1], args[2], args[3]);\n            break;\n        case \"playSection\":\n            playSection(args[1]);\n            break;\n    }\n}\n\n// Initialize on load\ninit();\n"
        }
      },
      {
        "maxclass": "button",
        "patching_rect": [
          30,
          110,
          60,
          24
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          "bang"
        ],
        "id": "btn_init"
      },
      {
        "maxclass": "message",
        "text": "init",
        "patching_rect": [
          110,
          110,
          50,
          20
        ],
        "numinlets": 2,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "msg_init"
      },
      {
        "maxclass": "comment",
        "text": "LIST CONTROL",
        "patching_rect": [
          30,
          160,
          120,
          20
        ],
        "textcolor": [
          0.5,
          0.5,
          0.5,
          1.0
        ],
        "fontsize": 11.0,
        "id": "comment_list_control"
      },
      {
        "maxclass": "button",
        "patching_rect": [
          30,
          190,
          50,
          24
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          "bang"
        ],
        "id": "btn_add_song"
      },
      {
        "maxclass": "message",
        "text": "add \"New Song\" 0 \"#4a90d9\"",
        "patching_rect": [
          100,
          190,
          180,
          20
        ],
        "numinlets": 2,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "msg_add_song"
      },
      {
        "maxclass": "number",
        "patching_rect": [
          30,
          230,
          50,
          22
        ],
        "numinlets": 1,
        "numoutlets": 2,
        "outlettype": [
          "",
          "bang"
        ],
        "id": "num_song_id",
        "minimum": 1
      },
      {
        "maxclass": "message",
        "text": "remove",
        "patching_rect": [
          100,
          230,
          60,
          20
        ],
        "numinlets": 2,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "msg_remove"
      },
      {
        "maxclass": "button",
        "patching_rect": [
          30,
          270,
          50,
          24
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          "bang"
        ],
        "id": "btn_clear"
      },
      {
        "maxclass": "message",
        "text": "clear",
        "patching_rect": [
          100,
          270,
          50,
          20
        ],
        "numinlets": 2,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "msg_clear"
      },
      {
        "maxclass": "comment",
        "text": "SONG CONTROL",
        "patching_rect": [
          350,
          160,
          120,
          20
        ],
        "textcolor": [
          0.5,
          0.5,
          0.5,
          1.0
        ],
        "fontsize": 11.0,
        "id": "comment_song_control"
      },
      {
        "maxclass": "button",
        "patching_rect": [
          350,
          190,
          60,
          30
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          "bang"
        ],
        "id": "btn_play"
      },
      {
        "maxclass": "comment",
        "text": "Play",
        "patching_rect": [
          355,
          222,
          40,
          15
        ],
        "textcolor": [
          1.0,
          1.0,
          1.0,
          0.7
        ],
        "fontsize": 10.0,
        "id": "label_play"
      },
      {
        "maxclass": "message",
        "text": "play",
        "patching_rect": [
          350,
          250,
          50,
          20
        ],
        "numinlets": 2,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "msg_play"
      },
      {
        "maxclass": "button",
        "patching_rect": [
          440,
          190,
          60,
          30
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          "bang"
        ],
        "id": "btn_stop"
      },
      {
        "maxclass": "comment",
        "text": "Stop",
        "patching_rect": [
          445,
          222,
          40,
          15
        ],
        "textcolor": [
          1.0,
          1.0,
          1.0,
          0.7
        ],
        "fontsize": 10.0,
        "id": "label_stop"
      },
      {
        "maxclass": "message",
        "text": "stop",
        "patching_rect": [
          440,
          250,
          50,
          20
        ],
        "numinlets": 2,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "msg_stop"
      },
      {
        "maxclass": "button",
        "patching_rect": [
          530,
          190,
          60,
          30
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          "bang"
        ],
        "id": "btn_resume"
      },
      {
        "maxclass": "comment",
        "text": "Resume",
        "patching_rect": [
          535,
          222,
          50,
          15
        ],
        "textcolor": [
          1.0,
          1.0,
          1.0,
          0.7
        ],
        "fontsize": 10.0,
        "id": "label_resume"
      },
      {
        "maxclass": "message",
        "text": "resume",
        "patching_rect": [
          530,
          250,
          60,
          20
        ],
        "numinlets": 2,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "msg_resume"
      },
      {
        "maxclass": "button",
        "patching_rect": [
          440,
          290,
          60,
          30
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          "bang"
        ],
        "id": "btn_next"
      },
      {
        "maxclass": "comment",
        "text": "Next",
        "patching_rect": [
          448,
          322,
          40,
          15
        ],
        "textcolor": [
          1.0,
          1.0,
          1.0,
          0.7
        ],
        "fontsize": 10.0,
        "id": "label_next"
      },
      {
        "maxclass": "message",
        "text": "next",
        "patching_rect": [
          440,
          350,
          50,
          20
        ],
        "numinlets": 2,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "msg_next"
      },
      {
        "maxclass": "button",
        "patching_rect": [
          530,
          290,
          60,
          30
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          "bang"
        ],
        "id": "btn_prev"
      },
      {
        "maxclass": "comment",
        "text": "Prev",
        "patching_rect": [
          543,
          322,
          40,
          15
        ],
        "textcolor": [
          1.0,
          1.0,
          1.0,
          0.7
        ],
        "fontsize": 10.0,
        "id": "label_prev"
      },
      {
        "maxclass": "message",
        "text": "prev",
        "patching_rect": [
          530,
          350,
          50,
          20
        ],
        "numinlets": 2,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "msg_prev"
      },
      {
        "maxclass": "button",
        "patching_rect": [
          620,
          290,
          80,
          30
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          "bang"
        ],
        "id": "btn_refresh"
      },
      {
        "maxclass": "comment",
        "text": "Refresh",
        "patching_rect": [
          628,
          322,
          50,
          15
        ],
        "textcolor": [
          1.0,
          1.0,
          1.0,
          0.7
        ],
        "fontsize": 10.0,
        "id": "label_refresh"
      },
      {
        "maxclass": "message",
        "text": "refresh",
        "patching_rect": [
          620,
          350,
          60,
          20
        ],
        "numinlets": 2,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "msg_refresh"
      },
      {
        "maxclass": "comment",
        "text": "SECTION CONTROL",
        "patching_rect": [
          350,
          400,
          120,
          20
        ],
        "textcolor": [
          0.5,
          0.5,
          0.5,
          1.0
        ],
        "fontsize": 11.0,
        "id": "comment_section_control"
      },
      {
        "maxclass": "button",
        "patching_rect": [
          350,
          430,
          50,
          24
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          "bang"
        ],
        "id": "btn_add_section"
      },
      {
        "maxclass": "message",
        "text": "addSection \"New Section\" 0 0",
        "patching_rect": [
          420,
          430,
          180,
          20
        ],
        "numinlets": 2,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "msg_add_section"
      },
      {
        "maxclass": "comment",
        "text": "NOW PLAYING:",
        "patching_rect": [
          30,
          320,
          100,
          20
        ],
        "textcolor": [
          1.0,
          0.42,
          0.62,
          1.0
        ],
        "fontsize": 14.0,
        "fontname": "Arial Bold",
        "id": "label_now_playing"
      },
      {
        "maxclass": "textedit",
        "patching_rect": [
          30,
          345,
          250,
          30
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "now_playing_display",
        "text": "SONG 4",
        "bgcolor": [
          0.1,
          0.1,
          0.1,
          1.0
        ],
        "textcolor": [
          1.0,
          0.42,
          0.62,
          1.0
        ],
        "fontsize": 16.0,
        "readonly": 1
      },
      {
        "maxclass": "comment",
        "text": "Status: Ready",
        "patching_rect": [
          30,
          390,
          150,
          20
        ],
        "textcolor": [
          0.5,
          0.5,
          0.5,
          1.0
        ],
        "fontsize": 11.0,
        "id": "status_display"
      },
      {
        "maxclass": "newobj",
        "text": "live.transport",
        "patching_rect": [
          350,
          60,
          120,
          22
        ],
        "numinlets": 1,
        "numoutlets": 1,
        "outlettype": [
          ""
        ],
        "id": "live_transport"
      }
    ],
    "lines": [
      {
        "patchline": {
          "source": [
            "btn_init",
            0
          ],
          "destination": [
            "msg_init",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "msg_init",
            0
          ],
          "destination": [
            "setlist_js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "btn_add_song",
            0
          ],
          "destination": [
            "msg_add_song",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "msg_add_song",
            0
          ],
          "destination": [
            "setlist_js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "num_song_id",
            0
          ],
          "destination": [
            "msg_remove",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "msg_remove",
            0
          ],
          "destination": [
            "setlist_js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "btn_clear",
            0
          ],
          "destination": [
            "msg_clear",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "msg_clear",
            0
          ],
          "destination": [
            "setlist_js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "btn_play",
            0
          ],
          "destination": [
            "msg_play",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "msg_play",
            0
          ],
          "destination": [
            "setlist_js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "btn_stop",
            0
          ],
          "destination": [
            "msg_stop",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "msg_stop",
            0
          ],
          "destination": [
            "setlist_js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "btn_resume",
            0
          ],
          "destination": [
            "msg_resume",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "msg_resume",
            0
          ],
          "destination": [
            "setlist_js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "btn_next",
            0
          ],
          "destination": [
            "msg_next",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "msg_next",
            0
          ],
          "destination": [
            "setlist_js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "btn_prev",
            0
          ],
          "destination": [
            "msg_prev",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "msg_prev",
            0
          ],
          "destination": [
            "setlist_js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "btn_refresh",
            0
          ],
          "destination": [
            "msg_refresh",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "msg_refresh",
            0
          ],
          "destination": [
            "setlist_js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "btn_add_section",
            0
          ],
          "destination": [
            "msg_add_section",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "msg_add_section",
            0
          ],
          "destination": [
            "setlist_js",
            0
          ]
        }
      }
    ]
  }
}