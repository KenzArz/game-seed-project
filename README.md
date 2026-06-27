# Busa Fantasi 🛁

Game meracik bertema **imajinasi anak kecil di kamar mandi** — pemain mencampur
bahan-bahan kamar mandi (sabun, shampoo, dll) jadi "ramuan ajaib" untuk
pelanggan. Tata letak & alur UI terinspirasi *Coffee Talk*: dialog visual-novel
→ meja racik (split) → sajikan → minigame mengaduk.

> Engine: **Godot 4.6** (Forward+). Desain UI: **1920×1080**.
> Untuk detail teknis kode, lihat [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 1. Cara menjalankan

1. Buka project di Godot 4.6.
2. Tekan **F5** (jalankan main scene) → main menu → klik **Mulai**.
   - Atau buka [scenes/chapters/level1.tscn](scenes/chapters/level1.tscn) lalu **F6**
     untuk langsung ke gameplay-nya.

**Alur main:** dialog (klik untuk lanjut) → pilih ≤3 bahan lalu **RACIK** →
**BUANG / ADUK / SAJIKAN** → kalau ADUK: putar sendok melingkar di gayung lalu
**SAJIKAN** → pelanggan berikutnya.

---

## 2. Struktur folder penting

```
scenes/
├── chapters/level1.tscn          ← scene utama gameplay (koordinator)
├── ui/placeholder_box.tscn       ← greybox dasar
├── ui/panels/                    ← tiap fase: dialogue, mixing, serve, stir, customer_portrait
└── ui/main_menu/                 ← menu utama

scripts/systems/                  ← semua logika (.gd)

resources/
├── customers/                    ← 1 file = 1 pelanggan/level   (CustomerData)
└── ingredients/                  ← 1 file = 1 bahan             (IngredientDef)

assets/                           ← gambar/aset mentah
```

---

## 3. 🗨️ Cara menambah karakter (pelanggan) baru

### Konsep singkat (baca ini dulu)
- **1 file `.tres` di `resources/customers/` = 1 pelanggan.** Game memuat semua
  file di folder itu otomatis, **urut dari nomor depan** nama file (01, 02, …).
  Tidak perlu edit kode atau array apa pun.
- Tiap pelanggan punya **resep target** (max 3 bahan). Saat player menyajikan,
  game menghitung **berapa bahan yang benar**, lalu memilih:
  - **nama busa** yang tampil di layar HASIL RACIKAN, dan
  - **reaksi dialog** pelanggan.
- **Tidak ada skor/bintang.** Cuma 3 tingkat: **pas / sebagian / salah**.
- Dialog dirender oleh addon **Dialogic**.

### Tabel field (yang diisi di tiap file pelanggan)
| Field | Guna |
|---|---|
| **Display Name** | nama karakter (mis. "Kakek Ombak") |
| **Recipe** | bahan ideal (id), max 3 — penentu pas/sebagian/salah. **Tak ditampilkan ke player** |
| **Result Perfect** | nama busa kalau **semua** bahan benar (mis. "Cloud Foam") |
| **Result Partial** | nama busa kalau **sebagian** benar (default "Busa Setengah Jadi") |
| **Result Wrong** | nama busa kalau **salah** semua (default "Busa Gagal") |
| **Intro Lines** | dialog SEBELUM meracik — **beri petunjuk** apa yang dia mau |
| **React Perfect** | reaksi kalau semua bahan benar |
| **React Partial** | reaksi kalau sebagian benar (kasih hint) |
| **React Wrong** | reaksi kalau salah semua (tetap ramah) |
| **Npc Color** | warna kotak portrait (kalau belum ada gambar) |
| **Npc Texture** | gambar wajah karakter (opsional) |
| **Background Color/Texture** | latar khusus karakter ini (opsional) |

> **Id bahan** (huruf kecil, harus sama persis dgn id di `resources/ingredients/`):
> `sabun`, `shampo`, `pasta`, `bedak`, `mint`, `garam`.

---

### Contoh lengkap — bikin "Kakek Ombak" dari nol

**Langkah 1 — Buat file.** FileSystem → `resources/customers/` → klik kanan
[01_bocah_lumpur.tres](resources/customers/01_bocah_lumpur.tres) → **Duplicate** →
namai **`06_kakek_ombak.tres`** (nomor 06 = tampil paling akhir).

**Langkah 2 — Tentukan resep.** Misal dia mau ramuan **segar & bersih** →
resepnya `sabun` + `garam` + `mint`. (Player tidak lihat ini; mereka menebak dari
petunjuk di intro.)

**Langkah 3 — Isi semua field.** Cara tercepat: dobel-klik file → klik kanan di
panel atas → **View as Text** (atau buka di editor teks), lalu tempel:
```gdscript
display_name = "Kakek Ombak"
npc_color = Color(0.3, 0.5, 0.6, 1)
recipe = PackedStringArray("sabun", "garam", "mint")
result_perfect = "Ocean Breeze"
result_partial = "Busa Asin"
result_wrong = "Air Keruh"
intro_lines = PackedStringArray("Oho, aku Kakek Ombak, perindu laut tujuh samudra.", "Buatkan busa yang segar menyengat dan kuat membersihkan seperti deburan ombak.")
react_perfect = PackedStringArray("Aah! Segar dan bersih sempurna! Seperti pulang ke laut!", "Terima kasih, peracik cilik.")
react_partial = PackedStringArray("Hmm, ada segarnya... tapi kurang bersih.", "Coba tambah garam mandinya ya.")
react_wrong = PackedStringArray("Ini... sama sekali bukan aroma laut yang kurindukan.")
```
> Tiap kalimat dipisah `", "`. **Jangan pakai kutip dua (`"`) di dalam kalimat** —
> pakai kutip satu (`'`) kalau perlu. (Kalau diisi lewat Inspector: klik **＋** di
> tiap array untuk menambah baris.)

**Langkah 4 — Ganti gambar wajah (opsional).** Drag PNG ke FileSystem (mis.
`assets/sprites/`) → di `.tres` → Inspector grup **Portrait** → field
**Npc Texture** → drag PNG ke situ.

**Langkah 5 — Simpan (Ctrl+S) lalu Run.** Karakter muncul di urutan ke-6.

---

### ✨ (Opsional) Clue warna emas di intro
Mau kasih petunjuk bahan dengan **mewarnai kata kunci jadi emas**? Teks dialog
Dialogic mendukung **BBCode**, jadi tinggal bungkus kata clue-nya di Intro Lines:
```gdscript
intro_lines = PackedStringArray("Aku mau [color=#FFD700]busa tebal[/color] yang [color=#FFD700]banyak gelembungnya[/color], dan yang [color=#FFD700]seger[/color]!")
```
- `[color=#FFD700]kata[/color]` → kata jadi **emas**. Ganti hex untuk warna lain.
- Tebalkan: `[b][color=#FFD700]kata[/color][/b]`.
- **Warnai kata kunci sifat bahannya saja**, bukan seluruh kalimat.
- Tidak perlu ubah kode — Dialogic merender BBCode otomatis.

**Peta sifat → bahan** (biar clue konsisten):
| Kata clue (warnai emas) | Mengarah ke bahan |
|---|---|
| tebal / banyak busa | `sabun` |
| banyak gelembung | `shampo` |
| dingin tajam | `pasta` |
| lembut / calming | `bedak` |
| segar / mint | `mint` |
| bersih / membersihkan | `garam` |

**Contoh nyata** — Bocah Lumpur (resep `sabun`+`shampo`+`mint`): 3 kata emas =
3 bahan resepnya → *"busa tebal"* (sabun) + *"banyak gelembungnya"* (shampo) +
*"seger"* (mint). Player belajar memetakan kata emas ke bahan.

> ⚠️ BBCode pakai kurung siku `[ ]` — aman, tidak bentrok dgn tanda kutip `.tres`.
> Tapi tetap **jangan pakai kutip dua (`"`) di dalam kalimat**.

---

### Cara kerja saat dimainkan (Kakek Ombak, resep `sabun+garam+mint`)
| Yang diracik player | Tingkat | Nama di HASIL RACIKAN | Reaksi (saat SAJIKAN) |
|---|---|---|---|
| `sabun`+`garam`+`mint` | **Pas** | "Ocean Breeze" | React Perfect |
| cuma `mint` (atau mint+shampo) | **Sebagian** | "Busa Asin" | React Partial |
| `shampo`+`pasta`+`bedak` | **Salah** | "Air Keruh" | React Wrong |

Aturan tingkat: **semua bahan resep benar & tanpa bahan lain** = pas · **≥1 benar**
= sebagian · **0 benar** = salah. (Kalau salah, player bisa **BUANG** dan ulang —
cozy, tanpa hukuman.)

### (Opsional) Intro pakai editor Dialogic
Mau nama speaker / portrait Dialogic / pilihan-cabang di **intro**? Buka tab
**Dialogic** → buat **Timeline** → di `.tres` isi field **Intro Timeline**. Kalau
di-set, ia menggantikan Intro Lines.

> **Urutan pelanggan** = urutan nomor file. Sisip di tengah? Beri nomor sesuai
> (mis. `02b_…`). Override manual: isi array **Customers** di node `Level1`; kalau
> dikosongkan, folder dibaca otomatis.
> **Catatan:** kalau habis menambah/menghapus file dari luar Godot, lakukan
> **Project → Reload Current Project** supaya editor menyegarkan daftarnya.

---

## 4. 🎨 Cara ganti aset / texture

Semua greybox bisa diganti gambar. Aturan umum: **isi field Texture → greybox
jadi gambar; kosong → tetap kotak warna.** Letakkan file gambar di `assets/`
dulu (drag ke FileSystem Godot supaya ter-import).

### a) Gambar bahan (Sabun, Shampoo, dll)
Buka file di `resources/ingredients/`, isi field **Texture**:
| File | Bahan |
|---|---|
| [01_sabun_batang.tres](resources/ingredients/01_sabun_batang.tres) | Sabun Batang |
| [02_shampoo.tres](resources/ingredients/02_shampoo.tres) | Shampoo |
| [03_pasta_gigi.tres](resources/ingredients/03_pasta_gigi.tres) | Pasta Gigi |
| [04_bedak_bayi.tres](resources/ingredients/04_bedak_bayi.tres) | Bedak Bayi |
| [05_daun_mint.tres](resources/ingredients/05_daun_mint.tres) | Daun Mint |
| [06_garam_mandi.tres](resources/ingredients/06_garam_mandi.tres) | Garam Mandi |

### b) Wajah pelanggan & background per pelanggan
Di file `resources/customers/*.tres` → field **Npc Texture** dan
**Background Texture**.

### c) Background default (semua pelanggan)
[level1.tscn](scenes/chapters/level1.tscn) → node **Background** → field **Texture**.

### d) Greybox di dalam panel — buka scene panel-nya, pilih node kotaknya
Panel sekarang **dibuat di editor**, jadi tekstur diisi **langsung di node kotaknya**
(bukan lewat export panel). Buka file scene-nya (dobel-klik) → pilih node di panel
Scene → Inspector → field **Texture** → drag gambar.
| Buka scene | Pilih node | Mengganti |
|---|---|---|
| [serve_panel.tscn](scenes/ui/panels/serve_panel.tscn) | **Frame** | latar panel "HASIL RACIKAN" |
| [mixing_panel.tscn](scenes/ui/panels/mixing_panel.tscn) | **Frame** | latar meja racik |
| [stir_panel.tscn](scenes/ui/panels/stir_panel.tscn) | **Backdrop** | latar layar mengaduk |
| [stir_panel.tscn](scenes/ui/panels/stir_panel.tscn) | **Vessel** | **gayung** (wadah aduk) |
| [stir_panel.tscn](scenes/ui/panels/stir_panel.tscn) | **Spoon** | **sendok** |

> **Kotak yang isinya berubah saat main** (kotak hasil, slot WADAH, rak bahan,
> wajah pelanggan) gambarnya datang dari **data**, jadi diatur lewat resource-nya,
> bukan di node: bahan → `resources/ingredients/*.tres` (poin a), wajah pelanggan
> → `resources/customers/*.tres` (poin b).

> Catatan: begitu sebuah greybox diberi Texture, label teks di dalamnya
> tersembunyi (diganti gambar). Itu memang perilaku yang diinginkan.

---

## 5. 🧪 Cara mengubah daftar / sifat bahan

- **Ganti nama/warna/gambar bahan:** edit `.tres` di `resources/ingredients/`.
- **Tambah bahan baru:** duplicate salah satu `.tres`, ubah `id` &
  `display_name`, lalu daftarkan: buka [level1.tscn](scenes/chapters/level1.tscn)
  → node **MixingPanel** → array **Ingredients** → masukkan file baru.
  (Kalau array dikosongkan, default 6 bahan dimuat dari kode.)
- Jumlah slot maksimum = `MAX_SLOTS` (3) di
  [mixing_panel.gd](scripts/systems/mixing_panel.gd).

---

## 6. ⚙️ Pengaturan cepat lain (di kode)

| Mau ubah | File | Bagian |
|---|---|---|
| Durasi transisi geser | [level1.gd](scripts/systems/level1.gd) | `const DUR := 0.35` |
| Jumlah putaran aduk sampai "rata" | [stir_panel.gd](scripts/systems/stir_panel.gd) | `const MAX_STIR := 5` |
| Maks bahan per ramuan | [mixing_panel.gd](scripts/systems/mixing_panel.gd) | `const MAX_SLOTS := 3` |
| Posisi/ukuran gayung di layar aduk | [stir_panel.gd](scripts/systems/stir_panel.gd) | `VESSEL_CENTER`, `VESSEL_RADIUS` |

---

## 7. ⚠️ Tips & jebakan

- **Jangan klik ikon "mata" (visibility) di Scene tree** lalu menyimpan tanpa
  sengaja — itu men-set `visible=false` pada node dan ikut tersimpan. (Pernah
  terjadi pada `StirCanvas` → layar mengaduk jadi tak muncul.)
- **Warning `invalid UID ... using text path instead` saat run itu dari addon
  Dialogic** (versi alpha), **tidak berbahaya** — abaikan saja.
- `.gd.uid`, `.tscn`, `.tres` — **ikut commit ke git**, jangan dihapus manual.
- Tiap panel bisa dites sendiri: buka `.tscn`-nya di `scenes/ui/panels/` lalu
  **F6**.
- Panel debug kiri-bawah (PHASE, INGREDIENTS, STIR, dll) hanya alat bantu dev;
  hapus node **DebugCanvas** di [level1.tscn](scenes/chapters/level1.tscn) kalau
  sudah tak perlu.

---

## 8. Status & yang belum ada

Ini masih **prototype greybox**. Dialog **sudah pakai addon Dialogic**. Belum
ada: sistem skor/penilaian ramuan, reaksi pelanggan, audio, save system. Sebagian
besar visual masih kotak warna sampai aset gambar dipasang lewat langkah di
Bagian 4.
