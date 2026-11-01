extends Interactable
class_name DialogueInteractable

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

func _ready() -> void:
	prompt_text = "Falar"
	if dialogue_resource == null:
		push_warning("DialogueInteractable sem dialogue_resource: " + str(get_path()))

func get_actions() -> Array[String]:
	return ["Falar", "Sair"]

func perform_action(action: String, manager: InteractionManager) -> bool:
	match action:
		"Falar":
			manager.start_dialogue(dialogue_resource, dialogue_start)
			return false  # o manager fecha o menu quando o diálogo acabar
		_:
			return true
