## FASE 3 — layar "HASIL RACIKAN".
##
## LAYOUT dibuat di EDITOR (lihat serve_panel.tscn) — kotak, tombol, judul semua
## node yang bisa kamu geser & edit visual lewat Inspector. Script ini HANYA
## logika: menyambungkan tombol ke sinyal + mengganti tulisan nama busa.
##
## Node yang dipakai (ada di serve_panel.tscn):
##   Frame      = PlaceholderBox  (latar panel)
##   ResultBox  = PlaceholderBox  (nama busa hasil)
##   Buang/Aduk/Sajikan = Button
class_name ServePanel
extends CraftPanel

signal trash_requested
signal serve_requested
signal stir_requested

@onready var _result_box: PlaceholderBox = $ResultBox
@onready var _buang: Button = $Buang
@onready var _aduk: Button = $Aduk
@onready var _sajikan: Button = $Sajikan


# _build() dipanggil oleh CraftPanel saat panel siap. Di sini kita TIDAK bikin
# kotak (sudah ada di editor) — cuma menyambungkan tombol.
func _build() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # area kosong tembus klik ke bawah
	_buang.pressed.connect(func() -> void: trash_requested.emit())
	_aduk.pressed.connect(func() -> void: stir_requested.emit())
	_sajikan.pressed.connect(func() -> void: serve_requested.emit())


## Ganti tulisan nama busa di kotak hasil (dipanggil level1.gd saat tekan RACIK).
func set_result(text: String) -> void:
	if _result_box:
		_result_box.display_name = text
