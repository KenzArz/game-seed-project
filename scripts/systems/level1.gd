## KOORDINATOR / STAGE — orkestrasi tipis untuk alur ala Coffee Talk, digerakkan
## oleh ANTREAN PELANGGAN. Scene meja racik dipakai ulang untuk tiap pelanggan;
## yang berubah per "level" adalah CustomerData (nama, portrait, dialog, latar).
## Untuk menambah level 2/3/..., tambahkan file CustomerData .tres — TIDAK perlu
## menyalin scene ini.
##
## Siklus per pelanggan:
##   dialog INTRO -> MIXING -> SERVING -> (STIR) -> sajikan
##     -> pelanggan geser balik ke tengah -> dialog CLOSING
##     -> pelanggan FADE OUT -> pelanggan berikutnya FADE IN (nama/aset baru) -> INTRO...
##   Saat antrean habis -> layar DONE.
##
## Arah transisi: menu racik/serve datang dari KANAN, pelanggan geser tengah<->kiri,
## minigame aduk turun full-screen dari ATAS.
extends Control

enum Phase { INTRO, MIXING, SERVING, STIR, CLOSING, DONE }

const DUR := 0.35

## Urutan level. Isi di Inspector dengan men-drag file CustomerData .tres; kalau
## dikosongkan, semua .tres di res://resources/customers/ dimuat otomatis.
@export var customers: Array[CustomerData] = []

@onready var background: PlaceholderBox = $Background
@onready var mixing_panel: MixingPanel = $MixingPanel
@onready var serve_panel: ServePanel = $ServePanel
@onready var customer_portrait: CustomerPortraitPanel = $CustomerPortraitPanel
@onready var stir_panel: StirPanel = $StirCanvas/StirPanel
@onready var debug_label: Label = $DebugCanvas/DebugLabel

var phase: int = Phase.INTRO
var sedang_transisi := false
var _customer_index := 0
var _end_label: Label
# Apa pun yang ada di node Background (Inspector) adalah default; pelanggan boleh
# menimpanya, tapi kalau pelanggan mengosongkannya kita pakai default ini.
var _default_bg_texture: Texture2D
var _default_bg_color: Color
var _racikan_terakhir: Array = []  # id bahan yang diracik player, buat pilih reaksi


func _ready() -> void:
	if customers.is_empty():
		customers = _load_default_customers()

	# Dialog dirender addon Dialogic. timeline_ended diemit tiap timeline (intro
	# atau closing) selesai; kita arahkan berdasarkan fase.
	Dialogic.timeline_ended.connect(_on_dialogue_done)
	mixing_panel.mix_requested.connect(_on_mix_requested)
	serve_panel.trash_requested.connect(_on_trash)
	serve_panel.serve_requested.connect(_on_serve)
	serve_panel.stir_requested.connect(_on_stir)
	stir_panel.serve_requested.connect(_on_serve)

	# Parkir menu-menu di luar layar; pelanggan tetap di layar (di tengah).
	mixing_panel.place_off(CraftPanel.Dir.RIGHT)
	serve_panel.place_off(CraftPanel.Dir.RIGHT)
	stir_panel.place_off(CraftPanel.Dir.TOP)
	customer_portrait.place_center()

	if background:
		_default_bg_texture = background.texture
		_default_bg_color = background.box_color

	_build_end_label()
	_customer_index = 0
	_start_customer(_customer_index)


func _process(_delta: float) -> void:
	var nama_pelanggan := "-"
	if _customer_index < customers.size():
		nama_pelanggan = customers[_customer_index].display_name
	debug_label.text = "CUSTOMER: %s (%d/%d)\nPHASE: %s\nINGREDIENTS: %s (%d/3)\nSTIR: %d/5\nTRANSITIONING: %s" % [
		nama_pelanggan,
		mini(_customer_index + 1, customers.size()),
		customers.size(),
		Phase.keys()[phase],
		str(mixing_panel.contents),
		mixing_panel.contents.size(),
		stir_panel.stir_count,
		str(sedang_transisi),
	]


# --- Siklus hidup pelanggan --------------------------------------------------

func _start_customer(index: int) -> void:
	var pelanggan := customers[index]
	customer_portrait.configure(pelanggan.display_name, pelanggan.npc_color, pelanggan.npc_texture)
	customer_portrait.set_center_instant()
	_apply_background(pelanggan)
	phase = Phase.INTRO
	_play_dialogue(pelanggan.intro_timeline, pelanggan.intro_lines)


## Mulai dialog lewat Dialogic. Kalau diberi resource timeline, dipakai apa adanya
## (fitur Dialogic penuh); kalau tidak, timeline dibangun dadakan dari baris teks
## biasa (tiap baris = 1 text event).
func _play_dialogue(timeline_res: DialogicTimeline, baris: PackedStringArray) -> void:
	var tl: DialogicTimeline = timeline_res
	if tl == null:
		tl = DialogicTimeline.new()
		tl.from_text("\n".join(baris))
	Dialogic.start(tl)


func _apply_background(pelanggan: CustomerData) -> void:
	if not background:
		return
	# Texture pelanggan menimpa default Inspector; kalau kosong, pakai default.
	if pelanggan.background_texture != null:
		background.texture = pelanggan.background_texture
		background.box_color = pelanggan.background_color
	else:
		background.texture = _default_bg_texture
		background.box_color = _default_bg_color


# Setelah dialog closing: fade-out pelanggan ini, datangkan pelanggan berikutnya.
func _advance_customer() -> void:
	sedang_transisi = true
	customer_portrait.fade_out(DUR)
	await get_tree().create_timer(DUR).timeout

	_customer_index += 1
	if _customer_index >= customers.size():
		_show_end()
		sedang_transisi = false
		return

	# Siapkan pelanggan berikutnya saat tersembunyi, lalu fade-in portrait barunya.
	var pelanggan := customers[_customer_index]
	customer_portrait.configure(pelanggan.display_name, pelanggan.npc_color, pelanggan.npc_texture)
	customer_portrait.set_center_instant()
	_apply_background(pelanggan)
	customer_portrait.fade_in(DUR)
	phase = Phase.INTRO
	await get_tree().create_timer(DUR).timeout
	sedang_transisi = false
	_play_dialogue(pelanggan.intro_timeline, pelanggan.intro_lines)


# --- Transisi antar fase -----------------------------------------------------

func _on_dialogue_done() -> void:
	if sedang_transisi:
		return
	match phase:
		Phase.INTRO:
			_go_to_mixing()
		Phase.CLOSING:
			_advance_customer()


# INTRO -> MIXING
func _go_to_mixing() -> void:
	sedang_transisi = true
	phase = Phase.MIXING
	# Pelanggan yang sama geser tengah -> kiri; menu racik masuk dari KANAN.
	customer_portrait.move_to_left(DUR)
	mixing_panel.slide_in(CraftPanel.Dir.RIGHT, DUR)
	await get_tree().create_timer(DUR).timeout
	sedang_transisi = false


# MIXING -> SERVING
func _on_mix_requested(racikan: Array) -> void:
	if sedang_transisi:
		return
	sedang_transisi = true
	phase = Phase.SERVING
	_racikan_terakhir = racikan.duplicate()  # ingat racikannya buat reaksi nanti
	mixing_panel.slide_out(CraftPanel.Dir.LEFT, DUR)
	serve_panel.set_result(_result_name(customers[_customer_index], _racikan_terakhir))
	serve_panel.slide_in(CraftPanel.Dir.RIGHT, DUR)
	await get_tree().create_timer(DUR).timeout
	sedang_transisi = false


# SERVING -> MIXING (buang)
func _on_trash() -> void:
	# Guard berbasis fase (bukan sedang_transisi) supaya klik tidak hilang saat
	# slide-in; fase berubah setelah aksi, mencegah trigger ganda.
	if phase != Phase.SERVING:
		return
	sedang_transisi = true
	phase = Phase.MIXING
	serve_panel.slide_out(CraftPanel.Dir.RIGHT, DUR)
	mixing_panel.reset_station()
	mixing_panel.slide_in(CraftPanel.Dir.RIGHT, DUR)
	await get_tree().create_timer(DUR).timeout
	sedang_transisi = false


# SERVING -> STIR (full-screen, dari atas)
func _on_stir() -> void:
	if phase != Phase.SERVING:
		return
	sedang_transisi = true
	phase = Phase.STIR
	stir_panel.reset_stir()
	stir_panel.slide_in(CraftPanel.Dir.TOP, DUR)
	await get_tree().create_timer(DUR).timeout
	sedang_transisi = false


# sajikan (dari layar serve atau stir) -> dialog CLOSING dengan pelanggan ini
func _on_serve() -> void:
	if phase != Phase.SERVING and phase != Phase.STIR:
		return
	sedang_transisi = true
	phase = Phase.CLOSING
	stir_panel.slide_out(CraftPanel.Dir.TOP, DUR)
	serve_panel.slide_out(CraftPanel.Dir.RIGHT, DUR)
	customer_portrait.move_to_center(DUR)  # pelanggan geser balik ke tengah buat ngobrol
	await get_tree().create_timer(DUR).timeout

	mixing_panel.reset_station()
	stir_panel.reset_stir()
	await get_tree().create_timer(DUR).timeout
	sedang_transisi = false
	# Pilih reaksi berdasarkan berapa bahan resep yang cocok (tanpa skor).
	var pelanggan := customers[_customer_index]
	_play_dialogue(null, _pick_reaction(pelanggan, _racikan_terakhir))


## Tingkat kecocokan racikan player vs resep pelanggan:
## 2 = pas (semua bahan resep & tanpa tambahan), 1 = sebagian (>=1 benar),
## 0 = salah (tidak ada yang benar). Dipakai untuk nama hasil DAN reaksi dialog.
func _match_tier(pelanggan: CustomerData, racikan: Array) -> int:
	var benar := 0
	for id_bahan in pelanggan.recipe:
		if racikan.has(id_bahan):
			benar += 1
	if pelanggan.recipe.is_empty() or (benar == pelanggan.recipe.size() and racikan.size() == pelanggan.recipe.size()):
		return 2
	elif benar >= 1:
		return 1
	return 0


## Nama busa yang tampil di layar serve, per tingkat kecocokan.
func _result_name(pelanggan: CustomerData, racikan: Array) -> String:
	match _match_tier(pelanggan, racikan):
		2: return pelanggan.result_perfect
		1: return pelanggan.result_partial
		_: return pelanggan.result_wrong


## Baris reaksi yang dimainkan setelah disajikan, per tingkat kecocokan.
func _pick_reaction(pelanggan: CustomerData, racikan: Array) -> PackedStringArray:
	var baris: PackedStringArray
	match _match_tier(pelanggan, racikan):
		2: baris = pelanggan.react_perfect
		1: baris = pelanggan.react_partial
		_: baris = pelanggan.react_wrong
	if baris.is_empty():  # jaring pengaman kalau satu tingkat dibiarkan kosong
		baris = PackedStringArray(["..."])
	return baris


# --- Layar selesai -----------------------------------------------------------

func _build_end_label() -> void:
	_end_label = Label.new()
	_end_label.text = "Semua pelanggan hari ini sudah dilayani! 🛁\nTerima kasih sudah bermain."
	_end_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_end_label.add_theme_font_size_override("font_size", 56)
	_end_label.visible = false
	add_child(_end_label)


func _show_end() -> void:
	phase = Phase.DONE
	if _end_label:
		_end_label.visible = true


# --- Data level default (dipakai saat export `customers` dikosongkan) ---------

## Memuat SEMUA CustomerData di res://resources/customers/, urut nama file (jadi
## 01_, 02_, 03_, ... menentukan urutan). Untuk menambah karakter cukup taruh
## file .tres baru di folder itu — tanpa edit kode/array.
func _load_default_customers() -> Array[CustomerData]:
	const DIR := "res://resources/customers/"
	var arr: Array[CustomerData] = []
	var files := DirAccess.get_files_at(DIR)
	files.sort()
	for f in files:
		var fname := f.trim_suffix(".remap")  # build hasil export menambah .remap
		if not (fname.ends_with(".tres") or fname.ends_with(".res")):
			continue
		var r := load(DIR + fname)
		if r is CustomerData:
			arr.append(r)
	if arr.is_empty():
		arr.append(_fallback_customer())  # jaring pengaman terakhir biar scene selalu jalan
	return arr


func _fallback_customer() -> CustomerData:
	var pelanggan := CustomerData.new()
	pelanggan.id = "default"
	pelanggan.display_name = "Tamu"
	pelanggan.intro_lines = PackedStringArray(["Halo! Coba racik sesuatu buat aku ya."])
	pelanggan.react_perfect = PackedStringArray(["Terima kasih!"])
	pelanggan.react_partial = PackedStringArray(["Terima kasih!"])
	pelanggan.react_wrong = PackedStringArray(["Terima kasih!"])
	return pelanggan
