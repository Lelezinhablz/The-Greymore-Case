class_name Player extends CharacterBody3D

@onready var state_machine = $StateMachine
const GRAVITY = -9.81

var is_aiming := false

func handle_gravity(delta):
	if is_on_floor():
		velocity.y = -2
	else:
		velocity.y += GRAVITY * delta

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)
	handle_gravity(delta)
	move_and_slide()
