## AUTOLOAD `AudioManager` (autoload SCENE) — satu pintu untuk semua audio.
##   BGM (loop) diputar di bus "BGM", SFX (pool 6 player) di bus "SFX".
##
## Audio di-load langsung dari path di _ready(). Kalau file belum ada,
## pemanggilan AMAN: tidak bunyi dan tidak error.
##
## Pemakaian dari mana pun:
##   AudioManager.play_bgm("gameplay")   # menu / intro / gameplay / ending
##   AudioManager.play_sfx("tumbuk")     # lihat daftar key SFX di bawah
extends Node

@onready var _bgm: AudioStreamPlayer = $BgmPlayer
@onready var _sfx_pool: Array = [$Sfx1, $Sfx2, $Sfx3, $Sfx4, $Sfx5, $Sfx6]

var _bgm_map := {}
var _sfx_map := {}
var _pending_bgm: AudioStream


func _ready() -> void:
	# BGM — tambahkan path file di sini saat file audio tersedia
	_bgm_map = {
		"menu":     _load("res://assets/audio/bgm/menu.mp3"),
		"intro":    _load("res://assets/audio/bgm/intro.mp3"),
		"gameplay": _load("res://assets/audio/bgm/gameplay.mp3"),
		"ending":   _load("res://assets/audio/bgm/ending.mp3"),
	}
	# SFX — tambahkan path file di sini saat file audio tersedia
	_sfx_map = {
		"button":      _load("res://assets/audio/sfx/button.wav"),
		"drag":        _load("res://assets/audio/sfx/drag.wav"),
		"tumbuk":      _load("res://assets/audio/sfx/tumbuk.wav"),
		"bubuk":       _load("res://assets/audio/sfx/bubuk.wav"),
		"gayung":      _load("res://assets/audio/sfx/gayung.wav"),
		"aduk":        _load("res://assets/audio/sfx/aduk.wav"),
		"sajikan":     _load("res://assets/audio/sfx/sajikan.wav"),
		"transisi":    _load("res://assets/audio/sfx/transisi.wav"),
		"foot_steps":  _load("res://assets/audio/sfx/foot_steps.wav"),
	}

## Load helper — return null tanpa error kalau file belum ada.
func _load(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path)
	return null


const BGM_VOLUME_DB := -15.0  ## Volume normal BGM. Naikkan mendekati 0 untuk lebih keras.

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
	t.tween_property(_bgm, "volume_db", BGM_VOLUME_DB, fade * 0.5)


func stop_bgm(fade := 0.6) -> void:
	if not _bgm.playing:
		return
	var t := create_tween()
	t.tween_property(_bgm, "volume_db", -40.0, fade)
	t.tween_callback(_bgm.stop)


## Mainkan 1 SFX. Lihat key di _sfx_map (button/drag/tumbuk/bubuk/gayung/aduk/sajikan/transisi).
## Untuk tumbuk dan aduk: cek apakah sudah ada yang playing agar tidak overlap.
func play_sfx(key: String, allow_overlap := true) -> void:
	var s: AudioStream = _sfx_map.get(key, null)
	if s == null:
		return
	# Mode no-overlap: cari apakah stream ini sudah ada yang main
	if not allow_overlap:
		for p: AudioStreamPlayer in _sfx_pool:
			if p.playing and p.stream == s:
				return  # sudah main, skip
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
	# Aktifkan looping tergantung tipe stream
	if _pending_bgm is AudioStreamMP3:
		(_pending_bgm as AudioStreamMP3).loop = true
	elif _pending_bgm is AudioStreamWAV:
		(_pending_bgm as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif _pending_bgm is AudioStreamOggVorbis:
		(_pending_bgm as AudioStreamOggVorbis).loop = true
	_bgm.play()
