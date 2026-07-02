# Prompt: Busa Fantasi — SceneManager + GameStateMachine (Core Systems)

> Tempel ke AI coding agent yang jalan DI DALAM project Godot ini.
> Kartu PM: **"Godot Setup + Core Systems"** → bagian **SceneManager (transitions + overlay stack)** dan **GameStateMachine**. Ini lapisan fondasi; kerjakan SEBELUM prompt lain kalau bisa.

---

## FAKTA PROJECT (patuhi)
- **Godot 4.6**, desain 1920×1080, stretch `canvas_items`/`keep`.
- Dialog pakai **Dialogic** (autoload). ⚠️ **Jangan pakai pola `Nama: teks`** di dialog (crash) — pakai `(Nama ...)`.
- Visual pakai **PlaceholderBox** greybox; **panel dibuat di EDITOR** (layout `.tscn`, script = logika).
- Scene yang sudah ada: `scenes/ui/main_menu/main_menu.tscn` (+ `.gd`), `scenes/ui/setting/pengaturan.tscn`, `scenes/chapters/level1.tscn` (+ `level1.gd`, gameplay crafting). (`intro.tscn`/`ending.tscn` mungkin belum ada — jangan berasumsi.)
- Transisi antar scene SEKARANG: `get_tree().change_scene_to_file(...)` langsung; **belum ada** fade/overlay/manajer terpusat. `pengaturan` ditampilkan manual sebagai overlay di dalam `main_menu`.
- **JANGAN bangun ulang** gameplay/pelanggan/unlock di `level1` — sudah jalan.
- Target: run headless **EXIT 0**, tanpa error dari `res://scripts/`.

## STATUS
- **Belum ada** SceneManager global maupun GameStateMachine. Ini yang dibangun.

---

## TUJUAN
Bangun 2 autoload:
1. **`SceneManager`** — transisi scene terpusat dengan **fade**, plus **overlay stack** (push/pop overlay seperti Pengaturan/Pause DI ATAS scene tanpa menghancurkannya).
2. **`GameState`** — state machine global mode game.

## A. SceneManager (`scripts/systems/scene_manager.gd`, autoload `SceneManager`)
- Node autoload dengan **CanvasLayer** internal (layer tinggi) berisi `ColorRect` hitam **`FadeOverlay`** (alpha 0) untuk transisi, dan sebuah **`OverlayLayer`** (CanvasLayer/Control) sebagai tempat menumpuk overlay.
- API:
  - `change_to(scene_path: String, fade := 0.35) -> void` — fade out → `get_tree().change_scene_to_file(scene_path)` → fade in. (Pakai `await`.)
  - `push_overlay(scene: PackedScene) -> Node` — instance overlay, tambahkan ke stack di atas scene aktif (scene bawah tetap hidup, boleh di-pause opsional). Kembalikan node-nya.
  - `pop_overlay() -> void` — buang overlay teratas dari stack.
  - `overlay_count() -> int`.
- Simpan stack overlay di `Array[Node]`. Overlay = scene UI (mis. Pengaturan) — bukan ganti scene.
- Sinyal: `scene_changed(path)`.

## B. GameState (`scripts/systems/game_state.gd`, autoload `GameState`)
- `enum State { TITLE, DIALOG, CRAFTING, FOAM_REVEAL, SETTINGS, CREDITS }`
- `var current: State`
- `func set_state(s: State) -> void` (emit sinyal kalau berubah).
- `signal state_changed(new_state: State)`
- Guna: gating input, musik, dsb (dipakai sistem lain nanti). Untuk sekarang cukup track + sinyal.

## C. Migrasi minimal (JANGAN rombak besar)
- `main_menu.gd._on_mulai_pressed()` → pakai `SceneManager.change_to("res://scenes/chapters/intro.tscn")` (atau `level1.tscn` kalau intro belum ada). Set `GameState.set_state(GameState.State.TITLE)` saat menu tampil.
- `main_menu` **Pengaturan** → pakai `SceneManager.push_overlay(preload pengaturan.tscn)` dan tombol tutup Pengaturan → `SceneManager.pop_overlay()`. (Kalau berisiko, boleh biarkan mekanisme lama; tapi minimal SceneManager tersedia.)
- `level1` saat mulai → `GameState.set_state(CRAFTING)`.
- Biarkan flow lain apa adanya. **Tujuan: SceneManager tersedia & dipakai di titik transisi utama, bukan refactor total.**

## ACCEPTANCE
- [ ] Autoload `SceneManager` & `GameState` terdaftar di Project Settings → Autoload.
- [ ] `change_to()` transisi dengan fade hitam mulus (out→ganti→in).
- [ ] `push_overlay()`/`pop_overlay()` bisa buka Pengaturan di atas scene apa pun lalu tutup, scene bawah tetap utuh.
- [ ] `GameState.current` berubah + `state_changed` teremit di TITLE/CRAFTING minimal.
- [ ] Flow lama (Mulai → gameplay) tetap jalan lewat SceneManager.
- [ ] Run headless scene utama **EXIT 0**, tanpa error dari `res://scripts/`.

## OUT OF SCOPE
Cursor system, save/load, credits, art/audio, gameplay pelanggan (sudah ada). Prompt terpisah.
