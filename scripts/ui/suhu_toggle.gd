## SUHU TOGGLE — flavor-only, SATU tombol yang di-klik untuk berganti suhu:
## Netral -> Panas -> Dingin -> Netral. Tanpa pengaruh skor. Reset per pelanggan.
## Visibilitas mengikuti fase CRAFTING.
class_name SuhuToggle
extends Control

enum State { NETRAL, PANAS, DINGIN }

const STATE_NAMES := ["Netral", "Panas", "Dingin"]
const DIR := "res://assets/cursor + toggle suhu/"
# Sprite "normal" per state (ditukar tiap klik).
const STATE_TEX := {
	State.NETRAL: "Sprite-Suhu default.png",
	State.PANAS: "Sprite-Suhu Hot .png",
	State.DINGIN: "Sprite-Suhu cold.png",
}
# Sprite "pressed" (tampil selagi tombol ditekan) per state.
const STATE_TEX_PRESSED := {
	State.NETRAL: "Sprite-Suhu default pressed.png",
	State.PANAS: "Sprite-Suhu Hot pressed.png",
	State.DINGIN: "Sprite-Suhu cold pressed.png",
}

@onready var btn: TextureButton = $Btn
@onready var label: Label = $Label

var current_state := State.NETRAL


func _ready() -> void:
	if btn:
		btn.pressed.connect(cycle_state)
	reset()
	GameState.state_changed.connect(_on_game_state_changed)
	_on_game_state_changed(GameState.current)


## Klik -> maju ke suhu berikutnya (memutar).
func cycle_state() -> void:
	set_state((current_state + 1) % State.size())


func set_state(state: int) -> void:
	if state < 0 or state >= State.size():
		return
	current_state = state
	_update_visual()


func reset() -> void:
	current_state = State.NETRAL
	_update_visual()


func _update_visual() -> void:
	if btn:
		btn.texture_normal = _load_tex(STATE_TEX[current_state])
		btn.texture_pressed = _load_tex(STATE_TEX_PRESSED[current_state])
	if label:
		label.text = STATE_NAMES[current_state]


func _load_tex(fname: String) -> Texture2D:
	var path := DIR + fname
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _on_game_state_changed(new_state: int) -> void:
	# Tampil hanya saat fase CRAFTING.
	visible = (new_state == GameState.State.CRAFTING)
