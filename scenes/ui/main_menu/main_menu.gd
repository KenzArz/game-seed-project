extends Control

@onready var menu = $menu
@onready var pengaturan = $pengaturan

func _ready():
	menu.visible = true
	pengaturan.visible = false

func _on_mulai_pressed():
	get_tree().change_scene_to_file("res://scenes/chapters/level1.tscn")

func _on_pengaturan_pressed():
	menu.visible = false
	pengaturan.visible = true

func _on_keluar_pressed():
	get_tree().quit()
