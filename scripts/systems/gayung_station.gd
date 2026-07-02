## GAYUNG (ladle) di meja — teknik SANDWICH LAYER: bubuk tampil DI DALAM gayung
## karena digapit GayungBelakang dan GayungDepan.
##
## Layout di EDITOR (gayung_station.tscn), 3 layer (belakang->depan):
##   GayungBelakang -> GayungIsi (bubuk) -> GayungDepan
##
## Bubuk dari ulekan di-drag ke sini (koordinator memanggil tambah_bubuk).
## Setelah ada isi, KLIK gayung -> pindah ke stir panel (memancarkan minta_stir).
class_name GayungStation
extends Control

signal minta_stir

@onready var _isi: PlaceholderBox = $GayungIsi

var aktif := false
var _isi_ids: Array[String] = []


func _ready() -> void:
	if _isi:
		_isi.visible = false


## Tambah bubuk (dipanggil koordinator saat bubuk di-drop ke gayung).
func tambah_bubuk(id: String, texture: Texture2D) -> void:
	_isi_ids.append(id)
	if _isi:
		_isi.texture = texture
		_isi.visible = true


func kosong() -> void:
	_isi_ids.clear()
	if _isi:
		_isi.visible = false


func ada_isi() -> bool:
	return not _isi_ids.is_empty()


## Salinan daftar id bahan yang sudah masuk gayung (buat cocokkan resep).
func isi_ids() -> Array:
	return _isi_ids.duplicate()


func _gui_input(event: InputEvent) -> void:
	if not aktif:
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and (event as InputEventMouseButton).pressed:
		if not _isi_ids.is_empty():
			minta_stir.emit()
		accept_event()
