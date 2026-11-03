class_name Enemy extends CharacterBody3D

@export var detection_range := 10.0   # começa a perseguir dentro dessa distância
@export var lose_range := 14.0        # desiste se o player fugir além disso
@export var hop_speed := 4.0
@export var jump_velocity := 5.0
@export var hop_cooldown := 0.8       # pausa entre um pulo e outro
@export var damage := 1
@export var attack_cooldown := 1.0
@export var turn_speed := 10.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_area: Area3D = $AttackArea

const GRAVITY := -9.81

var player: Node3D
var chasing := false
var _hop_timer := 0.0
var _attack_timer := 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node3D
	health_component.died.connect(queue_free)

func _physics_process(delta: float) -> void:
	if player == null:
		return

	if is_on_floor():
		# no chão ele fica parado, só pula quando o timer zera
		velocity.x = move_toward(velocity.x, 0.0, 30.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 30.0 * delta)
		if velocity.y < 0.0:
			velocity.y = 0.0

		_update_chase()
		_hop_timer -= delta
		if chasing and _hop_timer <= 0.0:
			_hop()
	else:
		velocity.y += GRAVITY * delta

	move_and_slide()
	_try_attack(delta)

func _update_chase() -> void:
	var to_player := player.global_position - global_position
	to_player.y = 0.0
	var dist := to_player.length()
	if not chasing and dist <= detection_range:
		chasing = true
	elif chasing and dist > lose_range:
		chasing = false

func _hop() -> void:
	var dir := player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()

	look_at(global_position + dir, Vector3.UP)   # vira para o player antes de pular
	velocity.x = dir.x * hop_speed
	velocity.z = dir.z * hop_speed
	velocity.y = jump_velocity
	_hop_timer = hop_cooldown

func _try_attack(delta: float) -> void:
	_attack_timer -= delta
	if _attack_timer > 0.0:
		return
	for body in attack_area.get_overlapping_bodies():
		if body is Player:
			PlayerStats.take_damage(damage)
			_attack_timer = attack_cooldown
			break
