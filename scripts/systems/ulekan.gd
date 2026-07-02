## ULEKAN (mortar) — MANGKUK (tempat bahan) + ALAT ULEK (pestle).
## Bisa menampung bahan di 3 slot (UlekanIsi1/2/3). Bahan masuk ke slot SESUAI
## tempat di-drop (slot terdekat), BUKAN berurutan.
##
## Cara menumbuk: grab ALAT lalu gerakkan NAIK-TURUN di atas mangkuk. Progres
## dihitung PER SLOT (hanya bahan yang tepat di bawah alat yang menyusut). Serbuk
## jadi kalau SEMUA bahan yang ada sudah halus.
class_name Ulekan
extends Control

signal selesai_menumbuk(ids: Array)

const GERAK_TARGET := 5    # gerakan tumbuk per bahan sampai halus
const SEG_MIN := 45.0      # jarak minimal 1 gerakan biar dihitung (px)
const SKALA_HALUS := 0.35  # skala akhir bahan saat sudah halus
const MARGIN_Y := 200.0    # toleransi Y: ayunan boleh overshoot keluar mangkuk

@onready var _mangkuk: Control = $Mangkuk
@onready var _alat = $Alat
@onready var _slots: Array = [$UlekanIsi1, $UlekanIsi2, $UlekanIsi3]

var aktif := false          # hanya bisa menumbuk saat fase crafting
var _slot_id := ["", "", ""]  # id bahan per slot ("" = kosong)
var _prog := [0, 0, 0]        # progres tumbuk per slot
var _arah := 0                # arah vertikal terakhir (-1 naik, 1 turun)
var _seg := 0.0               # jarak tempuh di segmen arah saat ini


func _ready() -> void:
	for s: PlaceholderBox in _slots:
		if s:
			s.visible = false
	if _alat:
		_alat.gerus.connect(_on_gerus)
		_alat.dilepas.connect(func() -> void: _alat.return_home())


## Apakah titik global ini di atas mangkuk (gate drop bahan & area menumbuk).
func atas_mangkuk(global_point: Vector2) -> bool:
	return _mangkuk != null and _mangkuk.get_global_rect().has_point(global_point)


## Slot yang PALING DEKAT ke titik (dipakai saat drop bahan). -1 kalau tak ada.
func slot_terdekat(global_point: Vector2) -> int:
	var best := -1
	var best_d := INF
	for i in range(_slots.size()):
		var s: PlaceholderBox = _slots[i]
		if s == null:
			continue
		var d := s.get_global_rect().get_center().distance_squared_to(global_point)
		if d < best_d:
			best_d = d
			best = i
	return best


## Boleh mengisi slot ini? (aktif & slot masih kosong)
func boleh_isi_slot(index: int) -> bool:
	return aktif and index >= 0 and index < _slots.size() and _slot_id[index] == ""


## Isi slot TERTENTU (sesuai tempat drop, bukan berurutan).
func isi_slot(index: int, id: String, texture: Texture2D) -> void:
	if index < 0 or index >= _slots.size() or _slot_id[index] != "":
		return
	_slot_id[index] = id
	_prog[index] = 0
	var s: PlaceholderBox = _slots[index]
	if s:
		s.texture = texture
		s.pivot_offset = s.size * 0.5
		s.scale = Vector2.ONE
		s.visible = true


func ada_isi() -> bool:
	for id in _slot_id:
		if id != "":
			return true
	return false


func jumlah() -> int:
	var n := 0
	for id in _slot_id:
		if id != "":
			n += 1
	return n


func kosong() -> void:
	for i in range(_slots.size()):
		_slot_id[i] = ""
		_prog[i] = 0
		var s: PlaceholderBox = _slots[i]
		if s:
			s.visible = false
			s.scale = Vector2.ONE
	_arah = 0
	_seg = 0.0
	if _alat:
		_alat.return_home()


# Alat digerakkan: progres PER SLOT (hanya slot terisi yang di bawah kolom alat).
func _on_gerus(dy: float, pusat_global: Vector2) -> void:
	if not aktif or not ada_isi():
		return
	# 1 "gerakan" = tiap arah vertikal berbalik setelah menempuh jarak minimal.
	var ada_gerakan := false
	if absf(dy) >= 0.5:
		var arah := 1 if dy > 0.0 else -1
		if arah == _arah:
			_seg += absf(dy)
		else:
			if _seg >= SEG_MIN:
				ada_gerakan = true
			_arah = arah
			_seg = absf(dy)
	if ada_gerakan:
		AudioManager.play_sfx("tumbuk")
	var mr := _mangkuk.get_global_rect() if _mangkuk != null else Rect2()
	for i in range(_slots.size()):
		if _slot_id[i] == "" or _prog[i] >= GERAK_TARGET:
			continue
		var s: PlaceholderBox = _slots[i]
		if s == null or not s.visible:
			continue
		var r := s.get_global_rect()
		if pusat_global.x < r.position.x or pusat_global.x > r.position.x + r.size.x:
			continue  # kursor tidak di kolom slot ini
		if _mangkuk != null and (pusat_global.y < mr.position.y - MARGIN_Y or pusat_global.y > mr.position.y + mr.size.y + MARGIN_Y):
			continue
		if ada_gerakan:
			_prog[i] = mini(_prog[i] + 1, GERAK_TARGET)
		_perbarui_slot(i, dy)
	if _semua_halus():
		var ids := _kumpulan_id()
		kosong()
		selesai_menumbuk.emit(ids)


# Efek "beneran ditumbuk" untuk 1 slot: menyusut sesuai progres + squash.
func _perbarui_slot(i: int, dy: float) -> void:
	var s: PlaceholderBox = _slots[i]
	var t := clampf(float(_prog[i]) / float(GERAK_TARGET), 0.0, 1.0)
	var dasar := lerpf(1.0, SKALA_HALUS, t)
	var squash := 0.0 if _prog[i] >= GERAK_TARGET else clampf(absf(dy) * 0.006, 0.0, 0.22)
	s.pivot_offset = s.size * 0.5
	s.scale = Vector2(dasar * (1.0 + squash), dasar * (1.0 - squash))


# Semua bahan yang ADA sudah halus? (true hanya kalau minimal ada 1 bahan)
func _semua_halus() -> bool:
	var ada := false
	for i in range(_slots.size()):
		if _slot_id[i] != "":
			ada = true
			if _prog[i] < GERAK_TARGET:
				return false
	return ada


func _kumpulan_id() -> Array:
	var arr := []
	for id in _slot_id:
		if id != "":
			arr.append(id)
	return arr
