class_name EquipmentHolder extends Node3D

var current_model: Node3D

func _ready() -> void:
	InventoryManager.equipped_changed.connect(_refresh)
	_refresh()  # o autoload sobrevive a troca de cena, então sincroniza no início

func _refresh() -> void:
	if current_model:
		current_model.queue_free()
		current_model = null
	var item := InventoryManager.equipped_item
	if item and item.equip_scene:
		current_model = item.equip_scene.instantiate()
		add_child(current_model)
