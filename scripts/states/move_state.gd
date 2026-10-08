extends State
class_name MoveState

@export var idle_state: State
@export var player: CharacterBody3D 

@export_group("Animation Settings")
@export var anim_player: AnimationPlayer
@export var default_blend_time := 0.5

@export_group("Movement Settings")
@export var rotation_speed := 12.0
@export var walk_speed := 3.0 
@export var run_speed := 6.0
@export var acceleration := 18.0  
@export var deceleration := 24.0  

@export_group("QuickTurn Settings")
@export var quick_turn_state: State
@export var double_tap_window: int = 300
var last_tap_time: int = 0


func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("move_backward"):
		var current_time := Time.get_ticks_msec()
		if current_time - last_tap_time <= double_tap_window:
			switch_state.emit(quick_turn_state) 
			last_tap_time = 0 
			return 
		else:
			last_tap_time = current_time

	var input_vector := Input.get_vector("turn_left", "turn_right", "move_forward", "move_backward")

	var camera := player.get_viewport().get_camera_3d()
	var direction := Vector3.ZERO

	if camera:
		var cam_forward := -camera.global_transform.basis.z
		var cam_right := camera.global_transform.basis.x

		cam_forward.y = 0
		cam_right.y = 0

		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()

		direction = (cam_right * input_vector.x + cam_forward * -input_vector.y).normalized()
	else:
		direction = Vector3(input_vector.x, 0, input_vector.y).normalized()

	var is_running := Input.is_action_pressed("run")
	var current_speed := run_speed if is_running else walk_speed

	var target_vel_x := direction.x * current_speed
	var target_vel_z := direction.z * current_speed

	var accel_rate := acceleration if direction != Vector3.ZERO else deceleration


	player.velocity.x = move_toward(player.velocity.x, target_vel_x, accel_rate * delta)
	player.velocity.z = move_toward(player.velocity.z, target_vel_z, accel_rate * delta)

	var current_horizontal_speed := Vector2(player.velocity.x, player.velocity.z).length()
	if direction == Vector3.ZERO and current_horizontal_speed < 0.1:
		player.velocity.x = 0
		player.velocity.z = 0
		switch_state.emit(idle_state)
		return

	if direction != Vector3.ZERO:
		var target_angle := atan2(-direction.x, -direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_angle, rotation_speed * delta)

		if is_running:
			anim_player.play("run", default_blend_time, 1.15)
		else:
			anim_player.play("walk", default_blend_time)
