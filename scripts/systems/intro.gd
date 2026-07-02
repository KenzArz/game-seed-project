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
## Aturan: Protagonis tidak pernah bicara. Pak Guyon playful. Dialog TIDAK boleh
## pakai pola "Nama: teks" (Dialogic bisa crash); pakai kurung "(Pak Guyon ...)".
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

# Dialog ACT 1 (semua Pak Guyon, protagonis diam). Kata clue tutorial diwarnai emas.
var INTRO_LINES := PackedStringArray([
	"Aduh! Lo terjun ya? Hampir gua jatoh dari tangan lo!",
	"...lho. Lo balik juga, akhirnya.",
	"Duduk dulu, ngger. Jangan kepleset lagi. Hahaha.",
	"Astaga. Lo udah jadi bapak-bapak ya sekarang. Padahal terakhir gua liat lo masih mandi pake busa di kepala kayak mahkota.",
	"Lo masih inget gua, kan?",
	"...gak inget juga gapapa. Maklum, gua plastik tua. PVC zaman Pak Harto. Tapi gua dulu PREMIUM, lho. Rp 7.500. Mahal.",
	"Pisang emas dibawa berlayar... ah, lupa lagi.",
	"Yo wis. Sekarang gua bantuin lo sebentar. Ada beberapa temen yang mau mampir mandi. Lo bantuin gua, gua bantuin lo. Mau?",
	"Mantep. Tuh, di rak ada [color=#C9A84C]bahan-bahan[/color]. Ambil aja yang lo mau. [color=#C9A84C]Tumbuk, tuang lewat gua, aduk[/color]. Itu aja.",
	"Kalo bingung, coba aja. Gak ada salah di sini. Customer pertama bentar lagi nih.",
])


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
	var tl := DialogicTimeline.new()
	tl.from_text("\n".join(INTRO_LINES))
	Dialogic.start(tl)


func _on_dialogue_done() -> void:
	if _sudah_lanjut:  # jaga-jaga dari sinyal ganda
		return
	_sudah_lanjut = true
	var data := SaveManager.load_data()
	data["seen_intro"] = true
	SaveManager.save(data)
	SceneManager.change_to("res://scenes/chapters/level1.tscn")
