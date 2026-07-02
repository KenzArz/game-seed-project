# Busa Fantasi 🛁

Game meracik bertema **imajinasi anak kecil di kamar mandi** — bapak-bapak burnout
kepleset di kamar mandi, "masuk" ke dunia fantasi gayung, lalu membantu **Pak
Guyon** (gayung hidup) meracik busa untuk tamu-tamu.

**Alur meracik:** seret bahan dari **rak** ke **ulekan** → tumbuk pakai alat ulek
(gerak naik-turun) sampai jadi **butir** → seret butir ke **gayung** → klik gayung
→ **mengaduk** (putar sendok) → sajikan → reaksi pelanggan.

> Engine: **Godot 4.6** (Forward+). Desain UI: **1920×1080**.
> Untuk detail teknis kode (class, signal, autoload), lihat [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 1. Cara menjalankan

1. Buka project di Godot 4.6.
2. Tekan **F5** → main menu → **Mulai** (game baru) atau **Lanjutkan** (dari save).
3. Untuk tes satu scene saja, buka `.tscn`-nya lalu **F6** (Run Current Scene) — mis.
   [level1.tscn](scenes/chapters/level1.tscn), [credits.tscn](scenes/chapters/credits.tscn),
   [ending.tscn](scenes/chapters/ending.tscn).

**Alur game penuh:** `Menu → Intro (sinematik) → Level1 (meracik semua pelanggan)
→ Ending (ACT 7-8) → Credits → balik Menu`.

---

## 2. Struktur folder penting

```
scenes/
├── chapters/
│   ├── intro.tscn        ← sinematik pembuka (AnimationPlayer)
│   ├── level1.tscn       ← scene utama gameplay (koordinator)
│   ├── ending.tscn       ← sinematik penutup (AnimationPlayer)
│   └── credits.tscn      ← credit auto-scroll (AnimationPlayer)
├── ui/
│   ├── placeholder_box.tscn   ← greybox dasar (bisa di-skin)
│   ├── draggable_item.tscn    ← kotak bisa di-drag (bahan & bubuk)
│   ├── customer_window.tscn   ← jendela customer (teknik sandwich)
│   ├── ulekan.tscn            ← mangkuk + alat ulek
│   ├── gayung_station.tscn    ← gayung di meja (teknik sandwich)
│   ├── panels/stir_panel.tscn ← minigame mengaduk (full-screen)
│   ├── main_menu/             ← menu utama
│   └── setting/               ← layar pengaturan (volume)
└── systems/audio_manager.tscn ← AudioManager (autoload BGM/SFX, isi slot di sini)

scripts/systems/          ← semua logika (.gd), termasuk autoload

resources/
├── customers/            ← 1 file = 1 pelanggan/level (CustomerData)
└── ingredients/          ← 1 file = 1 bahan (IngredientDef)

assets/
├── ... (gambar/aset mentah)
└── audio/                ← bgm/ (.ogg loop) & sfx/ (.wav)
default_bus_layout.tres   ← bus audio (Master/BGM/SFX/Voice)
```

---

## 3. 🗨️ Cara menambah karakter (pelanggan) baru

> **Sistem pelanggan TIDAK berubah** — masih data-driven lewat `.tres`. Yang berubah
> cuma cara pelanggan **ditampilkan** (sekarang di jendela, bukan portrait geser).
> Jadi bagian ini tetap sama seperti sebelumnya.

### Konsep singkat
- **1 file `.tres` di `resources/customers/` = 1 pelanggan.** Game memuat semua
  file di folder itu otomatis, **urut nomor depan** nama file (00, 01, 02, …).
- Tiap pelanggan punya **resep target** (id bahan). Saat disajikan, game menghitung
  berapa bahan yang benar lalu memilih **reaksi dialog** (pas/sebagian/salah).
  **Tidak ada skor** — cuma dialognya yang beda.
- Dialog dirender addon **Dialogic**.

### Field penting (di tiap file pelanggan)
| Field | Guna |
|---|---|
| **Display Name** | nama karakter |
| **Available Ingredients** | bahan yang muncul di rak saat pelanggan ini (unlock cerita). Kosong = semua bahan |
| **Recipe** | bahan ideal (id) — penentu pas/sebagian/salah. **Tak ditampilkan** |
| **Result Perfect/Partial/Wrong** | nama busa hasil per tingkat |
| **Intro Lines** | dialog SEBELUM meracik — beri petunjuk yang dia mau |
| **React Perfect/Partial/Wrong** | reaksi setelah disajikan, dipilih by jumlah bahan benar |
| **Npc Color / Npc Texture** | warna/gambar customer di jendela |

> **Id bahan** (huruf kecil, sama persis dgn di `resources/ingredients/`):
> `sabun`, `shampo`, `pasta`, `bedak`, `mint`, `garam`.

### Langkah cepat
1. FileSystem → `resources/customers/` → klik kanan file yang ada → **Duplicate** →
   namai `06_nama.tres` (nomor = urutan tampil).
2. Isi field di Inspector (Recipe, Intro Lines, React, dll).
3. Gambar wajah: drag PNG ke `assets/`, lalu isi field **Npc Texture**.
4. **Ctrl+S** lalu Run.

> ⚠️ **JANGAN pakai pola `Nama: teks` di dialog** (mis. `Pak Guyon: halo`) — Dialogic
> menganggap `Nama:` sebagai karakter tak terdefinisi dan **crash**. Kalau perlu
> menandai pembicara, pakai kurung: `(Pak Guyon berbisik) ...`.

### (Opsional) Clue warna emas
Warnai kata kunci di Intro Lines pakai BBCode: `[color=#C9A84C]bahan[/color]`.
Peta sifat → bahan biar konsisten: tebal/banyak busa → `sabun`; banyak gelembung →
`shampo`; dingin tajam → `pasta`; lembut → `bedak`; segar/mint → `mint`;
bersih/membersihkan → `garam`.

---

## 4. 🎨 Cara ganti aset / texture (per node)

Aturan umum:
- Node **`TextureRect`** / **`Sprite2D`** → art statis: pilih node → Inspector →
  **Texture** → drop PNG. Langsung kelihatan di editor.
- Node **`PlaceholderBox`** (greybox) → isi field **Texture** → greybox jadi gambar;
  kosong → tetap kotak warna. Node tetap bisa digeser/di-resize di editor.

> **Prinsip penting:** ukuran & posisi node = tempat gambar itu muncul. Geser/resize
> node di editor untuk mengatur layout — **jangan** ubah lewat script.

### a) Bahan di rak — [level1.tscn](scenes/chapters/level1.tscn)
Rak = node **`RakBahan`** (TextureRect) → isi Texture-nya dengan gambar rak.
Tiap bahan = node **`Sabun` / `Shampo` / `Pasta` / `Bedak` / `Mint` / `Garam`**
(draggable) → isi Texture masing-masing. Geser posisinya di atas rak sesuai selera.
> Tiap node bahan punya field **`id`** (mis. "sabun") — **jangan diubah**, itu yang
> dicocokkan ke resep.

### b) Ulekan — [ulekan.tscn](scenes/ui/ulekan.tscn) (teknik sandwich)
| Node | Isi | Catatan |
|---|---|---|
| **Mangkuk** | gambar mangkuk ulekan (belakang) | area "boleh menumbuk" = rect node ini |
| **UlekanIsi1/2/3** | (opsional) gambar bahan di dalam | 3 slot; texture-nya diisi otomatis dari bahan yang di-drop |
| **MangkukDepan** | bibir depan mangkuk | digambar menutupi bawah bahan → efek "di dalam" |
| **Alat** | gambar alat ulek (pestle) | yang di-grab & digerakkan naik-turun |

### c) Gayung di meja — [gayung_station.tscn](scenes/ui/gayung_station.tscn) (sandwich)
| Node | Isi |
|---|---|
| **GayungBelakang** | gambar gayung penuh (belakang) |
| **GayungIsi** | gambar bubuk di dalam gayung |
| **GayungDepan** | bagian depan gayung (kacanya transparan biar bubuk kelihatan) |

### d) Jendela customer — [customer_window.tscn](scenes/ui/customer_window.tscn) (sandwich 3 layer)
Urutan belakang → depan:
1. **WindowBack** → pemandangan/kaca yang terlihat lewat jendela.
2. **CustomerSprite** → **JANGAN diisi** texture di sini; otomatis dari `Npc Texture`
   di `.tres` pelanggan saat runtime.
3. **WindowFrame** → (opsional) bingkai kaca dengan **tengah transparan**, biar
   customer terlihat *di balik* jendela (kepotong di kusen).
> Karakter otomatis di-**crop** ke jendela (cuma badan+muka yang tampil). Atur
> seberapa banyak yang tampil dengan mengubah **tinggi node `CustomerWindow`**.

### e) Layar mengaduk — [stir_panel.tscn](scenes/ui/panels/stir_panel.tscn) (layer full-screen)
Semua layer 1920×1080 yang saling menumpuk:
| Node | Isi |
|---|---|
| **Meja** | latar meja |
| **Gayung** | panci/wadah aduk |
| **Air** | air/ramuan di dalam wadah (selalu tampil saat mengaduk) |
| **Busa1 / Busa2 / Busa3** | 3 tingkat busa (muncul bertahap saat diaduk) |
| **Spoon** | sendok pengaduk |
> Node **`Vessel`** = penanda **geometri putaran sendok** (transparan, bukan gambar).
> Geser/resize supaya pusatnya pas di tengah cangkir panci.

### f) Aset lain
- **Background meja racik:** [level1.tscn](scenes/chapters/level1.tscn) → node **Background**.
- **Pak Guyon (pop-up saat ngomong):** [level1.tscn](scenes/chapters/level1.tscn) → node **PakGuyon**.
- **Gambar bahan (ikon default):** `resources/ingredients/*.tres` → field **Texture**.
- **Intro & Ending:** node greybox di [intro.tscn](scenes/chapters/intro.tscn) /
  [ending.tscn](scenes/chapters/ending.tscn) → isi Texture masing-masing.

---

## 5. 🧪 Cara ubah daftar / sifat bahan
- **Ganti nama/warna/ikon bahan:** edit `.tres` di `resources/ingredients/`.
- **Tambah bahan baru:** duplicate `.tres`, ubah `id` & `display_name`. Lalu tambah
  **node draggable baru** di [level1.tscn](scenes/chapters/level1.tscn) (duplicate
  node bahan yang ada, set `id`-nya, masukkan ke grup **`bahan`**), dan tambah slot
  isi di ulekan kalau perlu.
- **Maks bahan per ramuan** = jumlah slot ulekan (`UlekanIsi1/2/3` = 3).

---

## 6. ⚙️ Pengaturan & Save/Load

### Pengaturan (volume)
Layar [pengaturan](scenes/ui/setting/pengaturan.tscn) mengatur volume **Master /
BGM / SFX / Voice**. Nilai **persisten** di `user://settings.cfg` dan diterapkan ke
AudioServer otomatis saat start. Bus audio didefinisikan di
[default_bus_layout.tres](default_bus_layout.tres).
> **UX Simpan/Batal:** geser slider = **preview live** (langsung kedengeran, belum
> disimpan). **Simpan** = tulis ke disk + feedback + tutup ke menu. **Kembali** =
> batal (balik ke nilai terakhir tersimpan) + tutup.
> Bus **Master** mengontrol semua; **Musik**→BGM, **Efek Suara**→SFX otomatis lewat
> AudioManager. Bus **Dialog/Voice** baru kepakai kalau audio dialog di-route ke
> bus "Voice".

### 🔊 Cara masukin audio (BGM & SFX) — step by step
Sistem audio (**`AudioManager`**, autoload) sudah jadi. Kamu tinggal **isi slot**,
**tanpa ubah kode**. Ini berlaku untuk semua placeholder BGM/SFX:

1. **Taruh file** di `assets/audio/` (drag ke FileSystem Godot supaya ter-import):
   BGM → `.ogg` (disarankan), SFX → `.wav`.
2. **BGM harus loop:** klik file `.ogg` → tab **Import** (kanan atas) → centang
   **Loop** → **Reimport**.
3. **Colok ke slot:** buka [audio_manager.tscn](scenes/systems/audio_manager.tscn)
   → pilih node **AudioManager** → Inspector → **drag file ke slot yang sesuai**:

   | Grup | Slot | Bunyi saat |
   |---|---|---|
   | BGM | **Bgm Menu** | main menu |
   | BGM | **Bgm Intro** | scene intro |
   | BGM | **Bgm Gameplay** | gameplay (level1) |
   | BGM | **Bgm Ending** | ending → credits |
   | SFX | **Sfx Button** | klik tombol menu (Mulai/Lanjutkan/Pengaturan/Kredit/Keluar) |
   | SFX | **Sfx Drag Bahan** | ambil/seret bahan & bubuk |
   | SFX | **Sfx Tumbuk** | tiap gerakan menumbuk di ulekan |
   | SFX | **Sfx Bubuk Jadi** | bubuk selesai |
   | SFX | **Sfx Klik Gayung** | klik gayung (masuk mengaduk) |
   | SFX | **Sfx Aduk** | tiap putaran mengaduk |
   | SFX | **Sfx Sajikan** | menyajikan ramuan |
   | SFX | **Sfx Transisi** | tiap pindah scene |

4. **Ctrl+S & Run.** Selesai. Volume ngikut kenop di **Pengaturan** (bus BGM/SFX).
   Slot yang dibiarkan kosong = tidak bunyi (aman, tidak error).

> Mau nambah SFX di event lain? Panggil `AudioManager.play_sfx("nama")` di kode
> event-nya, lalu tambahkan slot `@export` + entri di `_sfx_map`
> ([audio_manager.gd](scripts/systems/audio_manager.gd)).

### Save/Load (progres)
Progres tersimpan di `user://busa_save.json` (SaveManager): sudah lihat intro,
indeks pelanggan aktif, tutorial selesai. **Mulai** = reset save + intro;
**Lanjutkan** = lanjut dari pelanggan terakhir. Auto-save tiap pelanggan selesai.

---

## 7. ⚙️ Angka yang gampang di-tuning (di kode)

| Mau ubah | File | Bagian |
|---|---|---|
| Durasi transisi | [level1.gd](scripts/systems/level1.gd) | `const DUR := 0.35` |
| Tumbukan per bahan sampai halus | [ulekan.gd](scripts/systems/ulekan.gd) | `const GERAK_TARGET := 5` |
| Seberapa kecil bahan saat halus | [ulekan.gd](scripts/systems/ulekan.gd) | `const SKALA_HALUS := 0.35` |
| Toleransi ayunan alat ulek | [ulekan.gd](scripts/systems/ulekan.gd) | `const MARGIN_Y := 200.0` |
| Putaran aduk sampai "rata" | [stir_panel.gd](scripts/systems/stir_panel.gd) | `const MAX_STIR := 5` |
| Ambang kemunculan busa | [stir_panel.gd](scripts/systems/stir_panel.gd) | `_perbarui_busa` (0.15/0.45/0.75) |
| Kecepatan scroll credits | [credits.tscn](scenes/chapters/credits.tscn) | klip AnimationPlayer "scroll" |
| Timing sinematik intro/ending | intro.tscn / ending.tscn | klip AnimationPlayer |

---

## 8. ⚠️ Tips & jebakan

- **Sinematik pakai AnimationPlayer**, bukan tween di kode. Untuk edit timing intro/
  ending/credits, buka scene-nya → node **AnimationPlayer** → geser keyframe.
  ⚠️ **Call Method track tidak jalan saat preview editor** (cuma runtime) — itu
  normal (dipakai buat trigger dialog/pindah scene, bukan visual).
- **Jangan pakai pola `Nama: teks` di dialog Dialogic** (crash). Pakai `(Nama ...)`.
- **Jangan klik ikon "mata" (visibility)** node lalu simpan tak sengaja — men-set
  `visible=false`. Node yang dikendalikan script sudah dipaksa `visible=true` saat
  runtime, tapi tetap hati-hati.
- **Warning `invalid UID ... using text path instead`** saat run = dari addon
  Dialogic, **tidak berbahaya**, abaikan.
- `.gd.uid`, `.tscn`, `.tres` — **ikut commit ke git**, jangan dihapus manual.
- Panel debug kiri-bawah (node **DebugCanvas** di level1) cuma alat dev.

---

## 9. Status
Loop game **utuh dari menu sampai tamat** (menu → intro → gameplay → ending →
credits). Sistem inti lengkap: SceneManager, GameState, Save/Load, Settings, **audio
(AudioManager: BGM+SFX, tinggal isi file)**, tutorial hint, ending+credits. Sebagian
besar visual masih **greybox** dan slot audio masih kosong sampai aset final dipasang.
**Cursor custom** (4 state) belum dibuat (menunggu aset).
