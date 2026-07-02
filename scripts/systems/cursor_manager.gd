## CURSOR MANAGER — singleton autoload managing 4 cursor states.
## Wiring: interactive elements call CursorManager.connect_hover(node) at startup,
## or manually connect mouse_entered -> set_cursor(HOVER) & mouse_exited -> set_cursor(DEFAULT).
## NOTE: no `class_name` — autoload name already exposes this globally (class_name would
## clash with the autoload singleton).
extends Node

enum Cursor { DEFAULT, HOVER, DRAG_BAHAN, DRAG_GUYON }

@export var cursor_default: Texture2D
@export var cursor_hover: Texture2D
@export var cursor_drag_bahan: Texture2D
@export var cursor_drag_guyon: Texture2D

var _current_state := Cursor.DEFAULT


func set_cursor(state: Cursor) -> void:
	if _current_state == state:
		return
	_current_state = state

	var texture: Texture2D = null
	match state:
		Cursor.DEFAULT:
			texture = cursor_default
		Cursor.HOVER:
			texture = cursor_hover
		Cursor.DRAG_BAHAN:
			texture = cursor_drag_bahan
		Cursor.DRAG_GUYON:
			texture = cursor_drag_guyon

	# Apply cursor or fall back to system cursor if texture missing.
	if texture != null:
		Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, Vector2.ZERO)
	else:
		Input.set_custom_mouse_cursor(null)  # system cursor


## Convenience: connect node's hover signals to cursor state changes.
func connect_hover(node: Control) -> void:
	if node == null:
		return
	node.mouse_entered.connect(func() -> void: set_cursor(Cursor.HOVER))
	node.mouse_exited.connect(func() -> void: set_cursor(Cursor.DEFAULT))
