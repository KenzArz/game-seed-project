## ENDING — sinematik penutup (ACT 7-9). Visual & timing dibuat di EDITOR lewat
## AnimationPlayer (klip "act7" & "act8"); script HANYA logika + gate dialog.
##   ACT 7 (klip "act7"): fade in dunia fantasi malam -> Call Method _mulai_dialog
##                        (dialog penutup Pak Guyon via Dialogic).
##   Dialog selesai -> mainkan klip "act8".
##   ACT 8 (klip "act8"): Pak Guyon tidur -> kilat putih -> _tukar_dunia (ke kamar
##                        mandi pagi + protagonis senyum) -> tahan -> _ke_credits.
##
## Protagonis TIDAK bicara. Pak Guyon playful. Tone: senyum, bukan sedih.
extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var fade: ColorRect = $FadeOverlay
@onready var bg_fantasy: PlaceholderBox = $BgFantasy
@onready var pak_guyon: PlaceholderBox = $PakGuyon
@onready var bg_real: PlaceholderBox = $BgReal
@onready var protagonist: PlaceholderBox = $Protagonist

var _lanjut := false

# Dialog ACT 7 (semua Pak Guyon). ⚠️ TANPA pola "Nama: teks" (Dialogic crash).
var ACT7_LINES := PackedStringArray([
	"Seru ya hari ini, ngger. Kayak dulu pas lo bocah, main lama-lama sampe ibumu marah.",
	"Lo udah lupa gimana rasanya ya?",
	"Tapi sekarang inget lagi.",
	"Yo wis. Gua tidur dulu ya, nak. Lo juga tidur ya. Besok bangun, jangan kepleset lagi. Hahaha.",
])


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
func _mulai_dialog() -> void:
	var tl := DialogicTimeline.new()
	tl.from_text("\n".join(ACT7_LINES))
	Dialogic.start(tl)


func _on_act7_done() -> void:
	if _lanjut:  # jaga-jaga dari sinyal ganda
		return
	_lanjut = true
	anim.play("act8")


## Call Method track (akhir klip act8): lanjut ke credits.
func _ke_credits() -> void:
	SceneManager.change_to("res://scenes/chapters/credits.tscn")
