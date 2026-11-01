extends RayCast3D

@export var prompt_label: Label
@export var cursor_sprite: AnimatedSprite2D 

func _physics_process(delta: float):
	var current_text = ""
	
	var cursor_state = "default" 
	
	if is_colliding():
		var hit = get_collider()
		
		if not hit.is_in_group("Dialog") and hit.get_parent().is_in_group("Dialog"):
			hit = hit.get_parent()
		
		if hit.is_in_group("Door") or (hit.get_parent() and hit.get_parent().is_in_group("Door")):
			current_text = "[E] Abrir/Fechar"
			cursor_state = "interact" 
			
			if Input.is_action_just_pressed("interact"):
				if hit.has_method("toggle_door"):
					hit.toggle_door()
				elif hit.get_parent().has_method("toggle_door"):
					hit.get_parent().toggle_door()
				else:
					print("ERRO: Nenhuma função 'toggle_door' encontrada na porta!")
		
		elif hit.is_in_group("Interagir"):
			current_text = "[E] Interagir"
			cursor_state = "interact"
			
			if Input.is_action_just_pressed("interact"):
				hit.mudar_fase()
		
		# --- COLETÁVEL ---
		elif hit.is_in_group("Collectable"):
			current_text = "[E] Pegar"
			cursor_state = "interact"
			
			if Input.is_action_just_pressed("interact"):
				var resource = hit.item_resource
				if resource:
					#PickupScreen.show_pickup_screen(resource)
					hit.queue_free()
		
		# --- DIÁLOGO ---
		elif hit.is_in_group("Dialog"):
			#if Dialogic.current_timeline == null:
				current_text = "[E] Conversar"
				cursor_state = "interact"
				
				if Input.is_action_just_pressed("interact"):
					var timeline_to_play = hit.get_timeline()
					#if timeline_to_play != "":
						#start_dialogue(timeline_to_play)

	if prompt_label:
		prompt_label.text = current_text
		if current_text == "": prompt_label.hide()
		else: prompt_label.show()

	if cursor_sprite:
		cursor_sprite.set_cursor(cursor_state)

#func start_dialogue(timeline_key: String):
	#if Dialogic.current_timeline != null: return
	#Dialogic.start(timeline_key)
