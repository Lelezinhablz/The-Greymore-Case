extends Node3D

@export var spin_speed: float = 0.5
@export var item_resource: ItemResource

func _process(delta):
	rotate_y(spin_speed * delta)


func _on_pickup_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
