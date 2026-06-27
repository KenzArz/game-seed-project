## FASE 2 — meja racik.
##
## LAYOUT dibuat di EDITOR (mixing_panel.tscn): frame, judul, 3 slot WADAH, dan
## tombol ULANGI/RACIK — semua node yang bisa kamu geser/edit visual.
##
## RAK 6 bahan TIDAK digambar manual — diisi lewat KODE dari file di
## res://resources/ingredients/ ke dalam node "Rack" (GridContainer) yang ada di
## editor. Ini pola standar untuk "daftar dari data": container-nya di editor,
## isinya di-generate. Geser/atur kolom & jarak rak langsung di Inspector.
class_name MixingPanel
extends CraftPanel

signal mix_requested(contents: Array)

const MAX_SLOTS := 3
const ItemBox := preload("res://scenes/ui/placeholder_box.tscn")

## Kosongkan → otomatis load semua bahan di res://resources/ingredients/.
@export var ingredients: Array[IngredientDef] = []

@onready var _rack: GridContainer = $Rack
@onready var _slots := [$Slot1, $Slot2, $Slot3]
@onready var _ulangi: Button = $Ulangi
@onready var _racik: Button = $Racik

var contents: Array[String] = []


func _build() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # area kiri (pelanggan) tembus klik
	if ingredients.is_empty():
		ingredients = _load_default_ingredients()
	_build_rack()
	for i in _slots.size():
		_slots[i].clicked.connect(_on_slot_clicked.bind(i))
	_ulangi.pressed.connect(_on_reset)
	_racik.pressed.connect(_on_mix)
	_refresh_slots()


# Isi GridContainer "Rack" dengan 1 kotak per bahan (dari data).
func _build_rack() -> void:
	for ing in ingredients:
		var b: PlaceholderBox = ItemBox.instantiate()
		b.custom_minimum_size = Vector2(220, 210)
		b.display_name = ing.display_name
		b.box_color = ing.placeholder_color
		b.texture = ing.texture
		_rack.add_child(b)
		b.clicked.connect(_on_ingredient_clicked.bind(ing, b))


func _on_ingredient_clicked(ing: IngredientDef, box: PlaceholderBox) -> void:
	if contents.size() >= MAX_SLOTS:
		box.flash_error()  # bahan ke-4 ditolak
		return
	contents.append(ing.id)
	box.pop()
	_refresh_slots()


func _on_slot_clicked(index: int) -> void:
	if index < contents.size():
		contents.remove_at(index)
		_refresh_slots()


func _on_reset() -> void:
	reset_station()


func _on_mix() -> void:
	if contents.is_empty():
		return
	mix_requested.emit(contents.duplicate())


func reset_station() -> void:
	contents.clear()
	_refresh_slots()


func _refresh_slots() -> void:
	for i in _slots.size():
		var box: PlaceholderBox = _slots[i]
		if i < contents.size():
			# Slot terisi: tampilkan gambar bahan kalau ada, kalau tidak nama-nya.
			var ing := _find_ingredient(contents[i])
			if ing and ing.texture:
				box.texture = ing.texture
			else:
				box.texture = null
				box.display_name = ing.display_name if ing else contents[i]
				box.box_color = Color(0.35, 0.5, 0.4)
		else:
			box.texture = null
			box.display_name = "WADAH %d" % (i + 1)
			box.box_color = Color(0.25, 0.24, 0.3)
	_racik.disabled = contents.is_empty()


func _find_ingredient(id: String) -> IngredientDef:
	for ing in ingredients:
		if ing.id == id:
			return ing
	return null


# Default: load semua .tres di folder bahan; fallback ke daftar kode kalau gagal.
func _load_default_ingredients() -> Array[IngredientDef]:
	var paths := [
		"res://resources/ingredients/01_sabun_batang.tres",
		"res://resources/ingredients/02_shampoo.tres",
		"res://resources/ingredients/03_pasta_gigi.tres",
		"res://resources/ingredients/04_bedak_bayi.tres",
		"res://resources/ingredients/05_daun_mint.tres",
		"res://resources/ingredients/06_garam_mandi.tres",
	]
	var arr: Array[IngredientDef] = []
	for p in paths:
		if ResourceLoader.exists(p):
			var r := load(p)
			if r is IngredientDef:
				arr.append(r)
	if arr.is_empty():
		arr = _hardcoded_ingredients()
	return arr


func _hardcoded_ingredients() -> Array[IngredientDef]:
	var data := [
		["sabun", "Sabun Batang", Color(0.85, 0.85, 0.70)],
		["shampo", "Shampoo", Color(0.50, 0.70, 0.90)],
		["pasta", "Pasta Gigi", Color(0.70, 0.90, 0.80)],
		["bedak", "Bedak Bayi", Color(0.95, 0.90, 0.92)],
		["mint", "Daun Mint", Color(0.50, 0.80, 0.50)],
		["garam", "Garam Mandi", Color(0.80, 0.80, 0.95)],
	]
	var arr: Array[IngredientDef] = []
	for d in data:
		var ing := IngredientDef.new()
		ing.id = d[0]
		ing.display_name = d[1]
		ing.placeholder_color = d[2]
		arr.append(ing)
	return arr
