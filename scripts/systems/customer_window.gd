## JENDELA CUSTOMER — teknik SANDWICH supaya customer tampak DI BALIK jendela,
## bukan ditempel di depan. Urutan layer (belakang -> depan):
##   WindowBack   -> pemandangan/kaca yang terlihat lewat jendela (mis. windowbg.png)
##   CustomerSprite -> karakter (texture dari CustomerData.npc_texture, di-fade)
##   WindowFrame  -> bingkai kaca (kacanya TRANSPARAN) di atas customer; OPSIONAL,
##                   isi kalau punya PNG bingkai. Kosong = tanpa bingkai depan.
##
## PENTING: texture customer TIDAK diisi di scene — otomatis dari .tres saat runtime.
## Root clip_contents = TRUE jadi customer yang kegedean kepotong di batas jendela.
class_name CustomerWindow
extends Control

@onready var _sprite: PlaceholderBox = $CustomerSprite


func _ready() -> void:
	clip_contents = true


## Ganti identitas customer (nama greybox, warna, gambar).
func set_customer(display_name: String, color: Color, texture: Texture2D) -> void:
	if _sprite == null:
		return
	_sprite.display_name = display_name
	_sprite.box_color = color
	_sprite.texture = texture
	_tata_sprite()


## Framing "orang di balik jendela": karakter di-skala MENUTUP jendela (COVER) lalu
## ditempel ATAS (kepala di batas atas jendela). Bagian bawah (badan/kaki) keluar
## dari jendela dan dipotong oleh clip_contents -> yang tampil cuma badan + muka.
## Kotak sprite dibuat pas rasio gambar jadi tak ada letterbox.
## Atur seberapa banyak yang tampil dengan mengubah TINGGI node CustomerWindow
## (jendela lebih pendek = kaki makin ketutupan).
func _tata_sprite() -> void:
	if _sprite == null or _sprite.texture == null:
		return
	var win := size
	if win.x <= 0.0 or win.y <= 0.0:  # layout belum siap -> coba lagi frame berikutnya
		call_deferred("_tata_sprite")
		return
	var ts: Vector2 = _sprite.texture.get_size()
	if ts.x <= 0.0 or ts.y <= 0.0:
		return
	var skala := maxf(win.x / ts.x, win.y / ts.y)  # cover: tutup jendela, tanpa celah
	var w := ts.x * skala
	var h := ts.y * skala
	_sprite.size = Vector2(w, h)
	_sprite.position = Vector2((win.x - w) * 0.5, 0.0)  # top-anchor: kepala di atas, bawah ke-clip


func set_hidden_instant() -> void:
	if _sprite:
		_sprite.modulate.a = 0.0


func fade_in(dur := 0.4) -> void:
	_tween_alpha(1.0, dur)


func fade_out(dur := 0.4) -> void:
	_tween_alpha(0.0, dur)


func _tween_alpha(target_a: float, dur: float) -> void:
	if _sprite == null:
		return
	var t := create_tween()
	t.tween_property(_sprite, "modulate:a", target_a, dur)
