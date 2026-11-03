extends CanvasLayer

@onready var life_indicator = $UI_Elements/StatusBox/LifeIndicator
@onready var item_name_label = $UI_Elements/CarouselItemInfo/ItemNameLabel
@onready var item_desc_label = $UI_Elements/CarouselItemInfo/ItemDescriptionLabel
@onready var item_mount = $UI_Elements/SubViewportContainer/SubViewport/ItemMount
@onready var triangulo_branco = $UI_Elements/SubViewportContainer/TrianguloBranco
@onready var triangulo_branco_2 = $UI_Elements/SubViewportContainer/TrianguloBranco2
@onready var equipped_label: Label = $UI_Elements/VBoxContainer/EquipedItem
@onready var action_hint: Label = $UI_Elements/CarouselItemInfo2/Comandos

@export var spin_speed: float = 0.5

var current_3d_item = null
var inventoryActive = false

var pos_inicial_t1: Vector2
var pos_inicial_t2: Vector2

func _ready():
	hide()
	
	if triangulo_branco and triangulo_branco_2:
		pos_inicial_t1 = triangulo_branco.position
		pos_inicial_t2 = triangulo_branco_2.position
	
	InventoryManager.inventory_changed.connect(update_display)
	InventoryManager.equipped_changed.connect(update_equipped_marker)
	PlayerStats.health_changed.connect(update_life)
	update_display()

func _input(event):
	
	if inventoryActive:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

			var largura_tela = get_viewport().get_visible_rect().size.x

			if event.position.x < (largura_tela / 2.0):
				InventoryManager.prev_item() # 
				
			else:
				InventoryManager.next_item()

func _process(delta):

	var tempo = Time.get_ticks_msec() / 1000.0 
	
	if triangulo_branco and triangulo_branco_2:
		
		triangulo_branco.position.x = pos_inicial_t1.x + sin(tempo * 4.0) * 7.0
		
		triangulo_branco_2.position.x = pos_inicial_t2.x + sin((tempo + -1.5) * -4.0) * 7.0

	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()

	if Input.is_action_just_pressed("ui_accept"):
		_primary_action()
	
	if visible:
		inventoryActive = true
		
		if current_3d_item:
			current_3d_item.rotate_y(spin_speed * delta)
		
		if Input.is_action_just_pressed("ui_right"):
			InventoryManager.next_item() 
			
		if Input.is_action_just_pressed("ui_left"):
			InventoryManager.prev_item()
	else:
		inventoryActive = false

func update_equipped_marker() -> void:
	var item = InventoryManager.get_current_item()
	equipped_label.visible = InventoryManager.is_equipped(item)
	if item == null:
		action_hint.text = ""
	else:
		match item.type:
			ItemResource.Type.CONSUMABLE: action_hint.text = "[U] Usar"
			ItemResource.Type.EQUIPMENT:
				action_hint.text = "[X] Desequipar" if InventoryManager.is_equipped(item) else "[E] Equipar"
			_: action_hint.text = ""

func update_life() -> void:
	if PlayerStats.health >= 80: life_indicator.play("ok")
	elif PlayerStats.health >= 40: life_indicator.play("machucado")
	else: life_indicator.play("perigo")

func _primary_action() -> void:
	var item = InventoryManager.get_current_item()
	if item == null:
		return
	match item.type:
		ItemResource.Type.CONSUMABLE: InventoryManager.use_item(item)
		ItemResource.Type.EQUIPMENT: InventoryManager.toggle_equip(item)

func update_display():
	
	var item_data = InventoryManager.get_current_item()
	
	if item_data == null:

		item_name_label.text = "Inventário Vazio"
		item_desc_label.text = "você ainda não pegou nenhum item"
		if current_3d_item:
			current_3d_item.queue_free()
			current_3d_item = null
			update_equipped_marker()
			update_life()
		return


	item_name_label.text = item_data.name
	item_desc_label.text = item_data.description
	

	if current_3d_item != null:
		current_3d_item.queue_free()
		current_3d_item = null

	if item_data.scene_3d:
		current_3d_item = item_data.scene_3d.instantiate()
		item_mount.add_child(current_3d_item)
		current_3d_item.rotation_degrees = item_data.initial_rotation
	else:
		print("ERRO: Não foi possível carregar a cena do item: ", item_data.scene_3d)
	

	if PlayerStats.health >= 8:
		life_indicator.play("ok")
	elif PlayerStats.health >= 4:
		life_indicator.play("machucado")
	else:
		life_indicator.play("perigo")
	update_equipped_marker()
	update_life()

func toggle_inventory():
	visible = not visible
	
	get_tree().paused = visible

	if visible:
		update_display() 

		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:

		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
