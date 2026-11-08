# ThreeFacesUI.gd - raiz da cena do puzzle "jogo das três faces" (CanvasLayer)
# Solução: mid_left = triste, mid_right = sádica (sádica olha p/ esquerda, ou seja, para a triste)
extends CanvasLayer
class_name ThreeFacesUI

signal closed

const PUZZLE_ID := "tres_faces"
const SOLUTION := {"mid_left": "triste", "mid_right": "sadica"}

@export var reward_item: ItemResource

@onready var keyhole: Keyhole = %Keyhole
@onready var slots_root: Control = %Slots
@onready var items_list: HBoxContainer = %ItemsList
@onready var message: Label = %Message
@onready var close_button: Button = %CloseButton

var _slots: Dictionary = {}   # slot_name -> HeadSlot
var _prev_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_prev_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

	close_button.pressed.connect(close)
	InventoryManager.inventory_changed.connect(_refresh_items)
	keyhole.unlocked.connect(_on_unlocked)
	keyhole.rejected.connect(func(_d): _say("Não serve nessa fechadura."))

	for child in slots_root.get_children():
		if child is HeadSlot:
			var slot := child as HeadSlot
			_slots[slot.slot_name] = slot
			slot.head_changed.connect(_on_head_changed)

	_restore()
	_refresh_items()

func _restore() -> void:
	_set_locked(true)   # cabeças presas até usar a chave
	var heads: Dictionary = NotebookManager.get_state(PUZZLE_ID, "heads", {})
	for slot_name in heads:
		if _slots.has(slot_name):
			_slots[slot_name].set_head(heads[slot_name])
	if NotebookManager.get_state(PUZZLE_ID, "unlocked", false):
		_reveal_slots()
	if NotebookManager.is_solved(PUZZLE_ID):
		_set_locked(true)
		_say("O mecanismo já foi resolvido.")

func _set_locked(value: bool) -> void:
	for slot_name in _slots:
		_slots[slot_name].locked = value

func _on_unlocked() -> void:
	NotebookManager.set_state(PUZZLE_ID, "unlocked", true)
	_say("A cabeça central se soltou. Atrás dela há dois encaixes.")
	var tw := create_tween()
	tw.tween_property(keyhole, "modulate:a", 0.0, 0.6)
	tw.tween_callback(_reveal_slots)

func _reveal_slots() -> void:
	keyhole.hide()
	_slots["mid_left"].show()
	_slots["mid_right"].show()
	_set_locked(false)

func _on_head_changed(_slot: HeadSlot) -> void:
	var heads := {}
	for slot_name in _slots:
		heads[slot_name] = _slots[slot_name].head_id
	NotebookManager.set_state(PUZZLE_ID, "heads", heads)
	_check()

func _check() -> void:
	for slot_name in SOLUTION:
		if _slots[slot_name].head_id != SOLUTION[slot_name]:
			return
	_solve()

func _solve() -> void:
	if NotebookManager.is_solved(PUZZLE_ID):
		return
	NotebookManager.mark_solved(PUZZLE_ID)
	_set_locked(true)
	var msg := "Clique. O mecanismo se abre."
	if reward_item:
		InventoryManager.add_item(reward_item)
		msg += "\nVocê pegou: " + reward_item.name
	_say(msg)

func _refresh_items(_arg = null) -> void:
	for c in items_list.get_children():
		c.queue_free()
	for item in InventoryManager.items:
		var card := DragCard.new()
		items_list.add_child(card)
		card.setup("item", item.name, item.name, item.description)

func _say(text: String) -> void:
	message.text = text

func close() -> void:
	get_tree().paused = false
	Input.mouse_mode = _prev_mouse_mode
	closed.emit()
	queue_free()
