extends Area3D
class_name InteractionManager

signal target_changed(target: Interactable)
signal menu_opened(options: Array[String])
signal menu_index_changed(index: int)
signal menu_closed
signal message_requested(text: String)

@export var use_facing_check := true
@export var facing_threshold := 0.3

var player: CharacterBody3D
var nearby: Array[Interactable] = []
var current: Interactable = null
var menu_open := false
var menu_index := 0
var options: Array[String] = []

func _ready():
	player = get_parent() as CharacterBody3D
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(a: Area3D) -> void:
	print("Manager detectou: ", a.name)
	if a is Interactable and not nearby.has(a):
		nearby.append(a)

func _on_area_exited(a: Area3D) -> void:
	nearby.erase(a)

func _physics_process(_delta):
	if menu_open or player == null:
		return
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
	options = current.get_actions()
	menu_opened.emit(options)

func close_menu():
	menu_open = false
	current = null
	target_changed.emit(null)
	menu_closed.emit()

func handle_input():
	if not menu_open:
		return
	if Input.is_action_just_pressed("ui_down"):
		menu_index = (menu_index + 1) % options.size()
		menu_index_changed.emit(menu_index)
	elif Input.is_action_just_pressed("ui_up"):
		menu_index = (menu_index - 1 + options.size()) % options.size()
		menu_index_changed.emit(menu_index)
	elif Input.is_action_just_pressed("ui_accept"):
		var finished: bool = current.perform_action(options[menu_index], self)
		if finished:
			close_menu()
	elif Input.is_action_just_pressed("ui_cancel"):
		close_menu()
