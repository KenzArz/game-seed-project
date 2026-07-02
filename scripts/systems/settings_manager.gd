## AUTOLOAD `SettingsManager` — pengaturan pemain (volume) yang PERSISTEN &
## diterapkan ke AudioServer. Disimpan di user://settings.cfg (ConfigFile),
## TERPISAH dari save progres (SaveManager) — praktik profesional: config bukan
## bagian dari progress. Dimuat + diterapkan otomatis saat startup.
##
## Volume disimpan 0..100 per bus audio (Master/BGM/SFX/Voice). Bus didefinisikan
## di default_bus_layout.tres.
extends Node

const PATH := "user://settings.cfg"
const BUSES := ["Master", "BGM", "SFX", "Voice"]

var _vol := {"Master": 100.0, "BGM": 100.0, "SFX": 100.0, "Voice": 100.0}


func _ready() -> void:
	load_settings()
	terapkan_semua()


func get_volume(bus: String) -> float:
	return _vol.get(bus, 100.0)


## Set + langsung terapkan (live). Simpan ke disk lewat save_settings().
func set_volume(bus: String, nilai: float) -> void:
	_vol[bus] = clampf(nilai, 0.0, 100.0)
	_terapkan(bus)


func terapkan_semua() -> void:
	for b in BUSES:
		_terapkan(b)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	for b in BUSES:
		cfg.set_value("volume", b, _vol[b])
	cfg.save(PATH)


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return  # belum ada / rusak -> pakai default
	for b in BUSES:
		_vol[b] = clampf(float(cfg.get_value("volume", b, _vol[b])), 0.0, 100.0)


# Terapkan 1 bus ke AudioServer. Aman kalau bus belum ada (dilewati).
func _terapkan(bus: String) -> void:
	var idx := AudioServer.get_bus_index(bus)
	if idx < 0:
		return
	var linear := get_volume(bus) / 100.0
	AudioServer.set_bus_mute(idx, linear <= 0.0)
	if linear > 0.0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(linear))
