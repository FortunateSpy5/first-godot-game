extends Node

export var max_health = 1
onready var health = max_health setget set_health

signal no_health
signal health_change(value)

func set_health(value):
	health = clamp(value, 0, max_health)
	emit_signal("health_change", health)
	if health <= 0:
		emit_signal("no_health")
