extends Node2D

const grass_effect = preload("res://Effects/GrassEffect.tscn")

func create_grass_effect():
	var grass_effect_instance = grass_effect.instance()
	get_parent().add_child(grass_effect_instance)
	grass_effect_instance.position = self.position

func _on_Area2D_area_entered(_area):
	create_grass_effect()
	queue_free()
