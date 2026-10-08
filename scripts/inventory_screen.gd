extends CanvasLayer

@onready var life_indicator = $UI_Elements/StatusBox/LifeIndicator
@onready var item_name_label = $UI_Elements/CarouselItemInfo/ItemNameLabel
@onready var item_desc_label = $UI_Elements/CarouselItemInfo/ItemDescriptionLabel
@onready var item_mount = $UI_Elements/SubViewportContainer/SubViewport/ItemMount
@onready var triangulo_branco = $TrianguloBranco
@onready var triangulo_branco_2 = $TrianguloBranco2

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

	if visible:
		inventoryActive = true

		if Input.is_action_just_pressed("ui_right"):
			InventoryManager.next_item() 
			
		if Input.is_action_just_pressed("ui_left"):
			InventoryManager.prev_item()
	else:
		inventoryActive = false



func update_display():
	
	var item_data = InventoryManager.get_current_item()
	
	if item_data == null:

		item_name_label.text = "Inventário Vazio"
		item_desc_label.text = "você ainda não pegou nenhum item"
		if current_3d_item:
			current_3d_item.queue_free()
			current_3d_item = null
		return


	item_name_label.text = item_data.name
	item_desc_label.text = item_data.description
	

	if current_3d_item != null:
		current_3d_item.queue_free()
		current_3d_item = null

	var new_scene = load(item_data.scene_3d_path)
	
	if new_scene:
		current_3d_item = new_scene.instantiate()

		item_mount.add_child(current_3d_item)
	else:
		print("ERRO: Não foi possível carregar a cena do item: ", item_data.scene_3d_path)
	

	if PlayerStats.health >= 8:
		life_indicator.play("ok")
	elif PlayerStats.health >= 4:
		life_indicator.play("machucado")
	else:
		life_indicator.play("perigo")
	

func toggle_inventory():
	visible = not visible
	
	get_tree().paused = visible

	if visible:
		update_display() 

		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:

		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
