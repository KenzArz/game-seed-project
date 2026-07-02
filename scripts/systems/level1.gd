## KOORDINATOR / STAGE — alur meracik BARU, digerakkan ANTREAN PELANGGAN.
## Satu ruangan (bukan split Coffee Talk): customer muncul di jendela, bahan di
## rak, tumbuk di ulekan, tuang bubuk ke gayung, lalu aduk di stir panel.
##
## Siklus per pelanggan:
##   customer FADE IN + dialog INTRO
##     -> CRAFTING: drag bahan -> ulekan (tumbuk naik-turun) -> bubuk
##        -> drag bubuk -> gayung (menumpuk) -> KLIK gayung
##     -> STIR (full-screen, dipertahankan) -> sajikan
##     -> dialog REAKSI (sesuai resep) -> customer FADE OUT -> pelanggan berikutnya
##   Antrean habis -> DONE.
##
## Layout dibuat di EDITOR (level1.tscn + sub-scene). Script = logika saja.
extends Control

enum Phase { INTRO, CRAFTING, STIR, CLOSING, DONE }

const DUR := 0.35

# Instruksi tutorial (suara Pak Guyon), muncul kontekstual & HANYA sekali (playthrough
# pertama; disimpan lewat flag "tutorial_done" di save).
const HINT_RAK := "Ambil bahan di rak, seret ke ulekan."
const HINT_TUMBUK := "Tumbuk pakai alat ulek: gerakkan naik-turun sampai jadi butir."
const HINT_GAYUNG := "Butirnya jadi! Seret ke gayung."
const HINT_KLIK := "Klik gayung buat mengaduk jadi ramuan."

## Urutan level. Kosongkan untuk memuat semua .tres di res://resources/customers/.
@export var customers: Array[CustomerData] = []

@onready var background: PlaceholderBox = $Background
@onready var customer_window: CustomerWindow = $CustomerWindow
@onready var ulekan: Ulekan = $Ulekan
@onready var gayung: GayungStation = $Gayung
@onready var bubuk: DraggableItem = $Bubuk
@onready var stir_panel: StirPanel = $StirCanvas/StirPanel
@onready var pak_guyon: PlaceholderBox = $PakGuyon
@onready var debug_label: Label = $DebugCanvas/DebugLabel
@onready var hint: Control = $Hint
@onready var hint_label: Label = $Hint/Text

var phase: int = Phase.INTRO
var sedang_transisi := false
var _customer_index := 0
var _end_label: Label
var _default_bg_texture: Texture2D
var _default_bg_color: Color
var _racikan_terakhir: Array = []       # id bahan di gayung saat disajikan
var _bahan_items: Array = []            # semua DraggableItem bahan (grup "bahan")
var _tex_bahan := {}                    # id -> texture bahan (buat visual isi)
var _bubuk_ids: Array = []              # id bahan yang terkandung di bubuk hasil ulek
var _tutorial := false                  # true = playthrough pertama, tampilkan hint
var _gayung_hoverable := false          # hover gayung baru aktif setelah serbuk masuk


func _ready() -> void:
	GameState.set_state(GameState.State.CRAFTING)
	AudioManager.play_bgm("gameplay")

	if customers.is_empty():
		customers = _load_default_customers()

	# Kumpulkan bahan dari rak (grup "bahan"), sambungkan sinyal drop & angkat-nya.
	_bahan_items = get_tree().get_nodes_in_group("bahan")
	for item: DraggableItem in _bahan_items:
		item.dropped.connect(_on_bahan_dropped)
		item.picked_up.connect(_on_item_diangkat)
		_tex_bahan[item.id] = item.texture

	bubuk.dropped.connect(_on_bubuk_dropped)
	bubuk.picked_up.connect(_on_item_diangkat)
	bubuk.visible = false

	ulekan.selesai_menumbuk.connect(_on_selesai_menumbuk)
	gayung.minta_stir.connect(_on_minta_stir)
	stir_panel.serve_requested.connect(_on_serve)

	Dialogic.timeline_ended.connect(_on_dialogue_done)
	if Dialogic.has_subsystem("Text"):
		Dialogic.Text.about_to_show_text.connect(_on_dialogic_line)

	pak_guyon.modulate.a = 0.0
	stir_panel.place_off(CraftPanel.Dir.TOP)

	if background:
		_default_bg_texture = background.texture
		_default_bg_color = background.box_color

	_build_end_label()

	# Wire cursor hover for all interactive elements.
	_wire_cursor_hover()

	# Mulai dari pelanggan tersimpan (fitur Lanjutkan).
	var data := SaveManager.load_data()
	_customer_index = int(data.get("customer_index", 0))
	if _customer_index < 0 or _customer_index >= customers.size():
		_customer_index = 0
	# Tutorial cuma di playthrough pertama (belum pernah selesai sekali pun).
	_tutorial = not bool(data.get("tutorial_done", false))
	if hint:
		hint.visible = false
	_start_customer(_customer_index)


func _process(_delta: float) -> void:
	var nama := "-"
	if _customer_index < customers.size():
		nama = customers[_customer_index].display_name
	debug_label.text = "CUSTOMER: %s (%d/%d)\nPHASE: %s\nULEKAN: %s\nGAYUNG: %s\nTRANSISI: %s" % [
		nama,
		mini(_customer_index + 1, customers.size()),
		customers.size(),
		Phase.keys()[phase],
		str(ulekan.ada_isi()),
		str(gayung.isi_ids()),
		str(sedang_transisi),
	]


# --- Siklus hidup pelanggan --------------------------------------------------

func _start_customer(index: int) -> void:
	var pelanggan := customers[index]
	customer_window.set_customer(pelanggan.display_name, pelanggan.npc_color, pelanggan.npc_texture)
	customer_window.set_hidden_instant()
	customer_window.fade_in(DUR)
	_apply_background(pelanggan)
	_set_bahan_tersedia(pelanggan.available_ingredients)  # unlock cerita
	_reset_station()
	_set_craft_enabled(false)  # crafting dibuka setelah dialog intro
	phase = Phase.INTRO
	_play_dialogue(pelanggan.intro_timeline, pelanggan.intro_lines)


func _reset_station() -> void:
	ulekan.kosong()
	gayung.kosong()
	bubuk.visible = false
	_bubuk_ids.clear()
	_gayung_hoverable = false  # reset: gayung belum berisi serbuk
	for item: DraggableItem in _bahan_items:
		item.return_home()


# Tampilkan hanya bahan yang tersedia untuk pelanggan ini (kosong = semua).
func _set_bahan_tersedia(ids: PackedStringArray) -> void:
	for item: DraggableItem in _bahan_items:
		item.visible = ids.is_empty() or ids.has(item.id)


# Aktif/nonaktifkan interaksi meracik (drag bahan, tumbuk, klik gayung).
func _set_craft_enabled(on: bool) -> void:
	ulekan.aktif = on
	gayung.aktif = on
	for item: DraggableItem in _bahan_items:
		item.drag_enabled = on
	bubuk.drag_enabled = on


# Setelah dialog closing: fade-out customer, datangkan pelanggan berikutnya.
func _advance_customer() -> void:
	sedang_transisi = true
	customer_window.fade_out(DUR)
	await get_tree().create_timer(DUR).timeout

	_customer_index += 1
	if _customer_index >= customers.size():
		SaveManager.clear()  # tamat
		_show_end()
		sedang_transisi = false
		return

	# Merge ke save yang ada (JANGAN nimpa) supaya field lain seperti tutorial_done
	# tidak ikut terhapus.
	var d := SaveManager.load_data()
	d["has_save"] = true
	d["seen_intro"] = true
	d["customer_index"] = _customer_index
	SaveManager.save(d)
	sedang_transisi = false
	_start_customer(_customer_index)


# --- Interaksi meracik -------------------------------------------------------

# Bahan dilepas: kalau pas di atas ulekan & ulekan kosong -> isi. Bahan = sumber
# tak habis, jadi selalu balik ke rak.
func _on_bahan_dropped(item: DraggableItem) -> void:
	CursorManager.set_cursor(CursorManager.Cursor.DEFAULT)
	if phase == Phase.CRAFTING:
		var titik := item.get_global_rect().get_center()
		if ulekan.atas_mangkuk(titik):
			var slot := ulekan.slot_terdekat(titik)  # masuk ke slot tempat di-drop
			if ulekan.boleh_isi_slot(slot):
				ulekan.isi_slot(slot, item.id, item.texture)
				if ulekan.jumlah() == 2:
					_show_hint(HINT_TUMBUK)  # 2 bahan masuk -> instruksi menumbuk
	item.return_home()  # bahan = sumber tak habis, selalu balik ke rak


# Item (bahan/bubuk) diangkat -> cursor jadi mode grab bahan.
func _on_item_diangkat(_item: DraggableItem) -> void:
	AudioManager.play_sfx("drag")
	CursorManager.set_cursor(CursorManager.Cursor.DRAG_BAHAN)


func _on_selesai_menumbuk(ids: Array) -> void:
	_bubuk_ids = ids
	bubuk.return_home()
	bubuk.visible = true
	bubuk.drag_enabled = true
	AudioManager.play_sfx("bubuk")
	_show_hint(HINT_GAYUNG)  # butir jadi -> ajari seret ke gayung


# Bubuk dilepas: kalau pas di atas gayung -> semua bahannya masuk gayung. Kalau
# tidak, balik ke tempatnya.
func _on_bubuk_dropped(item: DraggableItem) -> void:
	CursorManager.set_cursor(CursorManager.Cursor.DEFAULT)
	if phase == Phase.CRAFTING and _di_atas(item, gayung):
		for id: String in _bubuk_ids:
			gayung.tambah_bubuk(id, item.texture)
		_bubuk_ids.clear()
		item.visible = false  # bubuk habis dipakai
		_gayung_hoverable = true  # serbuk masuk -> gayung sekarang bisa di-hover/klik
		_show_hint(HINT_KLIK)  # bubuk masuk gayung -> ajari klik untuk mengaduk
	else:
		item.return_home()


# Gayung diklik (sudah ada isi) -> masuk stir panel.
func _on_minta_stir() -> void:
	if phase != Phase.CRAFTING or sedang_transisi:
		return
	AudioManager.play_sfx("gayung")
	_gayung_hoverable = false  # sudah masuk stir; matikan hover gayung
	CursorManager.set_cursor(CursorManager.Cursor.DEFAULT)
	_selesai_tutorial()  # sampai sini = pemain sudah paham; matikan hint selamanya
	sedang_transisi = true
	phase = Phase.STIR
	_racikan_terakhir = gayung.isi_ids()
	_set_craft_enabled(false)
	stir_panel.reset_stir()
	stir_panel.slide_in(CraftPanel.Dir.TOP, DUR)
	await get_tree().create_timer(DUR).timeout
	sedang_transisi = false


# Selesai mengaduk -> dialog reaksi sesuai resep.
func _on_serve() -> void:
	if phase != Phase.STIR:
		return
	AudioManager.play_sfx("sajikan")
	sedang_transisi = true
	phase = Phase.CLOSING
	stir_panel.slide_out(CraftPanel.Dir.TOP, DUR)
	await get_tree().create_timer(DUR).timeout
	gayung.kosong()
	sedang_transisi = false
	var pelanggan := customers[_customer_index]
	_play_dialogue(null, _pick_reaction(pelanggan, _racikan_terakhir))


# Apakah pusat `item` berada di dalam rect global `target`.
func _di_atas(item: Control, target: Control) -> bool:
	return target.get_global_rect().has_point(item.get_global_rect().get_center())


# --- Dialog ------------------------------------------------------------------

func _on_dialogue_done() -> void:
	_fade_pak_guyon(0.0)
	if sedang_transisi:
		return
	match phase:
		Phase.INTRO:
			phase = Phase.CRAFTING
			_set_craft_enabled(true)  # buka meracik
			_show_hint(HINT_RAK)  # langkah pertama tutorial
		Phase.CLOSING:
			_advance_customer()


# Pop-up Pak Guyon muncul HANYA saat baris dialog miliknya (diawali "(Pak Guyon").
func _on_dialogic_line(info: Dictionary) -> void:
	var teks: String = info.get("text", "")
	_fade_pak_guyon(1.0 if teks.contains("(Pak Guyon") else 0.0)


func _fade_pak_guyon(target_a: float) -> void:
	if pak_guyon == null:
		return
	var t := create_tween()
	t.tween_property(pak_guyon, "modulate:a", target_a, 0.25)


# --- Tutorial hint (kontekstual, non-blocking, sekali seumur save) ------------

func _show_hint(teks: String) -> void:
	if not _tutorial or hint == null:
		return
	hint_label.text = teks
	hint.visible = true
	hint.modulate.a = 0.0
	create_tween().tween_property(hint, "modulate:a", 1.0, 0.25)


func _hide_hint() -> void:
	if hint == null:
		return
	var t := create_tween()
	t.tween_property(hint, "modulate:a", 0.0, 0.2)
	t.tween_callback(func() -> void: hint.visible = false)


# Pemain sudah menyelesaikan alur sekali -> matikan tutorial & simpan supaya tidak
# muncul lagi di sesi/pelanggan berikutnya.
func _selesai_tutorial() -> void:
	if not _tutorial:
		return
	_tutorial = false
	_hide_hint()
	var d := SaveManager.load_data()
	d["tutorial_done"] = true
	SaveManager.save(d)


func _play_dialogue(timeline_res: DialogicTimeline, baris: PackedStringArray) -> void:
	var tl: DialogicTimeline = timeline_res
	if tl == null:
		tl = DialogicTimeline.new()
		tl.from_text("\n".join(baris))
	Dialogic.start(tl)


func _apply_background(pelanggan: CustomerData) -> void:
	if not background:
		return
	if pelanggan.background_texture != null:
		background.texture = pelanggan.background_texture
		background.box_color = pelanggan.background_color
	else:
		background.texture = _default_bg_texture
		background.box_color = _default_bg_color


# --- Pencocokan resep (dipertahankan) ----------------------------------------

## 2 = pas (semua bahan resep & tanpa tambahan), 1 = sebagian, 0 = salah.
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


func _pick_reaction(pelanggan: CustomerData, racikan: Array) -> PackedStringArray:
	var baris: PackedStringArray
	match _match_tier(pelanggan, racikan):
		2: baris = pelanggan.react_perfect
		1: baris = pelanggan.react_partial
		_: baris = pelanggan.react_wrong
	if baris.is_empty():
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
	_set_craft_enabled(false)
	# Antrean habis -> lanjut ke ending sinematik (ACT 7-9).
	SceneManager.change_to("res://scenes/chapters/ending.tscn")


# --- Data level default ------------------------------------------------------

func _load_default_customers() -> Array[CustomerData]:
	const DIR := "res://resources/customers/"
	var arr: Array[CustomerData] = []
	var files := DirAccess.get_files_at(DIR)
	files.sort()
	for f in files:
		var fname := f.trim_suffix(".remap")
		if not (fname.ends_with(".tres") or fname.ends_with(".res")):
			continue
		var r := load(DIR + fname)
		if r is CustomerData:
			arr.append(r)
	if arr.is_empty():
		arr.append(_fallback_customer())
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


# --- Cursor wiring -----------------------------------------------------------

func _wire_cursor_hover() -> void:
	# Wire bahan items (draggable).
	for node in get_tree().get_nodes_in_group("bahan"):
		if node is Control:
			CursorManager.connect_hover(node)

	# Wire ulekan.
	if ulekan and ulekan is Control:
		CursorManager.connect_hover(ulekan)

	# Wire alat ulek (pestle) — biar hover ketauan alatnya bisa di-drag.
	var alat := ulekan.get_node_or_null("Alat")
	if alat and alat is Control:
		CursorManager.connect_hover(alat)

	# Wire bubuk/serbuk hasil tumbuk — biar ada hover juga (nandain bisa di-drag).
	if bubuk and bubuk is Control:
		CursorManager.connect_hover(bubuk)

	# Gayung: hover DI-GATE lewat _gayung_hoverable — baru aktif setelah serbuk
	# masuk gayung (hint bahwa gayung bisa diklik untuk mengaduk).
	if gayung and gayung is Control:
		gayung.mouse_entered.connect(_on_gayung_hover_enter)
		gayung.mouse_exited.connect(_on_gayung_hover_exit)

	# Wire suhu toggle: pasang di tombolnya (Btn), bukan container, biar hover kena.
	var suhu_btn := $SuhuToggle.get_node_or_null("Btn")
	if suhu_btn and suhu_btn is Control:
		CursorManager.connect_hover(suhu_btn)

	# Wire customer window (if clickable).
	if customer_window and customer_window is Control:
		CursorManager.connect_hover(customer_window)


# Gayung hover hanya berlaku saat serbuk sudah ada di gayung (siap diaduk).
func _on_gayung_hover_enter() -> void:
	if _gayung_hoverable:
		CursorManager.set_cursor(CursorManager.Cursor.HOVER)


func _on_gayung_hover_exit() -> void:
	if _gayung_hoverable:
		CursorManager.set_cursor(CursorManager.Cursor.DEFAULT)
