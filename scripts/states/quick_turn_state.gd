extends State
class_name QuickTurnState

@export var player: CharacterBody3D
@export var idle_state: State
@export var quick_turn_speed: float = 0.2

@export_group("Animation Settings")
@export var anim_player: AnimationPlayer
@export var default_blend_time := 0.5

func enter_state() -> void:
	var target_y_rotation = player.rotation.y + PI
	
	var tween = create_tween()
	tween.tween_property(player, "rotation:y", target_y_rotation, quick_turn_speed)
	
	tween.finished.connect(_on_turn_finished)

func _on_turn_finished() -> void:
	switch_state.emit(idle_state)
	
func physics_update(_delta: float) -> void:
	player.velocity.x = 0
	player.velocity.z = 0
