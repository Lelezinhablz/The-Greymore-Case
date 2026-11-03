extends Node


var items: Array[ItemResource] = []
var equipped_item: ItemResource = null
var current_index: int = 0

signal equipped_changed
signal inventory_changed
var equipped: Dictionary = {}   # EquipSlot -> ItemResource


func _ready():
	#Dialogic.signal_event.connect(_on_dialogic_signal)
	var item_inicial = load("res://Resource/revolver.tres") #("res://Resource/flashlight.tres")
	var lanterna = load("res://Resource/flashlight.tres") #("res://Resource/flashlight.tres")


	if item_inicial:
		add_item(item_inicial)
		add_item(lanterna)
		print("Item inicial adicionado: ", item_inicial.name)
	else:
		print("ERRO: Não achei o item inicial no caminho especificado!")


func is_equipped(item: ItemResource) -> bool:
	return item != null and equipped.get(item.equip_slot) == item

func get_equipped(slot: ItemResource.EquipSlot) -> ItemResource:
	return equipped.get(slot)

func toggle_equip(item: ItemResource) -> void:
	if item.type != ItemResource.Type.EQUIPMENT:
		return
	if is_equipped(item):
		equipped.erase(item.equip_slot)
	else:
		equipped[item.equip_slot] = item
	equipped_changed.emit()

func has_ranged_weapon_equipped() -> bool:
	var w = get_equipped(ItemResource.EquipSlot.HAND)
	return w != null and w.equip_kind == ItemResource.EquipKind.WEAPON_RANGED

func has_light_equipped() -> bool:
	var l = get_equipped(ItemResource.EquipSlot.CHEST)
	return l != null and l.equip_kind == ItemResource.EquipKind.LIGHT

func _on_dialogic_signal(argumento: String):
	if argumento == "entregar_dinheiro":

		var item_dinheiro = load("res://Resource/dinheiro.tres") 
		
		if item_dinheiro:
			add_item(item_dinheiro) # Adiciona no inventário!
			print("Dinheiro adicionado com sucesso!")
		else:
			print("ERRO: Arquivo do item de dinheiro não encontrado.")

func get_equip_kind() -> ItemResource.EquipKind:
	if equipped_item == null:
		return ItemResource.EquipKind.NONE
	return equipped_item.equip_kind

func has_melee_weapon_equipped() -> bool:
	return get_equip_kind() == ItemResource.EquipKind.WEAPON_MELEE

func use_item(item: ItemResource) -> bool:
	if item.type != ItemResource.Type.CONSUMABLE:
		return false
	PlayerStats.heal(item.heal_amount)
	remove_item(item)
	return true

func has_item(item_procurado: Resource) -> bool:
	if item_procurado == null: 
		return false
	
	for i in items:
		if i.resource_path != "" and i.resource_path == item_procurado.resource_path:
			return true
			
		if "name" in i and "name" in item_procurado:
			var nome_no_bolso = i.name.strip_edges().to_lower()
			var nome_procurado = item_procurado.name.strip_edges().to_lower()
			
			if nome_no_bolso == nome_procurado:
				return true
				
	return false

func add_item(item_resource: ItemResource):
	items.append(item_resource)
	inventory_changed.emit() 
	
func next_item():
	if items.is_empty():
		return
	
	current_index = (current_index + 1) % items.size()
	inventory_changed.emit() 

func prev_item():
	if items.is_empty():
		return

	current_index = (current_index - 1 + items.size()) % items.size()
	inventory_changed.emit() 

func get_current_item() -> ItemResource:
	if items.is_empty():
		return null
	
	return items[current_index]

func remove_item(item_procurado: Resource):
	if items.is_empty(): 
		return
	
	var index_encontrado = -1
	
	for i in range(items.size()):
		if items[i] == item_procurado or items[i].name == item_procurado.name:
			index_encontrado = i
			break
	
	if index_encontrado != -1:
		if equipped_item == items[index_encontrado]:
			equipped_item = null
			equipped_changed.emit()
		items.remove_at(index_encontrado)
		
		if items.is_empty():
			current_index = 0
		elif current_index >= items.size():
			current_index = items.size() - 1
			
		inventory_changed.emit()
		print("Item removido com sucesso!")
	else:
		print("ERRO: Tentei remover o item mas ele não foi encontrado na lista!")

func remover_item_por_nome(nome_procurado: String):
	for i in range(items.size()):
		if items[i].name == nome_procurado:
			items.remove_at(i) 
			
			if current_index >= items.size():
				current_index = max(0, items.size() - 1)
				
			inventory_changed.emit() 
			return 
