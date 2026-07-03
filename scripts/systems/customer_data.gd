## Data 1 pelanggan / "level". Unit progres data-driven: untuk menambah pelanggan
## baru, bikin file CustomerData (.tres) BARU di res://resources/customers/ —
## stage otomatis memuat semua file di situ (urut nama file).
##
## Tiap pelanggan punya RESEP target (id bahan). Setelah disajikan, game menghitung
## berapa bahan resep yang benar lalu memainkan REAKSI dialog berbeda (perfect /
## sebagian / salah). TIDAK ada skor — hanya teks reaksinya yang berubah.
##
## Dialog system:
##   Satu file .dtl per pelanggan, berisi label "intro", "react_perfect",
##   "react_partial", "react_wrong". Dipanggil via Dialogic.start(tl, "label").
class_name CustomerData
extends Resource

@export var id: String = ""
@export var display_name: String = "NPC"

@export_group("Portrait")
@export var npc_color: Color = Color(0.32, 0.28, 0.4)  ## warna greybox
@export var npc_texture: Texture2D                      ## gambar OPSIONAL; null = greybox

@export_group("Recipe")
## Bahan yang TERSEDIA di rak saat pelanggan ini (sistem unlock cerita).
@export var available_ingredients: PackedStringArray = PackedStringArray()

## Id bahan ideal untuk pelanggan ini (maks 3).
@export var recipe: PackedStringArray = PackedStringArray()

## Nama busa hasil yang tampil di layar serve, per tingkat kecocokan.
@export var result_perfect: String = "Busa Sempurna"
@export var result_partial: String = "Busa Setengah Jadi"
@export var result_wrong: String = "Busa Gagal"

@export_group("Dialogue")
## File .dtl tunggal berisi semua dialog pelanggan ini (intro + semua reaksi).
## Di dalam file .dtl pakai label "intro", "react_perfect", "react_partial", "react_wrong".
@export var timeline: DialogicTimeline

## Teks hint dialog Pak Guyon yang muncul saat phase crafting dimulai.
## Format: dialog singkat Pak Guyon yang menyindir bahan tanpa menyebut langsung.
## Pakai BBCode untuk warnai kata kunci penting.
@export_multiline var hint_crafting_text: String = ""

@export_group("Scene")
@export var background_color: Color = Color(0.16, 0.15, 0.2)
@export var background_texture: Texture2D
