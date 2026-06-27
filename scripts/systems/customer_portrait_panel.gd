## Portrait pelanggan yang persisten — tidak dibuat/dihancurkan ulang saat ganti
## fase; cukup digeser (center <-> kiri) dan di-fade saat ganti pelanggan.
##
## LAYOUT di editor (customer_portrait_panel.tscn): 1 node "Portrait".
## Script hanya menggeser/fade + mengganti nama/warna/gambar portrait.
class_name CustomerPortraitPanel
extends CraftPanel

const CENTER_POS := Vector2(730, 120)  # saat ngobrol (intro/closing)
const LEFT_POS := Vector2(70, 240)     # saat split (mixing/serving)

@onready var _portrait: PlaceholderBox = $Portrait
var _move_tween: Tween


func _build() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # tembus klik ke panel di bawahnya


## Reskin portrait untuk pelanggan berbeda.
func configure(customer_name: String, color: Color, tex: Texture2D = null) -> void:
	if _portrait:
		_portrait.display_name = customer_name
		_portrait.box_color = color
		_portrait.texture = tex


func set_center_instant() -> void:
	if _portrait:
		_portrait.position = CENTER_POS


func fade_out(dur := 0.35) -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, dur)


func fade_in(dur := 0.35) -> void:
	modulate.a = 0.0
	visible = true
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, dur)


func move_to_center(dur := 0.35) -> void:
	_tween_to(CENTER_POS, dur)


func move_to_left(dur := 0.35) -> void:
	_tween_to(LEFT_POS, dur)


func _tween_to(pos: Vector2, dur: float) -> void:
	if _portrait == null:
		return
	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()
	_move_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_move_tween.tween_property(_portrait, "position", pos, dur)
