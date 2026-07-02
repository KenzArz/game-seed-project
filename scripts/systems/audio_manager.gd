## AUTOLOAD `AudioManager` (autoload SCENE) — satu pintu untuk semua audio.
##   BGM (loop) diputar di bus "BGM", SFX (pool 6 player) di bus "SFX".
##
## SLOT AUDIO DIISI DI EDITOR: buka scenes/systems/audio_manager.tscn -> pilih node
## root "AudioManager" -> Inspector -> drop file audio ke slot BGM/SFX yang sesuai.
## Kalau slot masih kosong (belum ada file), pemanggilan AMAN: tidak bunyi & tidak
## error. Volume otomatis ikut bus (diatur SettingsManager / layar Pengaturan).
##
## Pemakaian dari mana pun:
##   AudioManager.play_bgm("gameplay")   # menu / intro / gameplay / ending
##   AudioManager.play_sfx("tumbuk")     # lihat daftar key SFX di bawah
extends Node

@export_group("BGM (loop)")
@export var bgm_menu: AudioStream
@export var bgm_intro: AudioStream
@export var bgm_gameplay: AudioStream
@export var bgm_ending: AudioStream

@export_group("SFX")
@export var sfx_button: AudioStream      ## klik tombol menu
@export var sfx_drag_bahan: AudioStream  ## ambil/seret bahan
@export var sfx_tumbuk: AudioStream      ## menumbuk di ulekan
@export var sfx_bubuk_jadi: AudioStream  ## bubuk selesai
@export var sfx_klik_gayung: AudioStream ## klik gayung (ke mengaduk)
@export var sfx_aduk: AudioStream        ## mengaduk
@export var sfx_sajikan: AudioStream     ## sajikan
@export var sfx_transisi: AudioStream    ## transisi antar scene

@onready var _bgm: AudioStreamPlayer = $BgmPlayer
@onready var _sfx_pool: Array = [$Sfx1, $Sfx2, $Sfx3, $Sfx4, $Sfx5, $Sfx6]

var _bgm_map := {}
var _sfx_map := {}
var _pending_bgm: AudioStream


func _ready() -> void:
	_bgm_map = {
		"menu": bgm_menu, "intro": bgm_intro,
		"gameplay": bgm_gameplay, "ending": bgm_ending,
	}
	_sfx_map = {
		"button": sfx_button, "drag": sfx_drag_bahan, "tumbuk": sfx_tumbuk,
		"bubuk": sfx_bubuk_jadi, "gayung": sfx_klik_gayung, "aduk": sfx_aduk,
		"sajikan": sfx_sajikan, "transisi": sfx_transisi,
	}


## Ganti BGM dengan crossfade. key: "menu"/"intro"/"gameplay"/"ending".
## Kalau slot kosong -> biarkan lagu yang sedang main. Kalau lagu sama -> tidak restart.
func play_bgm(key: String, fade := 0.8) -> void:
	var s: AudioStream = _bgm_map.get(key, null)
	if s == null or (_bgm.stream == s and _bgm.playing):
		return
	_pending_bgm = s
	var t := create_tween()
	if _bgm.playing:
		t.tween_property(_bgm, "volume_db", -40.0, fade * 0.5)
	t.tween_callback(_swap_bgm)
	t.tween_property(_bgm, "volume_db", 0.0, fade * 0.5)


func stop_bgm(fade := 0.6) -> void:
	if not _bgm.playing:
		return
	var t := create_tween()
	t.tween_property(_bgm, "volume_db", -40.0, fade)
	t.tween_callback(_bgm.stop)


## Mainkan 1 SFX. Lihat key di _sfx_map (button/drag/tumbuk/bubuk/gayung/aduk/sajikan/transisi).
func play_sfx(key: String) -> void:
	var s: AudioStream = _sfx_map.get(key, null)
	if s == null:
		return
	for p: AudioStreamPlayer in _sfx_pool:
		if not p.playing:
			p.stream = s
			p.play()
			return
	# semua pool sibuk -> pakai player pertama (steal).
	_sfx_pool[0].stream = s
	_sfx_pool[0].play()


func _swap_bgm() -> void:
	_bgm.stream = _pending_bgm
	_bgm.volume_db = -40.0
	_bgm.play()
