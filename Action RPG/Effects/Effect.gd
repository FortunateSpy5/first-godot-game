extends AnimatedSprite

func _ready():
	var _t = connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	play("Animate")

func _on_AnimatedSprite_animation_finished():
	queue_free()
