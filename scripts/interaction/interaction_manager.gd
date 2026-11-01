extends Area3D
class_name InteractionManager

signal target_changed(target: Interactable)
signal menu_opened(options: Array[String])
signal menu_index_changed(index: int)
signal menu_closed
signal dialogue_started
signal message_requested(text: String)

@export var use_facing_check := true
@export var facing_threshold := 0.3

var player: CharacterBody3D
var nearby: Array[Interactable] = []
var current: Interactable = null
var menu_open := false
var menu_index := 0
var options: Array[String] = []
var dialogue_active := false

func _ready():
	player = get_parent() as CharacterBody3D
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func start_dialogue(resource: DialogueResource, start: String = "start") -> void:
	if resource == null:
		close_menu()
		return
	dialogue_active = true
	dialogue_started.emit()
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)
	DialogueManager.show_dialogue_balloon(resource, start)

func _on_dialogue_ended(_resource: DialogueResource) -> void:
	dialogue_active = false
	close_menu()  # emite menu_closed e o InteractState volta para o idle

func _on_area_entered(a: Area3D) -> void:
	print("Manager detectou: ", a.name)
	if a is Interactable and not nearby.has(a):
		nearby.append(a)

func _on_area_exited(a: Area3D) -> void:
	nearby.erase(a)

func _physics_process(_delta):
	if menu_open or player == null:
		return

	for idx in range(nearby.size() - 1, -1, -1):
		if not is_instance_valid(nearby[idx]):
			nearby.remove_at(idx)

	if current != null and not is_instance_valid(current):
		current = null
		target_changed.emit(null)

	var best: Interactable = _find_best_target()
	if best != current:
		current = best
		print("Alvo atual: ", current)
		target_changed.emit(current)

func _find_best_target() -> Interactable:
	var best: Interactable = null
	var best_dist: float = INF
	var forward: Vector3 = -player.global_transform.basis.z
	for i in nearby:
		if not is_instance_valid(i):
			continue
		var to_item: Vector3 = i.global_position - player.global_position
		if use_facing_check and forward.dot(to_item.normalized()) < facing_threshold:
			continue
		var d: float = to_item.length()
		if d < best_dist:
			best_dist = d
			best = i
	return best

func has_target() -> bool:
	return current != null and is_instance_valid(current)

func open_menu():
	if not has_target():
		menu_closed.emit()
		return
	menu_open = true
	menu_index = 0

	# Se o alvo é um NPC/objeto de diálogo, pula o menu e conversa direto
	if current is DialogueInteractable:
		start_dialogue(current.dialogue_resource, current.dialogue_start)
		return

	options = current.get_actions()
	menu_opened.emit(options)

func close_menu():
	menu_open = false
	current = null
	target_changed.emit(null)
	menu_closed.emit()

func forget(i: Interactable) -> void:
	nearby.erase(i)
	if current == i:
		current = null
		target_changed.emit(null)

func handle_input():
	if not menu_open or dialogue_active:
		return
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("move_forward") or Input.is_action_just_pressed("turn_right"):
		menu_index = (menu_index + 1) % options.size()
		menu_index_changed.emit(menu_index)
	elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("move_backward") or Input.is_action_just_pressed("turn_left"):
		menu_index = (menu_index - 1 + options.size()) % options.size()
		menu_index_changed.emit(menu_index)
	elif Input.is_action_just_pressed("ui_accept"):
		var finished: bool = current.perform_action(options[menu_index], self)
		if finished:
			close_menu()
	elif Input.is_action_just_pressed("ui_cancel"):
		close_menu()
