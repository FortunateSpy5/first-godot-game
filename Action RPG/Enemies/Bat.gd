extends KinematicBody2D

export var ACCELERATION = 5
export var FRICTION = 8
export var MAX_SPEED = 50
export var KNOCKBACK = 200

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
const enemy_death_effect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

onready var state = pick_new_state([IDLE, WANDER])

onready var stats = $Stats
onready var player_detection = $PlayerDetection
onready var bat_sprite = $Sprite
onready var hurtbox = $Hurtbox
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController

func _ready():
	randomize()
	bat_sprite.frame = rand_range(0, bat_sprite.frames.get_frame_count("Fly")-1)

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			seek_player()
			if wander_controller.get_time_left() == 0:
				state = pick_new_state([IDLE, WANDER])
				wander_controller.start_wander_timer(rand_range(2, 4))
			
		WANDER:
			seek_player()
			if wander_controller.get_time_left() == 0:
				state = pick_new_state([IDLE, WANDER])
				wander_controller.start_wander_timer(rand_range(2, 4))
			var direction = global_position.direction_to(wander_controller.target_position)
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
			if global_position.distance_to(wander_controller.target_position) < wander_controller.wander_range / 10:
				state = pick_new_state([IDLE, WANDER])
				wander_controller.start_wander_timer(rand_range(2, 4))
			
		CHASE:
			var player = player_detection.player
			if player != null:
				var direction = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
			else:
				state = IDLE
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * MAX_SPEED
	bat_sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)

func seek_player():
	if player_detection.can_see_player():
		state = CHASE

func pick_new_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * KNOCKBACK
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.2)

func _on_Stats_no_health():
	create_death_effect()
	queue_free()

func create_death_effect():
	var enemy_death_effect_instance = enemy_death_effect.instance()
	get_parent().add_child(enemy_death_effect_instance)
	enemy_death_effect_instance.position = self.position
	enemy_death_effect_instance.set_offset(Vector2(0,-14))
