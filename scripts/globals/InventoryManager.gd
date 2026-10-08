extends Node


var items: Array[ItemResource] = []

var current_index: int = 0

signal inventory_changed

func _ready():
	#Dialogic.signal_event.connect(_on_dialogic_signal)
	var item_inicial = load("res://Resource/pickup_flashlight.tres")

	if item_inicial:
		add_item(item_inicial) # Adiciona na lista
		print("Item inicial adicionado: ", item_inicial.name)
	else:
		print("ERRO: Não achei o item inicial no caminho especificado!")

func _on_dialogic_signal(argumento: String):
	# Verifica se o sinal que chegou foi o do dinheiro
	if argumento == "entregar_dinheiro":
		print("Dialogic avisou: Hora de dar o dinheiro!")
		# Carrega o arquivo do item do dinheiro (ajuste o caminho pro seu arquivo .tres)
		var item_dinheiro = load("res://Resource/dinheiro.tres") 
		
		if item_dinheiro:
			add_item(item_dinheiro) # Adiciona no inventário!
			print("Dinheiro adicionado com sucesso!")
		else:
			print("ERRO: Arquivo do item de dinheiro não encontrado.")
			
	# Você pode adicionar mais itens no futuro colocando mais 'elif' aqui!
	#elif argumento == "entregar_chave":
		# dar a chave...

func has_item(item_procurado: Resource) -> bool:
	if item_procurado == null: 
		return false
	
	for i in items:
		# 1. CHECAGEM SUPREMA: Os dois itens são o MESMO arquivo no HD?
		if i.resource_path != "" and i.resource_path == item_procurado.resource_path:
			return true
			
		# 2. CHECAGEM SECUNDÁRIA: Os nomes são iguais? 
		# (Usa strip_edges() para ignorar espaços em branco sem querer e to_lower() para ignorar maiúsculas)
		if "name" in i and "name" in item_procurado:
			var nome_no_bolso = i.name.strip_edges().to_lower()
			var nome_procurado = item_procurado.name.strip_edges().to_lower()
			
			if nome_no_bolso == nome_procurado:
				return true
				
	return false

# Função para adicionar um item (ex: quando você pega do chão)
func add_item(item_resource: ItemResource):
	items.append(item_resource)
	inventory_changed.emit() # Avisa a UI para recarregar
	
# Função para girar o carrossel para a DIREITA
func next_item():
	if items.is_empty():
		return
	
	current_index = (current_index + 1) % items.size()
	inventory_changed.emit() # Avisa a UI que o item mudou

# Função para girar o carrossel para a ESQUERDA
func prev_item():
	if items.is_empty():
		return

	current_index = (current_index - 1 + items.size()) % items.size()
	inventory_changed.emit() # Avisa a UI que o item mudou

# Função para a UI "perguntar" qual item ela deve mostrar
func get_current_item() -> ItemResource:
	if items.is_empty():
		return null
	
	return items[current_index]

# --- ADICIONE ISSO NO FIM DO INVENTORYMANAGER.GD ---

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
