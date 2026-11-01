extends Node


var items: Array[ItemResource] = []

var current_index: int = 0

signal inventory_changed
#
#func _ready():
	#Dialogic.signal_event.connect(_on_dialogic_signal)
	#var item_inicial = load("res://Resource/flashlight.tres") #("res://Resource/flashlight.tres")

	#if item_inicial:
		#add_item(item_inicial)
		#print("Item inicial adicionado: ", item_inicial.name)
	#else:
		#print("ERRO: Não achei o item inicial no caminho especificado!")

func _on_dialogic_signal(argumento: String):
	if argumento == "entregar_dinheiro":

		var item_dinheiro = load("res://Resource/dinheiro.tres") 
		
		if item_dinheiro:
			add_item(item_dinheiro) # Adiciona no inventário!
			print("Dinheiro adicionado com sucesso!")
		else:
			print("ERRO: Arquivo do item de dinheiro não encontrado.")
			


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
