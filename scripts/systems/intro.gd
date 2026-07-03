## INTRO / NOSTALGIA (scene sinematik pembuka).
##
## Koreografi visual (fade, zoom, crossfade, kilas nostalgia, kepleset, awaken)
## DIBUAT DI EDITOR lewat AnimationPlayer (klip "intro"), bukan tween di kode.
## Alasan: timing & kurva bisa diatur visual di panel Animation tanpa ubah script.
## Ini pola standar studio untuk cutscene di Godot.
##
## Script ini cuma logika tipis:
##   _ready(): pastikan node terlihat, set pivot yang tak dianimasikan, lalu play.
##   AnimationPlayer memanggil (via Call Method track):
##     _enter_fantasy()  saat layar tertutup kilat putih (tukar dunia nyata->fantasi)
##     _start_dialogue() di akhir klip (mulai dialog Pak Guyon)
##   Saat dialog selesai: tandai save + pindah ke level1.
##
## Dialog diambil dari res://resources/dialog/intro_scene.dtl (Dialogic timeline).
## Protagonis tidak pernah bicara. Semua dialog milik Pak Guyon.
extends Control

const OPENING_FOCUS := Vector2(1320, 540) # pusat zoom BG pembuka: Y tengah (lurus), X ke kanan

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var bg_opening: PlaceholderBox = $BgOpening
@onready var bg_real: PlaceholderBox = $BgRealBathroom
@onready var bg_fantasy: PlaceholderBox = $BgFantasy
@onready var gayung: PlaceholderBox = $Gayung
@onready var protagonist: PlaceholderBox = $Protagonist
@onready var pak_guyon: PlaceholderBox = $PakGuyon
@onready var fade_overlay: ColorRect = $FadeOverlay

var _sudah_lanjut := false


func _ready() -> void:
	GameState.set_state(GameState.State.DIALOG)
	AudioManager.play_bgm("intro")

	# Node yang dikendalikan animasi wajib terlihat saat runtime. (Menekan eye icon
	# di editor untuk preview tidak akan merusak jalannya intro.)
	for n: CanvasItem in [fade_overlay, bg_opening, bg_real, gayung, protagonist, pak_guyon]:
		n.visible = true

	# Pivot yang TIDAK dianimasikan, diset sekali di sini:
	#   BgOpening -> pusat zoom (tengah-agak-kanan)
	#   root Intro -> pusat oleng saat kepleset (tengah layar)
	#   PakGuyon  -> pusat scale saat awaken
	bg_opening.pivot_offset = OPENING_FOCUS
	pivot_offset = Vector2(960, 540)
	pak_guyon.pivot_offset = pak_guyon.size * 0.5

	Dialogic.timeline_ended.connect(_on_dialogue_done)
	anim.play("intro")


## Method track: dipanggil saat layar tertutup kilat putih. Tukar dunia nyata
## ke dunia fantasi di baliknya (tak terlihat karena tertutup putih).
func _enter_fantasy() -> void:
	bg_real.visible = false
	gayung.visible = false
	protagonist.visible = false
	bg_opening.visible = false
	bg_fantasy.modulate.a = 1.0


## Method track: dipanggil di akhir klip. Mulai dialog Pak Guyon lewat Dialogic.
func _start_dialogue() -> void:
	var tl: DialogicTimeline = load("res://resources/dialog/intro_scene.dtl")
	if tl == null:
		tl = DialogicTimeline.new()
		tl.from_text("\"Pak Guyon\": ...")
	Dialogic.start(tl)


func _on_dialogue_done() -> void:
	if _sudah_lanjut:  # jaga-jaga dari sinyal ganda
		return
	_sudah_lanjut = true
	var data := SaveManager.load_data()
	data["seen_intro"] = true
	SaveManager.save(data)
	SceneManager.change_to("res://scenes/chapters/level1.tscn")
