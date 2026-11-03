class_name EquipmentHolder extends Node3D

@export var slot: ItemResource.EquipSlot = ItemResource.EquipSlot.HAND

var current_model: Node3D

func _ready() -> void:
	InventoryManager.equipped_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	if current_model:
		current_model.queue_free()
		current_model = null
	var item := InventoryManager.get_equipped(slot)
	if item and item.equip_scene:
		current_model = item.equip_scene.instantiate()
		add_child(current_model)

func get_muzzle() -> Marker3D:
	if current_model == null:
		return null
	return current_model.find_child("Muzzle", true, false) as Marker3D
