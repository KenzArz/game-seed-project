## Base class untuk setiap panel-fase yang meluncur (dialog, racik, sajikan, aduk).
##
## Tiap panel = Control full-screen (1920x1080) yang digeser masuk/keluar layar
## oleh koordinator level1. Panel MEMILIKI tween slide-nya sendiri (koordinator
## hanya menentukan ARAH & KAPAN); subclass mengisi logika di `_build()`.
class_name CraftPanel
extends Control

enum Dir { LEFT, RIGHT, TOP, BOTTOM }

const DESIGN_SIZE := Vector2(1920, 1080)
const PlaceholderBoxScene := preload("res://scenes/ui/placeholder_box.tscn")

var _slide_tween: Tween


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = DESIGN_SIZE
	_build()


## Di-override subclass untuk mengisi logika (sambung tombol, dll). Layout-nya
## sendiri sudah ada di file .tscn (dibuat di editor).
func _build() -> void:
	pass


# Posisi off-screen sesuai arah (dipakai saat parkir/slide).
func _offset(dir: int) -> Vector2:
	match dir:
		Dir.LEFT:
			return Vector2(-DESIGN_SIZE.x, 0)
		Dir.RIGHT:
			return Vector2(DESIGN_SIZE.x, 0)
		Dir.TOP:
			return Vector2(0, -DESIGN_SIZE.y)
		Dir.BOTTOM:
			return Vector2(0, DESIGN_SIZE.y)
	return Vector2.ZERO


# Parkir di luar layar (tanpa animasi) + sembunyikan.
func place_off(dir: int) -> void:
	position = _offset(dir)
	visible = false


# Tempatkan di tengah layar (tanpa animasi).
func place_center() -> void:
	position = Vector2.ZERO
	visible = true


## Meluncur masuk dari arah `dir` ke posisi tengah (di layar).
func slide_in(dir: int, dur := 0.35) -> void:
	position = _offset(dir)
	visible = true
	_kill_tween()
	_slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_slide_tween.tween_property(self, "position", Vector2.ZERO, dur)


## Meluncur keluar ke arah `dir`, lalu sembunyikan.
func slide_out(dir: int, dur := 0.35) -> void:
	_kill_tween()
	_slide_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_slide_tween.tween_property(self, "position", _offset(dir), dur)
	_slide_tween.tween_callback(func() -> void: visible = false)


func _kill_tween() -> void:
	if _slide_tween and _slide_tween.is_valid():
		_slide_tween.kill()


# --- Helper lama (dipakai saat panel masih dibuat lewat kode). Sekarang panel
# --- dibuat di editor, jadi helper ini jarang dipakai tapi disisakan. ---

## Pasang gambar ke greybox hanya kalau texture-nya benar-benar ada.
func apply_texture(box: PlaceholderBox, tex: Texture2D) -> void:
	if box and tex:
		box.texture = tex


## Label judul yang diletakkan di ATAS frame (supaya judul tidak jatuh di tengah
## kotak besar dan nembus ke kontrol lain).
func make_title(text: String, top_left: Vector2, width: float) -> Label:
	var l := Label.new()
	l.text = text
	l.position = top_left
	l.size = Vector2(width, 44)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 28)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


## Bikin anak greybox yang bisa di-reskin. `ignore_mouse=false` membuatnya bisa
## diklik (sinyal `clicked` aktif). Mengembalikan PlaceholderBox-nya.
func make_box(text: String, rect: Rect2, color: Color, ignore_mouse := true) -> PlaceholderBox:
	var b: PlaceholderBox = PlaceholderBoxScene.instantiate()
	b.display_name = text
	b.box_color = color
	add_child(b)
	b.position = rect.position
	b.size = rect.size
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE if ignore_mouse else Control.MOUSE_FILTER_STOP
	return b
