# ClueSlot.gd - encaixe do quadro. Só aceita a carta (kind + id) esperada.
extends PanelContainer
class_name ClueSlot

signal filled(slot: ClueSlot)
signal rejected(slot: ClueSlot, data: Dictionary)

@export var slot_name := ""          # único dentro do quadro (usado para salvar estado)
@export var expected_kind := "clue"  # "clue" ou "item"
@export var expected_id := ""        # id da pista OU name do ItemResource
@export var empty_text := "?"

var current: Dictionary = {}
var _label: Label

func _ready() -> void:
	custom_minimum_size = Vector2(180, 90)
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
	_refresh()

func is_filled() -> bool:
	return not current.is_empty()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return not is_filled() and data is Dictionary and data.has("kind") and data.has("id")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data["kind"] == expected_kind and data["id"] == expected_id:
		fill(data)
	else:
		rejected.emit(self, data)
		_flash(Color(1, 0.3, 0.3))

# silent = true -> restaura estado salvo sem emitir sinal/efeito
func fill(data: Dictionary, silent := false) -> void:
	current = {
		"kind": data["kind"],
		"id": data["id"],
		"title": data.get("title", data["id"]),
	}
	_refresh()
	if not silent:
		_flash(Color(0.4, 1, 0.5))
		filled.emit(self)

func _refresh() -> void:
	if is_filled():
		_label.text = current["title"]
		_label.modulate = Color.WHITE
	else:
		_label.text = empty_text
		_label.modulate = Color(1, 1, 1, 0.5)

func _flash(color: Color) -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate", color, 0.12)
	tw.tween_property(self, "modulate", Color.WHITE, 0.25)
