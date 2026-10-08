extends State
class_name AimState

@export var idle_state: State
@export var move_state: State 
@export var player: CharacterBody3D 

@export_group("Animation Settings")
@export var anim_player: AnimationPlayer
@export var default_blend_time := 0.2
@export var aiming_ray: AimingRay

func enter_state() -> void:
	anim_player.play("aim", default_blend_time)

func physics_update(delta: float) -> void:
	if not Input.is_action_pressed("aim"):
		switch_state.emit(idle_state)
		return

	var is_aiming = Input.is_action_pressed("aim")
	
	if is_aiming:
		player.velocity.x = 0
		player.velocity.z = 0
		auto_aim()

func auto_aim():
	var target := aiming_ray.find_closest_target()
	if target == null:
		return
		
	var target_position = Vector3(target.global_position.x, player.global_position.y, target.global_position.z)
	player.look_at(target_position)
