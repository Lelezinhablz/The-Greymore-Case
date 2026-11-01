extends Node3D

@export var spin_speed: float = 0.5
@export var item_resource: ItemResource

func _process(delta):
	rotate_y(spin_speed * delta)
