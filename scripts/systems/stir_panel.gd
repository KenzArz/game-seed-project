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

@onready var _vessel: PlaceholderBox = $Vessel       # gayung
@onready var _spoon: PlaceholderBox = $Spoon         # sendok
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
	# Ambil geometri dari node gayung (ikut kalau digeser/diresize di editor).
	_center = _vessel.position + _vessel.size * 0.5
	_radius = _vessel.size.x * 0.5
	_spoon_radius = _radius * 0.72
	reset_stir()


func reset_stir() -> void:
	stir_count = 0
	_accum_angle = 0.0
	_dragging = false
	_update_spoon(-PI / 2.0)  # parkir sendok di atas
	_refresh()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.position.distance_to(_center) <= _radius * 1.4:
			_dragging = true
			_last_angle = (mb.position - _center).angle()
		else:
			_dragging = false
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		var ang := ((event as InputEventMouseMotion).position - _center).angle()
		_accum_angle += absf(angle_difference(_last_angle, ang))
		_last_angle = ang
		_update_spoon(ang)
		_refresh()


func _update_spoon(ang: float) -> void:
	if _spoon:
		_spoon.position = _center + Vector2(cos(ang), sin(ang)) * _spoon_radius - _spoon.size * 0.5


func _refresh() -> void:
	var rotations := _accum_angle / TAU
	var new_count: int = mini(MAX_STIR, int(floor(rotations)))
	if new_count > stir_count:
		stir_count = new_count
		if _vessel:
			_vessel.pop()
	if _progress_fill and _progress_bg:
		var overall := clampf(rotations / float(MAX_STIR), 0.0, 1.0)
		_progress_fill.size = Vector2(_progress_bg.size.x * overall, _progress_fill.size.y)
	if _info:
		var done := stir_count >= MAX_STIR
		_info.text = "Adukan: %d/%d %s" % [stir_count, MAX_STIR, "(rata sempurna!)" if done else ""]
