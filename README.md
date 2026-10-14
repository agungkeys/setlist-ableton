# Setlist Manager for Max for Live

Plugin setlist management powerful untuk Ableton Live, dibangun dengan Max for Live + JavaScript.

## Fitur

- **Playlist Management** - Tambah, hapus, reorder lagu dalam setlist
- **Playback Control** - Play, Stop, Resume, Next, Prev langsung dari plugin
- **Scene Navigation** - Auto jump ke scene sesuai lagu yang dipilih
- **Section Management** - Kelompokkan lagu jadi section (Opening, Break, Closing)
- **Now Playing Display** - Highlight lagu yang sedang dimainkan
- **JSON Persistence** - Simpan/muat setlist ke file JSON
- **Live API Integration** - Akses langsung ke transport, scenes, dan set Ableton

## Struktur Project

```
setlist-m4l/
├── src/
│   └── setlist.js          # Logic utama (JavaScript)
├── patchers/
│   └── patcher.json        # Max patcher structure
├── setlists/
│   └── default.json        # Contoh setlist
├── docs/
│   └── SETUP.md            # Panduan instalasi
└── README.md
```

## Instalasi di MacBook

### 1. Persiapan

- Install **Max 8** (dari Cycling '74)
- Install **Ableton Live 10/11/12**
- Pastikan **Max for Live** aktif di Ableton

### 2. Buat Max for Live Device

1. Buka **Max**
2. **File → New Patcher** (atau Cmd+N)
3. Simpan sebagai `.maxpat` di folder project

### 3. Import JavaScript

1. Di Max patcher, buat objek **`js`**
2. Klik kanan → **Open Script Editor**
3. Copy-paste seluruh isi `src/setlist.js` ke editor
4. Save

### 4. Import Patcher JSON

1. Di Max, buat objek **`patching`** atau buka **patcher.json**
2. Copy seluruh struktur JSON ke clipboard
3. Paste ke Max patcher (Cmd+V)
4. Atau rebuild manual mengikuti struktur di `patchers/patcher.json`

### 5. Load ke Ableton

1. Buka Ableton Live
2. Drag & drop file `.maxpat` ke track (Audio/MIDI)
3. Klik **Initialize** button di device
4. Plugin siap digunakan!

## Penggunaan

### Menambah Lagu
Klik tombol **Add Song** atau kirim pesan:
```
add "Judul Lagu" 0 "#4a90d9"
```

### Playback
- **Play** - Mainkan lagu yang dipilih + jump ke scene
- **Stop** - Hentikan transport
- **Resume** - Lanjutkan transport
- **Next** - Lagu berikutnya
- **Prev** - Lagu sebelumnya
- **Refresh** - Sync ulang dengan scene aktif di Ableton

### Section
```
addSection "Opening" 0 2
playSection <section_id>
```

### Simpan/Load
```
save /path/to/setlist.json
load /path/to/setlist.json
```

## Teknologi

- **Max 8** - Visual programming environment
- **JavaScript (Node)** - Logic dan Live API integration
- **Live API** - Akses ke transport, scenes, tracks
- **JSON** - Format penyimpanan setlist

## Referensi

- [Max for Live Documentation](https://docs.cycling74.com/max8/vignettes/core/live_api_overview)
- [LiveAPI Object](https://docs.cycling74.com/max8/vignettes/core/live_object_model)
- [JavaScript in Max](https://docs.cycling74.com/max8/vignettes/core/javascript_vignette)

## Lisensi

MIT License - Free to use and modify.
