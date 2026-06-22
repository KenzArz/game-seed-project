extends CanvasLayer

@onready var slider_master = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HSlider
@onready var slider_bgm    = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/HSlider
@onready var slider_sfx    = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer3/HSlider
@onready var slider_voice  = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer4/HSlider

@onready var label_master  = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/volumeMasterValue
@onready var label_bgm     = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/volumeMusikValue
@onready var label_sfx     = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer3/volumeSfxValue
@onready var label_voice   = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer4/volumeDialogValue

func _ready():
	slider_master.value_changed.connect(_on_master_changed)
	slider_bgm.value_changed.connect(_on_bgm_changed)
	slider_sfx.value_changed.connect(_on_sfx_changed)
	slider_voice.value_changed.connect(_on_voice_changed)

func _on_master_changed(value: float):
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100.0))
	label_master.text = str(int(value))

func _on_bgm_changed(value: float):
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(value / 100.0))
	label_bgm.text = str(int(value))

func _on_sfx_changed(value: float):
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))
	label_sfx.text = str(int(value))

func _on_voice_changed(value: float):
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), linear_to_db(value / 100.0))
	label_voice.text = str(int(value))

func _on_kembali_pressed():
	get_parent().get_node("menu").visible = true
	self.visible = false

func _on_simpan_pressed():
	get_parent().get_node("menu").visible = true
	self.visible = false
