# DragCard.gd - carta arrastável (pista do bloco de notas ou item do inventário)
# Criada por código: DragCard.new() + setup(...)
extends PanelContainer
class_name DragCard

var kind := "clue"   # "clue" ou "item"
var id := ""
var title := ""

func setup(p_kind: String, p_id: String, p_title: String, p_text := "") -> void:
	kind = p_kind
	id = p_id
	title = p_title
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_DRAG

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)

	var t := Label.new()
	t.text = p_title
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(t)

	if p_text != "":
		var d := Label.new()
		d.text = p_text
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.custom_minimum_size.x = 200
		d.modulate = Color(1, 1, 1, 0.7)
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(d)

# Chamado pelo Godot quando o jogador começa a arrastar
func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := PanelContainer.new()
	var l := Label.new()
	l.text = title
	preview.add_child(l)
	preview.modulate = Color(1, 1, 1, 0.85)
	set_drag_preview(preview)
	return {"kind": kind, "id": id, "title": title}
