# PuzzleInteractable.gd - objeto do mundo (quadro, tabuleta...) que abre uma UI.
# Defina prompt_text no Inspector (ex.: "Examinar quadro").
extends Interactable
class_name PuzzleInteractable

@export var ui_scene: PackedScene

func get_actions() -> Array[String]:
	print("[Puzzle] get_actions em ", name, " | ui_scene = ", ui_scene)
	return ["Examinar", "Sair"]

func perform_action(action: String, manager: InteractionManager) -> bool:
	print("[Puzzle] perform_action: ", action)
	if action == "Examinar":
		if ui_scene == null:
			push_warning("PuzzleInteractable sem ui_scene: " + str(get_path()))
			return true
		var ui := ui_scene.instantiate()
		get_tree().current_scene.add_child(ui)
		# a UI se destrói no _ready se a cena estiver mal montada: não deixa o menu preso
		if ui.is_queued_for_deletion():
			return true
		# o menu de interação só fecha quando a UI fechar
		ui.closed.connect(manager.close_menu)
		manager.dialogue_started.emit()   # o InteractionUI esconde o menu "Examinar / Sair"
		return false
	return true
