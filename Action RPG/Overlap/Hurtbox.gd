extends Area2D

const hit_effect = preload("res://Effects/HitEffect.tscn")

var invincible = false setget set_invincible

signal invincibility_started
signal invincibility_ended

onready var timer = $Timer

func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var hit_effect_instance = hit_effect.instance()
	get_parent().add_child(hit_effect_instance)
	hit_effect_instance.global_position = get_parent().global_position

func _on_Timer_timeout():
	# self is needed to use setter
	self.invincible = false

func _on_Hurtbox_invincibility_started():
	set_deferred("monitorable", false)

func _on_Hurtbox_invincibility_ended():
	set_deferred("monitorable", true)
