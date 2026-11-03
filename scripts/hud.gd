extends CanvasLayer

@onready var health_label: Label = $HealthLabel

func _ready() -> void:
	PlayerStats.health_changed.connect(_update_health)
	_update_health()  # mostra o valor inicial

func _update_health() -> void:
	health_label.text = "HP: %d / %d" % [PlayerStats.health, PlayerStats.max_health]
