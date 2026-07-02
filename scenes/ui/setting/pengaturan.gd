extends CanvasLayer

## Pola pengaturan profesional: PREVIEW LIVE + Simpan/Batal.
##  - Geser slider  -> langsung diterapkan (biar bisa didengar), TAPI belum disimpan.
##  - Simpan        -> tulis ke disk + feedback + tutup ke menu.
##  - Kembali (Batal)-> balikin ke nilai terakhir tersimpan + tutup.

@onready var slider_master = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HSlider
@onready var slider_bgm    = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/HSlider
@onready var slider_sfx    = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer3/HSlider
@onready var slider_voice  = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer4/HSlider

@onready var label_master  = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/volumeMasterValue
@onready var label_bgm     = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/volumeMusikValue
@onready var label_sfx     = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer3/volumeSfxValue
@onready var label_voice   = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer4/volumeDialogValue

@onready var btn_simpan: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/simpan

func _ready():
	# Mulai selalu dari nilai TERSIMPAN, supaya perubahan bisa dibatalkan (Kembali).
	SettingsManager.load_settings()
	SettingsManager.terapkan_semua()

	# Set slider dulu (belum connect) biar tidak memicu perubahan saat inisialisasi.
	slider_master.value = SettingsManager.get_volume("Master")
	slider_bgm.value = SettingsManager.get_volume("BGM")
	slider_sfx.value = SettingsManager.get_volume("SFX")
	slider_voice.value = SettingsManager.get_volume("Voice")
	_refresh_labels()

	slider_master.value_changed.connect(_on_master_changed)
	slider_bgm.value_changed.connect(_on_bgm_changed)
	slider_sfx.value_changed.connect(_on_sfx_changed)
	slider_voice.value_changed.connect(_on_voice_changed)
	btn_simpan.pressed.connect(_on_simpan_pressed)  # tombol Simpan belum di-wire di .tscn

# Preview live: langsung diterapkan (belum ke disk sampai tekan Simpan).
func _on_master_changed(value: float):
	SettingsManager.set_volume("Master", value)
	label_master.text = str(int(value))

func _on_bgm_changed(value: float):
	SettingsManager.set_volume("BGM", value)
	label_bgm.text = str(int(value))

func _on_sfx_changed(value: float):
	SettingsManager.set_volume("SFX", value)
	label_sfx.text = str(int(value))

func _on_voice_changed(value: float):
	SettingsManager.set_volume("Voice", value)
	label_voice.text = str(int(value))

func _refresh_labels():
	label_master.text = str(int(slider_master.value))
	label_bgm.text = str(int(slider_bgm.value))
	label_sfx.text = str(int(slider_sfx.value))
	label_voice.text = str(int(slider_voice.value))

# SIMPAN: persist ke disk + feedback singkat + tutup ke menu.
func _on_simpan_pressed():
	SettingsManager.save_settings()
	btn_simpan.text = "Tersimpan!"
	btn_simpan.disabled = true
	await get_tree().create_timer(0.6).timeout
	btn_simpan.text = "Simpan"
	btn_simpan.disabled = false
	_tutup()

# KEMBALI (Batal): buang perubahan, balik ke nilai terakhir tersimpan, lalu tutup.
func _on_kembali_pressed():
	SettingsManager.load_settings()
	SettingsManager.terapkan_semua()
	_tutup()

## Tutup Pengaturan. Overlay via SceneManager -> pop_overlay; embedded di main_menu
## (mode lama) -> tampilkan lagi menu.
func _tutup():
	var sm = get_node_or_null("/root/SceneManager")
	if sm != null and sm.is_overlay(self):
		sm.pop_overlay()
		return
	var menu = get_parent().get_node_or_null("menu")
	if menu != null:
		menu.visible = true
	self.visible = false
