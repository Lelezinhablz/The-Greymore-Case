# HeadSlot.gd - posição da tabuleta que guarda uma cabeça. Arrastar = mover/trocar.
extends PanelContainer
class_name HeadSlot

signal head_changed(slot: HeadSlot)

const LABELS := {
	"sadica": "Sádica\n(olha p/ esquerda)",
	"triste": "Triste\n(colar de cobra)",
}

@export var slot_name := ""
@export var head_id := ""                    # "" = encaixe vazio
@export var head_textures: Dictionary = {}   # id -> Texture2D (opcional; sem textura usa texto)
@export var locked := false

var _tex: TextureRect
var _label: Label

func _ready() -> void:
	custom_minimum_size = Vector2(140, 140)
	_tex = TextureRect.new()
	_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tex)
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
	set_head(head_id)

func set_head(id: String) -> void:
	head_id = id
	_tex.texture = head_textures.get(id)
	if _tex.texture != null:
		_label.text = ""
	else:
		_label.text = LABELS.get(id, "(encaixe)")
	modulate.a = 1.0 if id != "" else 0.5

func _get_drag_data(_at_position: Vector2) -> Variant:
	if locked or head_id == "":
		return null
	var preview := Label.new()
	preview.text = LABELS.get(head_id, head_id)
	set_drag_preview(preview)
	return {"kind": "head", "from": self}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return not locked and data is Dictionary \
		and data.get("kind") == "head" and data.get("from") != self

# soltar em encaixe vazio = mover; em encaixe ocupado = trocar
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var other := data["from"] as HeadSlot
	var mine := head_id
	set_head(other.head_id)
	other.set_head(mine)
	head_changed.emit(self)
