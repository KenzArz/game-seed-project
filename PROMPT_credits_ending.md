# Prompt: Busa Fantasi — Ending Scene + Credits + Title Polish

> Tempel ke AI coding agent yang jalan DI DALAM project Godot ini.
> Kartu PM: **"Credits + Title Screen"** — credits auto-scroll (ESC skip) + menu (Mulai/Lanjutkan/Pengaturan/Keluar, easter egg klik gayung). PLUS **ACT 7–9** dari NARRATIVE_BIBLE (closure + wakeup dunia nyata + title/credits).

---

## FAKTA PROJECT (patuhi)
- **Godot 4.6**, desain 1920×1080, stretch `canvas_items`/`keep`.
- Dialog pakai **Dialogic** (autoload). Start: `Dialogic.start(DialogicTimeline.new().from_text("\n".join(baris)))`; selesai → `Dialogic.timeline_ended`. ⚠️ **JANGAN pakai pola `Nama: teks`** (crash) — pakai `(Nama ...)`.
- Visual pakai **PlaceholderBox** greybox (swappable texture); **scene dibuat di EDITOR** (layout `.tscn`, script = logika).
- Menu: `scenes/ui/main_menu/main_menu.tscn` (+ `.gd`) — tombol `mulai` (→ gameplay), `pengaturan`, `kredit` (BELUM diwire), `keluar`. **Belum ada** tombol Lanjutkan, credits-scroll, easter-egg.
- Gameplay `level1.gd` punya `enum Phase { ... DONE }`; pelanggan terakhir (Mystery Child) selesai → fase **DONE** + saat ini menampilkan label "Semua pelanggan selesai". **Sambungkan DONE → pindah ke ending.**
- **Protagonis TIDAK PERNAH bicara.** Pak Guyon PLAYFUL. Tone: bikin **senyum**, bukan nangis.
- Target: run headless **EXIT 0**, tanpa error `res://scripts/`.

---

## BAGIAN A — ENDING SCENE (`scenes/chapters/ending.tscn` + `scripts/systems/ending.gd`)
Scene sinematik ACT 7–9, greybox editor-built. Dipanggil setelah gameplay selesai.

### Beat (dari NARRATIVE_BIBLE)
1. **ACT 7 — Cozy Closure:** dunia fantasi menenang, light bergeser ke biru malam. Dialog penutup **Pak Guyon** (via Dialogic), lalu Pak Guyon "tidur" (mata tertutup pelan — bukan dramatic).
2. **ACT 8 — Wakeup dunia nyata:** fade ke kamar mandi nyata, sinar pagi. Protagonis pegang gayung + kertas coretan crayon (memento). Protagonis **SMILE** (pertama kali wajah penuh, tanpa dialog). Hold ~5 detik.
3. **ACT 9 — Title + Credits:** fade ke title card **"BUSA FANTASI"**, lalu credits auto-scroll.

### Dialog ACT 7 (feed Dialogic, TANPA pola `Nama:`)
```
Seru ya hari ini, ngger. Kayak dulu pas lo bocah, main lama-lama sampe ibumu marah.
Lo udah lupa gimana rasanya ya?
Tapi sekarang inget lagi.
Yo wis. Gua tidur dulu ya, nak. Lo juga tidur ya. Besok bangun, jangan kepleset lagi. Hahaha.
```
(ACT 8 & 9 tanpa dialog.)

## BAGIAN B — CREDITS (bagian ACT 9 / kartu PM)
- Node credits: `RichTextLabel`/`Label` panjang di dalam scroll, **auto-scroll ke atas** pelan (tween/`AnimationPlayer` gerakkan posisi).
- **ESC / klik → skip** (langsung ke akhir / kembali ke menu).
- Musik "Track 10" = placeholder (kalau audio belum ada, lewati; beri komentar hook).
- Setelah credits selesai/di-skip → `change_scene_to_file` ke **main_menu**.

## BAGIAN C — TITLE POLISH (kartu PM, ubah minimal di `main_menu`)
- **Tombol "Lanjutkan":** tambahkan (kalau belum ada) — aktif hanya jika ada save (lihat sistem save kalau sudah dibuat; kalau belum, boleh disabled + komentar TODO). Jangan restyle tombol lain.
- **Wire "Kredit":** `_on_kredit_pressed()` → tampilkan credits (scene/overlay yang sama dengan ACT 9, tanpa ending sinematik).
- **Easter egg klik gayung:** node gayung di menu (`PakGuyonGayung` sudah ada di main_menu.tscn) → saat diklik, tampilkan **1 baris joke random Pak Guyon** (pop-up kecil / Dialogic 1 baris). Kumpulan joke (pilih acak, TANPA `Nama:`):
  - "Gua dulu PREMIUM, lho. Rp 7.500. Mahal."
  - "Pisang emas dibawa berlayar... ah, lupa lagi."
  - "Lo pernah liat gayung yang ngomong? Gak pernah, kan? Soalnya yang lain malu."
  - "Maklum, plastik tua. PVC zaman Pak Harto."
  > ⚠️ `randi()`/random: jangan pakai di tempat yang bikin non-deterministik kalau tak perlu; untuk easter egg boleh `randi()` biasa (butuh `randomize()` sekali).

## BAGIAN D — WIRING FLOW
- `level1.gd`: saat fase **DONE** (Mystery Child selesai) → `change_scene_to_file("res://scenes/chapters/ending.tscn")` (ganti label "selesai" yang sekarang).

## ACCEPTANCE
- [ ] `ending.tscn` + `ending.gd`: ACT 7 (dialog Pak Guyon + tidur) → ACT 8 (wakeup + smile, protagonis diam) → ACT 9 (title + credits). Greybox editor-built.
- [ ] Dialog ACT 7 lewat Dialogic; tidak ada baris berpola `Nama:`.
- [ ] Credits auto-scroll; **ESC/klik skip**; selesai → main_menu.
- [ ] `main_menu`: **Kredit** menampilkan credits; **easter egg** klik gayung memunculkan joke random Pak Guyon; tombol **Lanjutkan** ada (disabled kalau save belum ada).
- [ ] `level1` fase DONE → pindah ke `ending.tscn`.
- [ ] Protagonis NOL dialog di seluruh ending.
- [ ] Run headless `ending.tscn` **EXIT 0**, tanpa error `res://scripts/`.

## OUT OF SCOPE
Foam Memory reveal, audio final, cursor system, SceneManager, save/load (kartu terpisah). Kalau SceneManager/save sudah ada, boleh dipakai; kalau belum, `change_scene_to_file` langsung + TODO.
