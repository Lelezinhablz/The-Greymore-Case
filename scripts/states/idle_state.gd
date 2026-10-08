extends State
class_name IdleState

@export var move_state: State
@export var quick_turn_state: State
@export var aim_state: State
@export var player: CharacterBody3D

@export_group("QuickTurn Settings")
@export var double_tap_window: int = 300
var last_tap_time: int = 0

@export_group("Animation Settings")
@export var anim_player: AnimationPlayer
@export var default_blend_time := 0.5



func enter_state() -> void:
	anim_player.play("idle", default_blend_time)

func physics_update(_delta: float) -> void:
	if Input.is_action_pressed("aim"):
		switch_state.emit(aim_state)
		return
		
	if Input.is_action_just_pressed("move_backward"):
		var current_time := Time.get_ticks_msec()
		
		if current_time - last_tap_time <= double_tap_window:
			switch_state.emit(quick_turn_state)
			last_tap_time = 0
			return
		else:
			last_tap_time = current_time

	var move_dir = Input.get_axis("move_backward", "move_forward")
	var turn_dir = Input.get_axis("turn_left", "turn_right")
	
	if move_dir != 0 or turn_dir != 0:
		switch_state.emit(move_state)
