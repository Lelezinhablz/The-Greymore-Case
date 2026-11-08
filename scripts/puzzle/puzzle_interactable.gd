# PuzzleInteractable.gd - objeto do mundo (quadro, tabuleta...) que abre uma UI.
# Defina prompt_text no Inspector (ex.: "Examinar quadro").
extends Interactable
class_name PuzzleInteractable

@export var ui_scene: PackedScene

func get_actions() -> Array[String]:
	return ["Examinar", "Sair"]

func perform_action(action: String, manager: InteractionManager) -> bool:
	if action == "Examinar" and ui_scene:
		var ui := ui_scene.instantiate()
		get_tree().current_scene.add_child(ui)
		# o menu de interação só fecha quando a UI fechar
		ui.closed.connect(manager.close_menu)
		return false
	return true
