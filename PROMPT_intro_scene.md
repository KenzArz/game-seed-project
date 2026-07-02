# Prompt: Busa Fantasi — Intro/Prologue Scene + Save System (Greybox)

> Tempel semuanya di bawah garis ini ke AI coding agent (Claude Code / Cursor) yang jalan DI DALAM project Godot ini.
> Membangun **satu scene intro sinematik** (`scenes/chapters/intro.tscn`) yang tayang SEBELUM gameplay, lalu pindah ke `level1.tscn`. Plus **sistem save/continue** sederhana. Semua pakai **placeholder box** (greybox) yang bisa direskin belakangan.

---

## KONTEKS PROJECT (jangan diubah asumsinya)

Project **Godot 4.6** (`gameseed-project`), cozy crafting game **Busa Fantasi**: bapak-bapak burnout kepleset di kamar mandi, "masuk" ke dunia fantasi gayung, membantu Pak Guyon (gayung hidup) meracik busa untuk tamu-tamu.

Fakta yang HARUS dipatuhi (sudah ada di project, jangan dirusak):
- Engine **Godot 4.6**, resolusi desain **1920×1080**, stretch `canvas_items`, aspect `keep`. Bangun UI di koordinat 1920×1080.
- **Dialog pakai addon Dialogic** (sudah autoload). Cara start dialog runtime:
  ```gdscript
  var tl := DialogicTimeline.new()
  tl.from_text("\n".join(baris))   # tiap baris = 1 text event
  Dialogic.start(tl)
  # selesai -> sinyal Dialogic.timeline_ended
  ```
- ⚠️ **KRITIS — JANGAN pakai pola `Nama: teks` di awal baris dialog.** Dialogic `from_text` menganggap `Nama:` sebagai **karakter** (yang tak terdefinisi) → **segfault/crash**. Kalau perlu menandai pembicara, pakai kurung: `(Pak Guyon berbisik) ...` — BUKAN `Pak Guyon: ...`.
- **Greybox:** semua visual pakai scene reusable **`scenes/ui/placeholder_box.tscn`** (`class_name PlaceholderBox`). Isi export `display_name`, `box_color`, dan `texture` (kalau `texture` diisi → gambar; kosong → kotak warna + label). Reskin nanti = drop texture, tanpa ubah kode.
- **Panel dibuat di EDITOR** (layout = node di `.tscn`, script = logika saja). Ikuti pola ini untuk intro juga.
- Coordinator gameplay: **`scenes/chapters/level1.tscn`** + **`scripts/systems/level1.gd`** (state machine antrean pelanggan). Data pelanggan = `CustomerData` `.tres` di `resources/customers/` (di-load otomatis, urut nama file: `00_prologue`, `01_...`, dst).
- **Main menu:** `scenes/ui/main_menu/main_menu.tscn` + `.gd`. Tombol `mulai` SEKARANG memanggil `_on_mulai_pressed()` → `change_scene_to_file("res://scenes/chapters/level1.tscn")`. Ada juga tombol `pengaturan`, `kredit` (belum diwire), `keluar`.
- Protagonis **TIDAK PERNAH bicara** (nol dialog). Pak Guyon PLAYFUL (bukan bijak-berat). Tone: bikin pemain **senyum**, bukan nangis.

---

## STATUS PROJECT — peta ke kartu Project Manager (JANGAN bangun ulang yang sudah ada)

| Kartu PM (To Do) | Status | Catatan penting untuk agent |
|---|---|---|
| Godot Setup + **SceneManager / GameStateMachine** | ⚠️ Sebagian | Project/folder/git ✓. **Belum ada SceneManager/GameStateMachine global** — sekarang `change_scene_to_file` + state machine lokal `enum Phase` di `level1.gd`. Intro ini boleh pakai `change_scene` langsung. |
| Input Manager + **Cursor 4-state** | ❌ Belum | Kartu terpisah. Jangan dikerjakan di sini. |
| **Save/Load + Phase Progression** | ❌ Belum | = **Bagian B** prompt ini. |
| **Nostalgia scene** | ❌ Belum | = **Bagian A** prompt ini (scene intro). |
| **Customer Spawn + Garam Unlock** | ✅ **SUDAH JADI** | Antrean pelanggan (`00_prologue` + `01..05` di `resources/customers/`), fade in/out, portrait glide = ADA di `level1.gd`. **Unlock bahan per pelanggan** lewat `CustomerData.available_ingredients` + `MixingPanel.set_available()` = ADA (Garam tersedia saat Monster/C4). **JANGAN tulis ulang.** (Kurang cuma animasi *pulse* saat unlock — abaikan/opsional.) |
| Integration Art + Audio | ⏳ Jalan | Kartu terpisah. |
| Credits + Title | ⚠️ Sebagian | Menu ada; sebagian (Mulai/Lanjutkan) dicakup Bagian C. Credits-scroll & easter-egg = kartu terpisah. |

**FOKUS prompt ini:** Bagian A (Nostalgia/Intro) + Bagian B (Save/Load) + Bagian C (wiring menu). Sistem **pelanggan & unlock bahan SUDAH ADA — hanya integrasikan (baca `customer_index`), jangan bangun ulang.**

---

## BAGIAN A — NOSTALGIA / INTRO SCENE (`scenes/chapters/intro.tscn`)
> (= kartu PM "Nostalgia scene": scene masuk kamar mandi → kepleset → masuk dunia fantasi)

### Tujuan
Scene sinematik pembuka: **ACT 0 (dunia nyata) → kepleset → ACT 1 (awakening Pak Guyon + dialog)** → otomatis `change_scene_to_file` ke `level1.tscn`. Dijalankan pakai **greybox** (kotak berlabel), swappable ke art nanti.

### Struktur (ikuti pola editor-built)
- Buat **`scenes/chapters/intro.tscn`** (root `Control`, full-rect 1920×1080) + script **`scripts/systems/intro.gd`**.
- Semua elemen visual = **node `PlaceholderBox` instanced di editor** (bukan digenerate kode), diberi `display_name` deskriptif:
  - `BgRealBathroom` (latar kamar mandi nyata, full-rect, gelap)
  - `Gayung` (kotak kecil = gayung kuning tua)
  - `Protagonist` (kotak = bapak-bapak, SILENT — tidak pernah ada dialog)
  - `NostalgiaFlash` (kotak flash siluet anak, alpha 0 default)
  - `BgFantasy` (latar dunia fantasi, alpha 0 default — muncul saat transisi)
  - `PakGuyon` (kotak = gayung hidup, muncul di ACT 1)
  - `FadeOverlay` (ColorRect hitam full-rect untuk fade/whoosh, alpha 0)
- Script `intro.gd` = **state machine sinematik** yang menjalankan urutan beat pakai `Tween`/`await` (dan `AnimationPlayer` boleh untuk gerak halus). Script hanya logika; posisi/warna node diatur di editor.

### Urutan beat (dari NARRATIVE_BIBLE, ACT 0 + ACT 1)
Buat enum fase, mis. `enum Beat { DARK, ENTER, SEE_GAYUNG, FLASH, SLIP, WHOOSH, AWAKEN, DIALOGUE, TO_LEVEL1 }`.

1. **DARK** (~0.5s): layar hitam (FadeOverlay alpha 1). SFX langkah (placeholder, boleh dilewati kalau belum ada audio).
2. **ENTER**: fade in ke kamar mandi nyata (gelap/kusam). Protagonis "masuk" (geser pelan). Tidak ada dialog.
3. **SEE_GAYUNG**: kamera/fokus ke gayung di lantai. Protagonis berhenti.
4. **FLASH** (~0.3s): `NostalgiaFlash` kedip cepat (alpha 0→1→0) — siluet anak pegang gayung. Cepat & subtle.
5. **SLIP**: efek kepleset — goyang layar / protagonis jatuh (tween posisi+rotasi cepat), gayung "tersambar".
6. **WHOOSH**: FadeOverlay flash putih/gelap cepat (fade to white/black ~0.4s) sebagai transisi.
7. **AWAKEN**: fade in ke `BgFantasy` (hangat). `PakGuyon` muncul (fade/scale), "membuka mata".
8. **DIALOGUE**: mulai dialog Pak Guyon lewat **Dialogic** (teks di bawah). Protagonis diam.
9. **TO_LEVEL1**: saat `Dialogic.timeline_ended` → tandai `sudah_lihat_intro` (save, lihat Bagian B) → `get_tree().change_scene_to_file("res://scenes/chapters/level1.tscn")`.

> Timing longgar (tune sampai "kerasa"). Pakai `Tween` `EASE_OUT`/`TRANS_CUBIC`, transisi ~0.3–0.5s.

### Dialog ACT 1 (feed ke Dialogic via `from_text`)
Simpan sebagai `PackedStringArray` di `intro.gd` (atau `.tres` `DialogicTimeline` kalau mau pakai editor Dialogic). **INGAT: jangan pakai `Nama:`.** Semua ini Pak Guyon ngomong (protagonis diam). Baris petunjuk arahan pemain boleh, tapi tanpa `Nama:`.

```
Aduh! Lo terjun ya? Hampir gua jatoh dari tangan lo!
...lho. Lo balik juga, akhirnya.
Duduk dulu, ngger. Jangan kepleset lagi. Hahaha.
Astaga. Lo udah jadi bapak-bapak ya sekarang. Padahal terakhir gua liat lo masih mandi pake busa di kepala kayak mahkota.
Lo masih inget gua, kan?
...gak inget juga gapapa. Maklum, gua plastik tua. PVC zaman Pak Harto. Tapi gua dulu PREMIUM, lho. Rp 7.500. Mahal.
Pisang emas dibawa berlayar... ah, lupa lagi.
Yo wis. Sekarang gua bantuin lo sebentar. Ada beberapa temen yang mau mampir mandi. Lo bantuin gua, gua bantuin lo. Mau?
Mantep. Tuh, di rak ada bahan-bahan. Ambil aja yang lo mau. Tumbuk, tuang lewat gua, aduk. Itu aja.
Kalo bingung — coba aja. Gak ada salah di sini. Customer pertama bentar lagi nih.
```
(Boleh warnai kata clue tutorial dengan BBCode emas `[color=#C9A84C]...[/color]`, mis. nama bahan.)

### Aturan skip (dari Production Notes)
- Dialog normal **skippable** (klik = maju baris — Dialogic sudah handle).
- **TIDAK SKIPPABLE**: pembukaan Pak Guyon pertama kali (beat AWAKEN/DIALOGUE baris pertama). Implement guard sederhana (mis. abaikan input skip selama beat sinematik ACT 0, izinkan setelah dialog dimulai).

### Catatan konsistensi
- Karena `00_prologue.tres` (Pak Guyon tutorial) SUDAH ada sebagai "pelanggan 0" di `level1`, ada 2 pilihan — pilih salah satu & sebutkan di komentar:
  - (a) Intro cukup ACT 0 + awakening singkat, lalu level1 mulai dari `00_prologue` (tutorial crafting). **Rekomendasi** — hindari duplikasi dialog.
  - (b) Intro memuat seluruh tutorial, dan `00_prologue.tres` dihapus/di-skip.

---

## BAGIAN B — SAVE / LOAD + PHASE PROGRESSION (kartu PM "Save/Load")

### Tujuan
Menu "Mulai" (baru) dan "Lanjutkan" (dari save) berfungsi; progres tersimpan otomatis (target kartu PM: **auto-save 5 titik**).

> **Sistem pelanggan & unlock bahan SUDAH ADA** (`level1.gd` + `available_ingredients`). Bagian ini **hanya menambahkan lapisan save**: menyimpan/membaca **`customer_index`** (indeks pelanggan aktif) supaya bisa dilanjutkan. Jangan ubah logika antrean/unlock yang sudah jalan — cukup tambahkan `_customer_index` awal dari save + tulis save tiap pelanggan selesai (= 5 titik auto-save: setelah prolog + tiap C1–C4).

### Implementasi
1. Buat **autoload** `scripts/systems/save_manager.gd` (`class_name SaveManager` atau daftarkan sebagai singleton `SaveManager` di Project Settings → Autoload). Simpan ke **`user://busa_save.json`**. Data minimal:
   ```gdscript
   { "seen_intro": false, "customer_index": 0, "has_save": false }
   ```
   API: `save(data)`, `load_data() -> Dictionary`, `has_save() -> bool`, `clear()`.
2. **Main menu** (`main_menu.gd`):
   - **Mulai (baru):** reset save (`customer_index=0`, `seen_intro=false`) → `change_scene_to_file("res://scenes/chapters/intro.tscn")`.
   - **Lanjutkan:** hanya aktif kalau `SaveManager.has_save()`. Langsung ke `level1.tscn` (skip intro) dan level1 mulai dari `customer_index` tersimpan. (Kalau belum ada tombol Lanjutkan, tambahkan; jangan ubah styling tombol lain.)
3. **Auto-save di `level1.gd`** (per Production Notes — auto-save tiap pelanggan selesai):
   - Saat mulai/berpindah pelanggan, `level1` baca `SaveManager` untuk `_customer_index` awal (kalau melanjutkan).
   - Setelah tiap pelanggan selesai (di `_advance_customer` atau `_on_serve`→CLOSING selesai), tulis `{"has_save": true, "customer_index": _customer_index}`.
4. **Intro** menandai `seen_intro=true` sebelum pindah ke level1.

> Save di web export terbatas ke `user://` (browser storage) — tetap jalan, jangan pakai file lokal absolut.

---

## BAGIAN C — WIRING MENU (ubah minimal)
- Ubah `main_menu.gd._on_mulai_pressed()` agar → **`intro.tscn`** (bukan langsung level1).
- Tambah handler `_on_lanjutkan_pressed()` (kalau ada tombol Lanjutkan / `mulai` kedua) → level1 dari save.
- JANGAN restrukturisasi menu; hanya tambah/ubah koneksi sinyal + handler seperlunya. Biarkan `pengaturan`, `kredit`, `keluar`.

---

## ATURAN TEKNIS WAJIB (pelajaran dari kode yang sudah ada)
1. **Jangan pakai `Nama: teks`** di dialog Dialogic (crash). Pakai `(Nama ...)`.
2. **Panel/scene dibuat di editor** (node di `.tscn`), script = logika. Jangan generate kotak lewat `make_box()` gaya lama.
3. **Jangan hapus/rename** properti export CustomerData/IngredientDef (dipakai `.tres`).
4. Kalau menghapus GridContainer/anak node saat `_ready`, pakai `remove_child()` + `queue_free()` (jangan `free()` langsung) dan hindari bongkar-pasang saat `_ready` (bisa segfault).
5. Scene harus **run tanpa error** (EXIT 0 headless). Warning "invalid UID" dari addon Dialogic itu wajar, abaikan.

## ACCEPTANCE CHECKLIST
- [ ] `intro.tscn` + `intro.gd` ada; semua visual = node PlaceholderBox editor-built (bisa di-reskin via texture).
- [ ] Urutan beat ACT 0 → SLIP → WHOOSH → ACT 1 AWAKEN → dialog Pak Guyon jalan mulus.
- [ ] Protagonis NOL dialog di seluruh intro.
- [ ] Dialog Pak Guyon lewat Dialogic; tidak ada baris berpola `Nama:`.
- [ ] `Dialogic.timeline_ended` → set `seen_intro` → `change_scene_to_file` ke `level1.tscn`.
- [ ] Beat pembuka tidak bisa di-skip; dialog normal bisa.
- [ ] `SaveManager` autoload: save/load JSON di `user://`; `has_save()`.
- [ ] Menu: **Mulai** → intro (reset save); **Lanjutkan** → level1 dari `customer_index` (aktif hanya jika ada save).
- [ ] `level1.gd` auto-save `customer_index` tiap pelanggan selesai, dan bisa mulai dari index tersimpan.
- [ ] Run headless `intro.tscn` & `level1.tscn` = **EXIT 0**, tanpa error dari `res://scripts/`.

## OUT OF SCOPE (jangan dulu)
Ending scene (ACT 7–9), Foam Memory reveal, audio/musik, typewriter speed custom, animasi sprite karakter, pengaturan volume. Itu prompt terpisah.
