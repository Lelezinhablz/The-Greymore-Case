class_name Projectile extends Area3D

@export var speed := 40.0
@export var damage := 1
@export var lifetime := 2.0

var direction := Vector3.FORWARD
var _age := 0.0

func _ready() -> void:
	area_entered.connect(_on_hit)
	body_entered.connect(_on_hit)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_age += delta
	if _age >= lifetime:
		queue_free()

func _on_hit(other: Node) -> void:
	if other is AimTarget:
		other.apply_damage(damage)
	queue_free()
