# PuzzleBoardUI.gd - raiz da cena do quadro (CanvasLayer)
extends CanvasLayer
class_name PuzzleBoardUI

signal closed

@export var puzzle_id := "caso_01"
@export var reward_item: ItemResource                 # opcional
@export_multiline var solved_text := "Tudo se encaixa. Você descobriu quem saiu da casa."

@onready var slots_root: Control = %Slots
@onready var notes_list: VBoxContainer = %NotesList
@onready var items_list: VBoxContainer = %ItemsList
@onready var message: Label = %Message
@onready var close_button: Button = %CloseButton

var _slots: Array[ClueSlot] = []
var _prev_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_prev_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

	close_button.pressed.connect(close)
	NotebookManager.clue_added.connect(_refresh_lists)
	InventoryManager.inventory_changed.connect(_refresh_lists)

	for child in slots_root.get_children():
		if child is ClueSlot:
			var slot := child as ClueSlot
			_slots.append(slot)
			slot.filled.connect(_on_slot_filled)
			slot.rejected.connect(_on_slot_rejected)
			# restaura encaixes de quando o jogador abriu o quadro antes
			var saved: Dictionary = NotebookManager.get_state(puzzle_id, slot.slot_name, {})
			if not saved.is_empty():
				slot.fill(saved, true)

	_refresh_lists()
	message.text = solved_text if NotebookManager.is_solved(puzzle_id) else ""

func _refresh_lists(_arg = null) -> void:
	for c in notes_list.get_children():
		c.queue_free()
	for c in items_list.get_children():
		c.queue_free()

	for id in NotebookManager.collected:
		var data := NotebookManager.get_clue(id)
		var card := DragCard.new()
		notes_list.add_child(card)
		card.setup("clue", id, data["title"], data["text"])

	for item in InventoryManager.items:
		var card := DragCard.new()
		items_list.add_child(card)
		card.setup("item", item.name, item.name, item.description)

func _on_slot_filled(slot: ClueSlot) -> void:
	NotebookManager.set_state(puzzle_id, slot.slot_name, slot.current)
	_say("Isso se encaixa.")
	for s in _slots:
		if not s.is_filled():
			return
	_solve()

func _on_slot_rejected(_slot: ClueSlot, _data: Dictionary) -> void:
	_say("Isso não parece se encaixar aqui.")

func _solve() -> void:
	if NotebookManager.is_solved(puzzle_id):
		return
	NotebookManager.mark_solved(puzzle_id)
	var msg := solved_text
	if reward_item:
		InventoryManager.add_item(reward_item)
		msg += "\nVocê pegou: " + reward_item.name
	_say(msg)

func _say(text: String) -> void:
	message.text = text

func close() -> void:
	get_tree().paused = false
	Input.mouse_mode = _prev_mouse_mode
	closed.emit()
	queue_free()
