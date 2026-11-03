extends State
class_name AimState

@export var idle_state: State
@export var move_state: State
@export var player: CharacterBody3D
@export var equipment_holder: EquipmentHolder
@export var projectile_scene: PackedScene
@export var fire_cooldown := 0.4

@export_group("Animation Settings")
@export var anim_player: AnimationPlayer
@export var default_blend_time := 0.2
@export var aiming_ray: AimingRay

var _last_shot_time := 0.0
var _current_target: AimTarget = null

func enter_state() -> void:
	anim_player.play("aim", default_blend_time)

func physics_update(delta: float) -> void:
	if not Input.is_action_pressed("aim") or not InventoryManager.has_ranged_weapon_equipped():
		switch_state.emit(idle_state)
		return

	player.velocity.x = 0
	player.velocity.z = 0
	auto_aim()

	if Input.is_action_just_pressed("shoot"):
		_try_shoot()

func auto_aim() -> void:
	_current_target = aiming_ray.find_closest_target()
	if _current_target == null:
		return
	var target_position := Vector3(_current_target.global_position.x, player.global_position.y, _current_target.global_position.z)
	player.look_at(target_position)

func _try_shoot() -> void:

	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_shot_time < fire_cooldown:
		return
	_last_shot_time = now

	var muzzle := equipment_holder.get_muzzle()
	var origin: Vector3 = muzzle.global_position if muzzle else player.global_position + Vector3.UP

	# com alvo: mira no alvo. sem alvo: atira reto para a frente do player
	var dir: Vector3
	if _current_target and is_instance_valid(_current_target):
		dir = (_current_target.global_position - origin).normalized()
	else:
		dir = -player.global_transform.basis.z

	var p := projectile_scene.instantiate() as Projectile
	get_tree().current_scene.add_child(p)
	p.global_position = origin
	p.direction = dir
