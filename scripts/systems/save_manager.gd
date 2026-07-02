## AUTOLOAD `SaveManager` — save/continue sederhana ke user://busa_save.json.
## Menyimpan progres minimal: sudah lihat intro + indeks pelanggan aktif.
## Web export tetap jalan karena pakai user:// (browser storage), bukan path lokal.
## Daftarkan di Project Settings -> Autoload sebagai `SaveManager`.
extends Node

const PATH := "user://busa_save.json"


## Tulis Dictionary ke file save (overwrite).
func save(data: Dictionary) -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		push_warning("SaveManager: gagal membuka save untuk ditulis.")
		return
	f.store_string(JSON.stringify(data))
	f.close()


## Baca save; kalau belum ada / rusak, kembalikan default. Field yang hilang diisi
## default supaya penambahan field baru tidak bikin save lama error.
func load_data() -> Dictionary:
	var d := _default()
	if not FileAccess.file_exists(PATH):
		return d
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return d
	var txt := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		return d
	for k in parsed:
		d[k] = parsed[k]
	return d


func has_save() -> bool:
	return bool(load_data().get("has_save", false))


func clear() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)


func _default() -> Dictionary:
	return { "seen_intro": false, "customer_index": 0, "has_save": false }
