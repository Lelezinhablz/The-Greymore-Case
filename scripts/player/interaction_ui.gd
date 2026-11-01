extends CanvasLayer

@export var manager: InteractionManager

@onready var prompt_label: Label = $Control/PromptLabel
@onready var menu_box: HBoxContainer = $Control/MenuBox
@onready var message_label: Label = $Control/MessageLabel

var _option_labels: Array[Label] = []
var _msg_timer: SceneTreeTimer

func _ready():
	prompt_label.hide()
	menu_box.hide()
	message_label.hide()
	manager.target_changed.connect(_on_target_changed)
	manager.menu_opened.connect(_on_menu_opened)
	manager.menu_index_changed.connect(_highlight)
	manager.menu_closed.connect(_on_menu_closed)
	manager.message_requested.connect(_on_message)

func _on_target_changed(target: Interactable) -> void:
	if target and not manager.menu_open:
		prompt_label.text = "[E] " + target.prompt_text
		prompt_label.show()
	else:
		prompt_label.hide()

func _on_menu_opened(options: Array[String]) -> void:
	prompt_label.hide()
	for c in menu_box.get_children():
		c.queue_free()
	_option_labels.clear()
	for o in options:
		var l := Label.new()
		l.text = o
		menu_box.add_child(l)
		_option_labels.append(l)
	menu_box.show()
	_highlight(0)

func _highlight(index: int) -> void:
	for i in _option_labels.size():
		_option_labels[i].text = ("> " if i == index else "  ") + _option_labels[i].text.strip_edges().trim_prefix(">").strip_edges()

func _on_menu_closed() -> void:
	menu_box.hide()

func _on_message(text: String) -> void:
	message_label.text = text
	message_label.show()
	_msg_timer = get_tree().create_timer(3.0)
	_msg_timer.timeout.connect(message_label.hide)
