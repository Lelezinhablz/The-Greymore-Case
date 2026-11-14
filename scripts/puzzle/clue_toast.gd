# ClueToast.gd  (AUTOLOAD) - aviso "Nova pista" no topo da tela
# O autoload PRECISA se chamar exatamente ClueToast.
extends CanvasLayer

var _panel: PanelContainer
var _label: Label
var _tween: Tween

func _ready() -> void:
	layer = 128                                   # acima do balão de diálogo (layer 100)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.offset_top = 24
	_panel.modulate.a = 0.0
	add_child(_panel)

	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 22)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)

	NotebookManager.clue_added.connect(_on_clue_added)

func _on_clue_added(id: String) -> void:
	show_message("Pista coletada: " + NotebookManager.get_clue(id).get("title", id))

# Pode ser usado para qualquer aviso: ClueToast.show_message("texto")
func show_message(text: String) -> void:
	_label.text = text
	if _tween:
		_tween.kill()
	_panel.modulate.a = 1.0
	_tween = create_tween()
	_tween.tween_interval(2.5)
	_tween.tween_property(_panel, "modulate:a", 0.0, 0.4)
