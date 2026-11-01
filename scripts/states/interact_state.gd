extends State
class_name InteractState

@export var idle_state: State
@export var player: CharacterBody3D 

@export var idle_state: State
@export var player: CharacterBody3D
@export var interaction_manager: InteractionManager
@export var anim_player: AnimationPlayer


@export_group("QuickTurn Settings")
@export var quick_turn_state: State
@export var double_tap_window: int = 300

func enter_state() -> void:
	player.velocity = Vector3.ZERO
	anim_player.play("idle", 0.3)
	if not interaction_manager.menu_closed.is_connected(_on_menu_closed):
		interaction_manager.menu_closed.connect(_on_menu_closed)
	interaction_manager.open_menu()

func physics_update(_delta: float) -> void:
	interaction_manager.handle_input()

func _on_menu_closed() -> void:
	switch_state.emit(idle_state)
