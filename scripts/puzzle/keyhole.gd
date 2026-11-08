# Keyhole.gd - cabeça central com a fechadura na testa. Aceita o item certo arrastado.
extends PanelContainer
class_name Keyhole

signal unlocked
signal rejected(data: Dictionary)

@export var required_item := "Chave Dedo"   # = ItemResource.name da chave
@export var face_texture: Texture2D          # opcional

var _opened := false

func _ready() -> void:
	custom_minimum_size = Vector2(200, 200)
	if face_texture:
		var tr := TextureRect.new()
		tr.texture = face_texture
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(tr)
	else:
		var l := Label.new()
		l.text = "Cabeça central\n(fechadura na testa)"
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(l)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return not _opened and data is Dictionary and data.get("kind") == "item"

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data["id"] == required_item:
		_opened = true
		unlocked.emit()
	else:
		rejected.emit(data)
