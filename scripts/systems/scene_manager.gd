## AUTOLOAD `SceneManager` — transisi scene terpusat (fade hitam) + tumpukan
## overlay (Pengaturan/Pause di ATAS scene aktif tanpa menghancurkannya).
##
## Daftarkan di Project Settings -> Autoload sebagai `SceneManager`.
## Pemakaian:
##   SceneManager.change_to("res://scenes/chapters/level1.tscn")
##   var o := SceneManager.push_overlay(preload("res://.../pengaturan.tscn"))
##   SceneManager.pop_overlay()
extends Node

signal scene_changed(path: String)

var _fade: ColorRect
var _overlay_layer: CanvasLayer
var _overlays: Array[Node] = []
var _busy := false


func _ready() -> void:
	# Lapisan fade paling atas (di atas semua CanvasLayer game).
	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 128
	add_child(fade_layer)
	_fade = ColorRect.new()
	_fade.color = Color.BLACK
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.modulate.a = 0.0
	_fade.visible = false
	fade_layer.add_child(_fade)

	# Lapisan overlay: di atas scene, di bawah fade.
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 64
	add_child(_overlay_layer)


## Ganti scene dengan fade hitam: out -> change_scene -> in.
func change_to(scene_path: String, fade := 0.35) -> void:
	if _busy:
		return
	_busy = true
	AudioManager.play_sfx("transisi")
	await _fade_to(1.0, fade)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame  # biar scene baru sempat ter-load
	scene_changed.emit(scene_path)
	await _fade_to(0.0, fade)
	_busy = false


func _fade_to(target_a: float, dur: float) -> void:
	_fade.visible = true
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP  # blok input saat transisi
	var t := create_tween()
	t.tween_property(_fade, "modulate:a", target_a, dur)
	await t.finished
	if is_equal_approx(target_a, 0.0):
		_fade.visible = false
		_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Tampilkan overlay UI di atas scene aktif (scene bawah tetap hidup).
func push_overlay(scene: PackedScene) -> Node:
	var inst := scene.instantiate()
	_overlay_layer.add_child(inst)
	_overlays.append(inst)
	return inst


## Tutup overlay teratas.
func pop_overlay() -> void:
	if _overlays.is_empty():
		return
	var top: Node = _overlays.pop_back()
	if is_instance_valid(top):
		top.queue_free()


func overlay_count() -> int:
	return _overlays.size()


## Apakah node ini sedang jadi overlay (dipakai overlay agar tahu cara menutup diri).
func is_overlay(node: Node) -> bool:
	return node in _overlays
