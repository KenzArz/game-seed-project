## Definisi 1 bahan (data-driven).
## Desainer bisa bikin/edit ini di Inspector (sebagai .tres) atau di-seed lewat
## kode untuk prototype. Mengisi `texture` nanti mengganti greybox jadi gambar
## tanpa ubah kode.
class_name IngredientDef
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var placeholder_color: Color = Color(0.4, 0.4, 0.5)  ## warna kotak saat mode greybox
@export var texture: Texture2D  ## gambar OPSIONAL; null saat prototype
