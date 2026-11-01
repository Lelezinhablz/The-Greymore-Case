extends Interactable
class_name ItemPickup

@export var item: ItemResource

func _ready():
	if item == null:
		push_warning("ItemPickup sem item atribuído: " + str(get_path()))
		return
	prompt_text = "Examinar " + item.name
	if item.scene_3d:
		add_child(item.scene_3d.instantiate())

func get_actions() -> Array[String]:
	return ["Olhar", "Pegar", "Sair"]

func perform_action(action: String, manager: InteractionManager) -> bool:
	match action:
		"Olhar":
			manager.message_requested.emit(item.description)
			return false  # continua no menu
		"Pegar":
			InventoryManager.add_item(item)
			manager.message_requested.emit("Você pegou: " + item.name)
			queue_free()
			return true
		_:  # "Sair"
			return true
