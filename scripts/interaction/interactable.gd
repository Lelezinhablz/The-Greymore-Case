extends Area3D
class_name Interactable

@export var prompt_text: String = "Examinar"

# Opções que aparecem no menu
func get_actions() -> Array[String]:
	return ["Sair"]

# Retorna true se a interação deve ENCERRAR depois dessa ação
func perform_action(_action: String, _manager: InteractionManager) -> bool:
	return true
