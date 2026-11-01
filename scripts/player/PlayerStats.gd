# PlayerStats.gd
extends Node

var max_health: int = 10
var health: int = 10
var status: String = "Ok"

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		get_tree().quit()

func exit_game():
	if Input.is_action_pressed("exit"):
		get_tree().quit()
