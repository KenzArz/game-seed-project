## AUTOLOAD `GameState` — state machine global mode game.
## Dipakai untuk gating input / musik / dsb oleh sistem lain nanti.
## Daftarkan di Project Settings -> Autoload sebagai `GameState`.
extends Node

enum State { TITLE, DIALOG, CRAFTING, FOAM_REVEAL, SETTINGS, CREDITS }

signal state_changed(new_state: int)

var current: int = State.TITLE


## Ganti state; emit sinyal hanya kalau berubah.
func set_state(s: int) -> void:
	if s == current:
		return
	current = s
	state_changed.emit(s)
