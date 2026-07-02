extends Control

# Joke random Pak Guyon (easter egg klik gayung). TANPA pola "Nama:".
const JOKES := [
	"Gua dulu PREMIUM, lho. Rp 7.500. Mahal.",
	"Pisang emas dibawa berlayar... ah, lupa lagi.",
	"Lo pernah liat gayung yang ngomong? Gak pernah, kan? Soalnya yang lain malu.",
	"Maklum, plastik tua. PVC zaman Pak Harto.",
]

@onready var menu = $menu
@onready var pengaturan = $pengaturan
@onready var lanjutkan_btn: Button = $menu/PanelContainer/VBoxContainer/lanjutkan
@onready var _gayung: Sprite2D = $menu/PanelContainer/VBoxContainer/PakGuyonGayung
@onready var _bubble: Control = $menu/GayungBubble
@onready var _bubble_text: Label = $menu/GayungBubble/Text

var _bubble_tween: Tween

func _ready():
	randomize()  # untuk joke acak easter egg
	GameState.set_state(GameState.State.TITLE)
	menu.visible = true
	pengaturan.visible = false
	_bubble.visible = false
	# Tombol Lanjutkan aktif hanya kalau ada progres tersimpan.
	lanjutkan_btn.disabled = not SaveManager.has_save()
	AudioManager.play_bgm("menu")

func _on_mulai_pressed():
	AudioManager.play_sfx("button")
	# Game baru: reset save, lalu mainkan intro (transisi fade via SceneManager).
	SaveManager.clear()
	SceneManager.change_to("res://scenes/chapters/intro.tscn")

func _on_lanjutkan_pressed():
	if not SaveManager.has_save():
		return
	AudioManager.play_sfx("button")
	# Lanjutkan: langsung ke gameplay; level1 mulai dari customer_index tersimpan.
	SceneManager.change_to("res://scenes/chapters/level1.tscn")

func _on_pengaturan_pressed():
	AudioManager.play_sfx("button")
	menu.visible = false
	pengaturan.visible = true

func _on_kredit_pressed():
	AudioManager.play_sfx("button")
	# Kredit: ke layar credits (sama seperti ACT 9, tanpa sinematik ending).
	SceneManager.change_to("res://scenes/chapters/credits.tscn")

func _on_keluar_pressed():
	AudioManager.play_sfx("button")
	get_tree().quit()

# Easter egg: klik gambar gayung -> Pak Guyon nyeletuk 1 baris acak.
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _gayung != null and _gayung.get_rect().has_point(_gayung.to_local(event.position)):
			_gayung_nyeletuk()

func _gayung_nyeletuk():
	_bubble_text.text = JOKES[randi() % JOKES.size()]
	_bubble.visible = true
	_bubble.modulate.a = 1.0
	if _bubble_tween != null and _bubble_tween.is_valid():
		_bubble_tween.kill()
	_bubble_tween = create_tween()
	_bubble_tween.tween_interval(2.6)
	_bubble_tween.tween_property(_bubble, "modulate:a", 0.0, 0.6)
	_bubble_tween.tween_callback(func(): _bubble.visible = false)
