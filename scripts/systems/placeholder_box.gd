## Kotak greybox serbaguna & bisa di-reskin, dipakai untuk SEMUA visual statis
## (latar, frame panel, portrait, slot rak/wadah, kotak hasil, gayung). Inilah
## "kontrak swap" untuk seluruh prototype:
##
##   ATURAN SWAP: isi `texture` (lewat Inspector atau kode) maka kotak warna +
##   Label nama otomatis diganti gambar. Tidak ada kode yang mengunci nama/warna
##   sehingga menghalangi swap ini.
@tool
class_name PlaceholderBox
extends Control

## Diemit saat klik kiri (dipakai kotak yang bisa diklik: bahan rak, slot, gayung).
signal clicked

@export var display_name: String = "BOX":
	set(value):
		display_name = value
		_rebuild()
@export var texture: Texture2D:
	set(value):
		texture = value
		_rebuild()
@export var texture_hover: Texture2D:
	set(value):
		texture_hover = value
		_rebuild()
@export var box_color: Color = Color(0.3, 0.3, 0.35):
	set(value):
		box_color = value
		_rebuild()

# Node visual internal — dibuat saat runtime, owner=null supaya tidak pernah ikut
# tersimpan ke scene yang meng-instance PlaceholderBox ini.
var _color_rect: ColorRect
var _texture_rect: TextureRect
var _label: Label
var _is_hovering := false


func _ready() -> void:
	_ensure_nodes()
	_rebuild()
	_ensure_nodes()
	_rebuild()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	_is_hovering = true
	_rebuild()

func _on_mouse_exited() -> void:
	_is_hovering = false
	_rebuild()

# Pastikan ketiga node visual ada (dibuat sekali).
func _ensure_nodes() -> void:
	_color_rect = get_node_or_null("_ColorRect")
	if _color_rect == null:
		_color_rect = ColorRect.new()
		_color_rect.name = "_ColorRect"
		_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_color_rect)

	_texture_rect = get_node_or_null("_TextureRect")
	if _texture_rect == null:
		_texture_rect = TextureRect.new()
		_texture_rect.name = "_TextureRect"
		_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_texture_rect)

	_label = get_node_or_null("_Label")
	if _label == null:
		_label = Label.new()
		_label.name = "_Label"
		_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_label.clip_text = true
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_label)


# Atur tampilan: kalau ada texture → tampilkan gambar; kalau tidak → kotak warna + nama.
func _rebuild() -> void:
	_ensure_nodes()
	var current_tex: Texture2D = texture_hover if (_is_hovering and texture_hover) else texture
	var has_tex := current_tex != null
	_texture_rect.texture = current_tex
	_texture_rect.visible = has_tex
	_color_rect.visible = not has_tex
	_color_rect.color = box_color
	_label.text = display_name
	_label.visible = not has_tex


func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit()
		accept_event()


## Efek "aksi valid" — kotak memantul sebentar.
func pop() -> void:
	if Engine.is_editor_hint():
		return
	pivot_offset = size * 0.5
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.08, 1.08), 0.08)
	t.tween_property(self, "scale", Vector2.ONE, 0.12)


## Efek "aksi tidak valid" — kotak berkedip merah sebentar.
func flash_error() -> void:
	if Engine.is_editor_hint():
		return
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1.0, 0.4, 0.4), 0.08)
	t.tween_property(self, "modulate", Color.WHITE, 0.18)
