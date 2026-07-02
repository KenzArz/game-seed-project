## ALAT ULEK (pestle) — di-grab lalu digerakkan NAIK-TURUN di atas mangkuk untuk
## menghaluskan bahan. Mewarisi PlaceholderBox jadi tetap greybox swappable
## (isi `texture` = jadi gambar alat ulek).
##
## Saat di-drag, memancarkan `gerus(dy, pusat_global)` tiap gerak; Ulekan yang
## menghitung progres (hanya dihitung kalau alat sedang di atas mangkuk).
## Dilepas -> balik ke posisi semula.
@tool
class_name Pestle
extends PlaceholderBox

signal gerus(dy: float, pusat_global: Vector2)
signal dilepas

var _drag := false
var _offset := Vector2.ZERO
var _home := Vector2.ZERO


func _ready() -> void:
	super()  # PlaceholderBox: bangun visual greybox
	_home = position


func return_home() -> void:
	_drag = false
	z_index = 0
	var t := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "position", _home, 0.15)


func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			_drag = true
			_offset = get_global_mouse_position() - global_position
			z_index = 60
			move_to_front()
			CursorManager.set_cursor(CursorManager.Cursor.DRAG_BAHAN)  # sama kayak pegang bubuk
		elif _drag:
			_drag = false
			CursorManager.set_cursor(CursorManager.Cursor.DEFAULT)
			dilepas.emit()
		accept_event()
	elif event is InputEventMouseMotion and _drag:
		global_position = get_global_mouse_position() - _offset
		# Kirim posisi KURSOR (titik gerus), bukan tengah alat — biar deteksi
		# akurat di atas mangkuk, tak terpengaruh ukuran/area transparan alat.
		gerus.emit((event as InputEventMouseMotion).relative.y, get_global_mouse_position())
		accept_event()
