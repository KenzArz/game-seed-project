## ENDING — sinematik penutup (ACT 7-9). Visual & timing dibuat di EDITOR lewat
## AnimationPlayer (klip "act7" & "act8"); script HANYA logika + gate dialog.
##
##   ACT 7 (klip "act7"): fade in dunia fantasi malam -> Call Method _mulai_dialog
##                        Dialog penutup Pak Guyon dari closing.dtl via Dialogic.
##   Dialog selesai -> mainkan klip "act8".
##   ACT 8 (klip "act8"): Pak Guyon tidur -> kilat putih -> kamar mandi pagi +
##                        protagonis senyum -> tahan -> _ke_credits.
##
## Protagonis TIDAK bicara. Pak Guyon playful. Tone: senyum kecil yang earned.
extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var fade: ColorRect = $FadeOverlay
@onready var bg_fantasy: PlaceholderBox = $BgFantasy
@onready var pak_guyon: PlaceholderBox = $PakGuyon
@onready var bg_real: PlaceholderBox = $BgReal
@onready var protagonist: PlaceholderBox = $Protagonist

var _lanjut := false


func _ready() -> void:
	GameState.set_state(GameState.State.DIALOG)
	AudioManager.play_bgm("ending")
	bg_real.modulate.a = 0.0
	protagonist.modulate.a = 0.0
	fade.color = Color.BLACK
	fade.modulate.a = 1.0
	Dialogic.timeline_ended.connect(_on_act7_done)
	anim.play("act7")


## Call Method track (akhir klip act7): mulai dialog penutup Pak Guyon.
## Pakai closing.dtl — monolog Pak Guyon sebelum dia tidur.
func _mulai_dialog() -> void:
	var tl: DialogicTimeline = load("res://resources/dialog/closing.dtl")
	if tl == null:
		# Fallback kalau file tidak ditemukan
		push_error("[ending] closing.dtl tidak ditemukan!")
		_on_act7_done()
		return
	Dialogic.start(tl)


func _on_act7_done() -> void:
	if _lanjut:
		return
	_lanjut = true
	anim.play("act8")


## Call Method track (akhir klip act8): lanjut ke credits.
func _ke_credits() -> void:
	SceneManager.change_to("res://scenes/chapters/credits.tscn")
