# PlayerStats.gd
extends Node

var max_health: int = 100
var health: int = 100
var status: String = "Ok"

signal health_changed
signal died

func take_damage(amount: int) -> void:

	health = max(health - amount, 0)
	health_changed.emit()
	print(health)
	if health <= 0:
		died.emit()

func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	health_changed.emit()

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		get_tree().quit()

func exit_game():
	if Input.is_action_pressed("exit"):
		get_tree().quit()
