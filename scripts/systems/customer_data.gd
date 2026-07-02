## Data 1 pelanggan / "level". Unit progres data-driven: untuk menambah pelanggan
## baru, bikin file CustomerData (.tres) BARU di res://resources/customers/ —
## stage otomatis memuat semua file di situ (urut nama file).
##
## Tiap pelanggan punya RESEP target (id bahan). Setelah disajikan, game menghitung
## berapa bahan resep yang benar lalu memainkan REAKSI dialog berbeda (perfect /
## sebagian / salah). TIDAK ada skor — hanya teks reaksinya yang berubah.
class_name CustomerData
extends Resource

@export var id: String = ""
@export var display_name: String = "NPC"

@export_group("Portrait")
@export var npc_color: Color = Color(0.32, 0.28, 0.4)  ## warna greybox
@export var npc_texture: Texture2D                      ## gambar OPSIONAL; null = greybox

@export_group("Recipe")
## Bahan yang TERSEDIA di rak saat pelanggan ini (sistem unlock cerita).
## Mis. ["sabun","shampo"] = baru 2 bahan terbuka. Kosong = semua bahan tampil.
@export var available_ingredients: PackedStringArray = PackedStringArray()

## Id bahan ideal untuk pelanggan ini (maks 3), mis. ["sabun","shampo","mint"].
## Penentu reaksi mana yang main — TIDAK ditampilkan ke player & TIDAK diberi skor.
@export var recipe: PackedStringArray = PackedStringArray()

## Nama busa hasil yang tampil di layar serve, per tingkat kecocokan.
@export var result_perfect: String = "Busa Sempurna"  ## semua bahan resep benar
@export var result_partial: String = "Busa Setengah Jadi"  ## sebagian benar
@export var result_wrong: String = "Busa Gagal"  ## tidak ada yang benar

@export_group("Dialogue")
## Diucapkan SEBELUM meracik (sebaiknya kasih petunjuk apa yang dia mau).
@export_multiline var intro_lines: PackedStringArray = PackedStringArray()
## Reaksi SETELAH disajikan, dipilih berdasarkan berapa bahan resep yang benar:
@export_multiline var react_perfect: PackedStringArray = PackedStringArray()  ## semua bahan resep benar
@export_multiline var react_partial: PackedStringArray = PackedStringArray()  ## sebagian benar
@export_multiline var react_wrong: PackedStringArray = PackedStringArray()    ## tidak ada yang benar

## Cara LENGKAP (opsional): timeline Dialogic (.dtl) untuk intro. Kalau diisi, ia
## MENGGANTIKAN intro_lines (nama, portrait, pilihan semua jalan).
@export var intro_timeline: DialogicTimeline

@export_group("Scene")
@export var background_color: Color = Color(0.16, 0.15, 0.2)  ## warna greybox
@export var background_texture: Texture2D                      ## gambar OPSIONAL; null = greybox
