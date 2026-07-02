## FASE 4 — minigame mengaduk (full-screen).
##
## LAYOUT dibuat di EDITOR (lihat stir_panel.tscn): backdrop, gayung, sendok,
## bar progress, tombol — semua node yang bisa kamu geser/edit visual.
## Script ini HANYA logika: deteksi gerakan melingkar + update tampilan.
##
## Pusat & radius area aduk DIAMBIL dari node "Gayung", jadi kalau kamu geser
## atau ubah ukuran gayungnya di editor, area aduknya otomatis menyesuaikan.
class_name StirPanel
extends CraftPanel

signal serve_requested

const MAX_STIR := 5

@onready var _vessel: PlaceholderBox = $Vessel       # penanda geometri aduk (transparan)
@onready var _spoon: PlaceholderBox = $Spoon         # sendok
@onready var _air: PlaceholderBox = $Air             # layer air/ramuan (tampil saat mengaduk)
@onready var _busa: Array = [$Busa1, $Busa2, $Busa3] # 3 tingkat busa, muncul bertahap
@onready var _info: Label = $Info
@onready var _progress_bg: ColorRect = $ProgressBg
@onready var _progress_fill: ColorRect = $ProgressFill
@onready var _sajikan: Button = $Sajikan

var stir_count := 0
var _accum_angle := 0.0  # total jarak sudut yang sudah diputar (radian)
var _dragging := false
var _last_angle := 0.0
var _center := Vector2.ZERO
var _radius := 1.0
var _spoon_radius := 1.0


func _build() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP  # panel menerima gerakan seret
	_sajikan.pressed.connect(func() -> void: serve_requested.emit())
	CursorManager.connect_hover(_sajikan)  # tombol Sajikan ikut hover
	# Ambil geometri dari node gayung (ikut kalau digeser/diresize di editor).
	_center = _vessel.position + _vessel.size * 0.5
	_radius = _vessel.size.x * 0.5
	_spoon_radius = _radius * 0.72
	reset_stir()


func reset_stir() -> void:
	stir_count = 0
	_accum_angle = 0.0
	_dragging = false
	if _air:
		_air.visible = true  # ramuan/air selalu tampil saat mengaduk
	if _sajikan:
		_sajikan.disabled = true  # baru bisa disajikan setelah adukan penuh
	_update_spoon(-PI / 2.0)  # parkir sendok di atas
	_refresh()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.position.distance_to(_center) <= _radius * 1.4:
			_dragging = true
			_last_angle = (mb.position - _center).angle()
			CursorManager.begin_drag(CursorManager.Cursor.DRAG_BAHAN)  # kunci grab saat mengaduk
		else:
			if _dragging:
				CursorManager.end_drag()
			_dragging = false
		accept_event()
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _dragging:
			var ang := (mm.position - _center).angle()
			_accum_angle += absf(angle_difference(_last_angle, ang))
			_last_angle = ang
			_update_spoon(ang)
			_refresh()
		else:
			# Hover di area aduk -> cursor HOVER (nandain bisa di-grab & diputar).
			var inside := mm.position.distance_to(_center) <= _radius * 1.4
			CursorManager.set_cursor(CursorManager.Cursor.HOVER if inside else CursorManager.Cursor.DEFAULT)


func _update_spoon(ang: float) -> void:
	if _spoon:
		_spoon.position = _center + Vector2(cos(ang), sin(ang)) * _spoon_radius - _spoon.size * 0.5


func _refresh() -> void:
	var rotations := _accum_angle / TAU
	var frac := clampf(rotations / float(MAX_STIR), 0.0, 1.0)
	var new_count: int = mini(MAX_STIR, int(floor(rotations)))
	if new_count > stir_count:
		stir_count = new_count
		AudioManager.play_sfx("aduk")
	_perbarui_busa(frac)  # busa muncul dikit-dikit seiring adukan
	if _progress_fill and _progress_bg:
		_progress_fill.size = Vector2(_progress_bg.size.x * frac, _progress_fill.size.y)
	if _sajikan:
		_sajikan.disabled = stir_count < MAX_STIR  # baru aktif kalau sudah penuh
	if _info:
		var done := stir_count >= MAX_STIR
		_info.text = "Adukan: %d/%d %s" % [stir_count, MAX_STIR, "(rata sempurna!)" if done else ""]


# Tampilkan tingkat busa sesuai kemajuan adukan: makin banyak diaduk, makin banyak
# busa (Busa1 -> Busa2 -> Busa3). Hanya satu tingkat tampil pada satu waktu.
func _perbarui_busa(frac: float) -> void:
	var level := 0
	if frac >= 0.75:
		level = 3
	elif frac >= 0.45:
		level = 2
	elif frac >= 0.15:
		level = 1
	for i in range(_busa.size()):
		if _busa[i]:
			_busa[i].visible = (level == i + 1)
