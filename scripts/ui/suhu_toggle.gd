## SUHU TOGGLE — flavor-only 3-state toggle (Dingin/Netral/Panas).
## No scoring impact. Resets per customer. Visibility tied to GameState.CRAFTING.
class_name SuhuToggle
extends Control

enum State { DINGIN, NETRAL, PANAS }

const STATE_NAMES := ["Dingin", "Netral", "Panas"]

@onready var dingin_btn: TextureButton = $DinginBtn
@onready var netral_btn: TextureButton = $NetralBtn
@onready var panas_btn: TextureButton = $PanasBtn
@onready var label: Label = $Label

var current_state := State.NETRAL


func _ready() -> void:
	reset()
	# Wire button presses to set state.
	if dingin_btn:
		dingin_btn.pressed.connect(func() -> void: set_state(State.DINGIN))
	if netral_btn:
		netral_btn.pressed.connect(func() -> void: set_state(State.NETRAL))
	if panas_btn:
		panas_btn.pressed.connect(func() -> void: set_state(State.PANAS))

	# Visibility follows CRAFTING phase.
	GameState.state_changed.connect(_on_game_state_changed)
	_on_game_state_changed(GameState.current)


func cycle_state() -> void:
	var next := (current_state + 1) % State.size()
	set_state(next)


func set_state(state: int) -> void:
	if state < 0 or state >= State.size():
		return
	current_state = state
	_update_visual()


func reset() -> void:
	current_state = State.NETRAL
	_update_visual()


func _update_visual() -> void:
	# Update button visual states (pressed appearance).
	if dingin_btn:
		dingin_btn.button_pressed = (current_state == State.DINGIN)
	if netral_btn:
		netral_btn.button_pressed = (current_state == State.NETRAL)
	if panas_btn:
		panas_btn.button_pressed = (current_state == State.PANAS)
	# Update label if present.
	if label:
		label.text = STATE_NAMES[current_state]


func _on_game_state_changed(new_state: int) -> void:
	# Show toggle only during CRAFTING phase.
	visible = (new_state == GameState.State.CRAFTING)
