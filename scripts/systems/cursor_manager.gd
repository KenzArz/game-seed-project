## CURSOR MANAGER — singleton autoload managing 4 cursor states.
## Wiring: interactive elements call CursorManager.connect_hover(node) at startup,
## or manually connect mouse_entered -> set_cursor(HOVER) & mouse_exited -> set_cursor(DEFAULT).
## NOTE: no `class_name` — autoload name already exposes this globally (class_name would
## clash with the autoload singleton).
##
## Sprite di-load LANGSUNG dari folder aset (autoload tak punya scene, jadi @export
## tak bisa diisi lewat inspector). Kalau file tak ada -> fallback cursor sistem.
extends Node

enum Cursor { DEFAULT, HOVER, DRAG_BAHAN, DRAG_GUYON }

const DIR := "res://assets/cursor + toggle suhu/"
const HOTSPOT := Vector2.ZERO  # atur per aset kalau perlu (mis. ujung panah)
const CURSOR_SIZE := 48  # sprite aslinya 400x400 -> diperkecil ke ukuran cursor wajar

var cursor_default: Texture2D
var cursor_hover: Texture2D
var cursor_drag_bahan: Texture2D
var cursor_drag_guyon: Texture2D

var _current_state := Cursor.DEFAULT
var _drag_locked := false  # saat true, event hover diabaikan (cursor tetap grab)


func _ready() -> void:
	cursor_default = _try_load("Sprite-default.png")
	cursor_hover = _try_load("Sprite-Hover.png")
	cursor_drag_bahan = _try_load("Sprite-Grab.png")
	cursor_drag_guyon = _try_load("Sprite-grab gayungt.png")
	# Terapkan cursor default saat mulai (langsung apply, jangan lewat set_cursor
	# yang di-skip karena state sudah DEFAULT).
	_apply(Cursor.DEFAULT)


func set_cursor(state: Cursor) -> void:
	if _current_state == state:
		return
	_current_state = state
	_apply(state)


func _apply(state: Cursor) -> void:
	var texture := _texture_for(state)
	if texture != null:
		Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, HOTSPOT)
	else:
		Input.set_custom_mouse_cursor(null)  # cursor sistem


func _texture_for(state: Cursor) -> Texture2D:
	match state:
		Cursor.HOVER:
			return cursor_hover
		Cursor.DRAG_BAHAN:
			return cursor_drag_bahan
		Cursor.DRAG_GUYON:
			return cursor_drag_guyon
		_:
			return cursor_default


func _try_load(fname: String) -> Texture2D:
	var path := DIR + fname
	if not ResourceLoader.exists(path):
		push_warning("CursorManager: aset cursor tak ditemukan: " + path)
		return null
	var tex := load(path) as Texture2D
	if tex == null:
		return null
	# Sprite aslinya 400x400 — perkecil ke CURSOR_SIZE (jaga rasio) supaya cursor
	# tidak raksasa. Custom mouse cursor Godot pakai ukuran native texture.
	var img := tex.get_image()
	if img == null:
		return tex
	if img.is_compressed():
		img.decompress()
	var longest := maxi(img.get_width(), img.get_height())
	if longest > CURSOR_SIZE:
		var s := float(CURSOR_SIZE) / float(longest)
		var w := maxi(1, int(round(img.get_width() * s)))
		var h := maxi(1, int(round(img.get_height() * s)))
		img.resize(w, h, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(img)


## Convenience: connect node's hover signals to cursor state changes.
## Hover DIABAIKAN selama drag aktif (begin_drag), supaya cursor tetap grab.
func connect_hover(node: Control) -> void:
	if node == null:
		return
	node.mouse_entered.connect(_on_hover_enter)
	node.mouse_exited.connect(_on_hover_exit)


func _on_hover_enter() -> void:
	if not _drag_locked:
		set_cursor(Cursor.HOVER)


func _on_hover_exit() -> void:
	if not _drag_locked:
		set_cursor(Cursor.DEFAULT)


## Mulai drag: kunci cursor ke `state` (grab), abaikan hover sampai end_drag().
func begin_drag(state: Cursor = Cursor.DRAG_BAHAN) -> void:
	_drag_locked = true
	set_cursor(state)


## Selesai drag: buka kunci, balik ke cursor default.
func end_drag() -> void:
	_drag_locked = false
	set_cursor(Cursor.DEFAULT)


func is_dragging() -> bool:
	return _drag_locked
