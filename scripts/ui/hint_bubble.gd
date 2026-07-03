## HintBubble — speech bubble statis yang melayang di atas customer.
## Tampil saat phase CRAFTING dimulai, hilang saat player serve.
## Ekor segitiga di bawah bubble mengarah ke customer di bawahnya.
extends Control

@onready var label: RichTextLabel = %Label

var _full_text: String = ""
var _tween: Tween


## Tampilkan bubble dengan teks BBCode.
## Teks muncul karakter per karakter seperti sedang diketik.
func show_hint(text: String) -> void:
	_full_text = text
	label.text = text
	label.visible_ratio = 0.0
	modulate.a = 0.0
	visible = true

	# Fade in bubble dulu
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.25)
	# Lalu ketik teks pelan-pelan
	_tween.tween_property(label, "visible_ratio", 1.0, _full_text.length() * 0.04).set_ease(Tween.EASE_IN)


## Sembunyikan bubble dengan fade out.
func hide_hint() -> void:
	if not visible:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	_tween.tween_callback(func() -> void: visible = false)
