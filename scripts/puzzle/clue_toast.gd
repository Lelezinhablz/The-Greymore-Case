# ClueToast.gd  (AUTOLOAD, opcional) - aviso "Nova pista" no topo da tela
extends CanvasLayer

var _label: Label

func _ready() -> void:
	layer = 30
	_label = Label.new()
	_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_label.offset_top = 24
	_label.hide()
	add_child(_label)
	NotebookManager.clue_added.connect(_on_clue_added)

func _on_clue_added(id: String) -> void:
	_label.text = "Nova pista: " + NotebookManager.get_clue(id).get("title", id)
	_label.show()
	await get_tree().create_timer(2.5).timeout
	_label.hide()
