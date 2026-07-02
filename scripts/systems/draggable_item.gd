## Kotak yang bisa DI-DRAG (bahan di rak & bubuk hasil tumbuk). Mewarisi
## PlaceholderBox jadi tetap greybox swappable (isi `texture` = jadi gambar).
##
## Interaksi: tekan kiri -> angkat -> ikut kursor -> lepas. Saat dilepas, ia
## memancarkan sinyal `dropped`; KOORDINATOR (level1) yang memutuskan apakah pas
## di atas target (ulekan/gayung) atau harus balik ke posisi semula.
##
## `id` menyimpan id bahan (mis. "sabun") untuk pencocokan resep — tidak tampil.
@tool
class_name DraggableItem
extends PlaceholderBox

signal picked_up(item: DraggableItem)
signal dropped(item: DraggableItem)

@export var id: String = ""

var drag_enabled := true
var _dragging := false
var _drag_offset := Vector2.ZERO
var _home_pos := Vector2.ZERO


func _ready() -> void:
	super()  # PlaceholderBox: bangun visual greybox
	_home_pos = position


## Catat ulang posisi "rumah" (mis. setelah dipindah di editor via kode).
func set_home() -> void:
	_home_pos = position


## Kembalikan ke posisi semula (dipanggil koordinator kalau drop tidak valid).
func return_home() -> void:
	_dragging = false
	z_index = 0
	position = _home_pos


func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not drag_enabled:
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			_dragging = true
			_drag_offset = get_global_mouse_position() - global_position
			z_index = 100
			move_to_front()
			picked_up.emit(self)
		elif _dragging:
			_dragging = false
			z_index = 0
			dropped.emit(self)
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset
		accept_event()
