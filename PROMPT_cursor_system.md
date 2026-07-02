# Prompt: Busa Fantasi — Input Manager + Custom Cursor (4 state)

> Tempel ke AI coding agent yang jalan DI DALAM project Godot ini.
> Kartu PM: **"Input Manager + Cursor System"** — input mouse (click/drag/hover) + **cursor custom 4 state** (default / hover / drag bahan / drag Pak Guyon).

---

## FAKTA PROJECT (patuhi)
- **Godot 4.6**, desain 1920×1080.
- Input SEKARANG sudah mouse-based (klik/hover) lewat Godot bawaan. Kotak bahan/tombol pakai `Button` & `PlaceholderBox` (sinyal `clicked`).
- ⚠️ **Interaksi mixing SEKARANG = KLIK-ke-slot, BUKAN drag.** Pak Guyon juga tidak di-drag. Jadi state cursor "drag bahan"/"drag Pak Guyon" **belum terpakai aktif** — sediakan API-nya, aktif nanti kalau interaksi drag ditambahkan. **Jangan mengubah interaksi klik yang sudah jalan.**
- Target: run headless **EXIT 0**, tanpa error `res://scripts/`.

## TUJUAN
Buat **CursorManager** (autoload) yang mengganti gambar cursor sesuai state, + wiring hover di elemen interaktif.

## A. CursorManager (`scripts/systems/cursor_manager.gd`, autoload `CursorManager`)
- `enum Cursor { DEFAULT, HOVER, DRAG_BAHAN, DRAG_GUYON }`
- Export/const 4 `Texture2D` (default null → pakai cursor greybox/placeholder atau cursor sistem sampai aset ada). Reskin nanti = isi texture.
- `func set_cursor(state: Cursor) -> void` → `Input.set_custom_mouse_cursor(tex, Input.CURSOR_ARROW, hotspot)`; kalau tex null, `Input.set_custom_mouse_cursor(null)` (cursor sistem).
- `hotspot` default `Vector2.ZERO` (atur per aset nanti).
- Simpan state aktif; hindari set berulang kalau state sama.

## B. Wiring hover (yang bisa dilakukan sekarang)
- Saat mouse **masuk** elemen interaktif (tombol / kotak bahan clickable) → `set_cursor(HOVER)`; saat **keluar** → `set_cursor(DEFAULT)`.
- Cara paling bersih: hubungkan `mouse_entered`/`mouse_exited` pada node interaktif. Untuk kotak bahan di `MixingPanel` (dibuat dari data), sambungkan saat item dibuat. Untuk `Button`, sambungkan di panel masing-masing. **Tambah wiring seperlunya, jangan rombak layout.**

## C. State drag (SIAPKAN, belum diaktifkan)
- Sediakan `set_cursor(DRAG_BAHAN)` / `set_cursor(DRAG_GUYON)` untuk dipakai kalau nanti ada interaksi drag. Beri komentar jelas: "dipanggil saat mulai/berhenti drag bahan / Pak Guyon (belum ada di build ini)."

## ACCEPTANCE
- [ ] Autoload `CursorManager` terdaftar.
- [ ] `set_cursor()` mengganti cursor (atau ke cursor sistem kalau texture null) tanpa error.
- [ ] Hover di tombol/kotak bahan → cursor berubah ke HOVER, keluar → DEFAULT.
- [ ] API `DRAG_BAHAN`/`DRAG_GUYON` ada + berkomentar (belum dipakai aktif).
- [ ] Interaksi klik-ke-slot yang sudah ada TIDAK berubah/rusak.
- [ ] Run headless **EXIT 0**, tanpa error `res://scripts/`.

## OUT OF SCOPE
Mengubah mixing jadi drag-based, SceneManager, save, credits, art final. Prompt terpisah.
