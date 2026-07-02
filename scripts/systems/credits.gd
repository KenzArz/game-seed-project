## CREDITS — layar credit. LAYOUT, warna, DAN gerak scroll dibuat di EDITOR:
##   layout = Label/ColorRect/VBoxContainer (credits.tscn)
##   scroll = klip AnimationPlayer "scroll" (geser Content:position) + Call Method
##            track memanggil _ke_menu() di akhir.
## Script HANYA logika: mainkan klip + skip (ESC/klik) -> kembali ke main menu.
##
## Dipakai dua tempat: akhir ending (setelah ACT 8) dan tombol "Kredit" di menu.
extends Control

@onready var _anim: AnimationPlayer = $AnimationPlayer

var _selesai := false


func _ready() -> void:
	GameState.set_state(GameState.State.CREDITS)
	# TODO(audio): mainkan "Track 10" (BGM credit) di sini kalau aset sudah ada.
	_anim.play("scroll")


func _unhandled_input(event: InputEvent) -> void:
	if _selesai:
		return
	var klik := event is InputEventMouseButton and (event as InputEventMouseButton).pressed
	if klik or event.is_action_pressed("ui_cancel"):  # klik atau ESC = lewati
		_ke_menu()


# Dipanggil dari Call Method track di akhir klip, atau saat pemain skip.
func _ke_menu() -> void:
	if _selesai:
		return
	_selesai = true
	SceneManager.change_to("res://scenes/ui/main_menu/main_menu.tscn")
