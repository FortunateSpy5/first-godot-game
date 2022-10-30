extends KinematicBody2D

enum {
	MOVE,
	ROLL,
	ATTACK
}

const player_hurt_sound = preload("res://Player/PlayerHurtSound.tscn")

var stats = PlayerStats
var state = MOVE
var velocity = Vector2.ZERO # Initialize velocity
var input_vector = Vector2.ZERO
var queue_attack = false
var direction = Vector2.ZERO

export var ACCELERATION = 10
export var FRICTION = 8
export var MAX_SPEED = 100
export var ROLL_SPEED = 100

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var sword_hitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blink_animation_player = $BlinkAnimationPlayer

func _ready():
	sword_hitbox.get_child(0).disabled = true
	stats.connect("no_health", self, "queue_free")
	animation_tree.active = true

func _input(_event):
	randomize()
	# Project -> Project Settins -> Input Map -> Add action and key
	if Input.is_action_just_pressed("attack"):
		sword_hitbox.knockback_vector = direction
		if state == ROLL:
			queue_attack = true
		else:
			state = ATTACK
	if Input.is_action_just_released("roll") and input_vector != Vector2.ZERO:
		velocity = input_vector * ROLL_SPEED
		state = ROLL
		hurtbox.start_invincibility(0.5)
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	

func _physics_process(_delta): 
	# this function once every frame
	# delta -> duration of last frame
	match state:
		MOVE:
			move_state()
		ROLL:
			roll_state()
		ATTACK:
			attack_state()

func move_state():
	# Make sure diagonal speed is same as horizontal and vertical by normalizing the vector
	if input_vector != Vector2.ZERO:
		direction = input_vector
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_state.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	move()

func roll_state():
	animation_state.travel("Roll")
	move()
	
func attack_state():
	animation_state.travel("Attack")
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	move()

func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	velocity = Vector2.ZERO
	if queue_attack:
		state = ATTACK
		queue_attack = false
	else:
		state = MOVE

func attack_animation_finished():
	state = MOVE

func _on_Hurtbox_area_entered(area):
	if not hurtbox.invincible:
		stats.health -= area.damage
		blink_animation_player.play("Start")
		hurtbox.start_invincibility(0.6) # sec
		hurtbox.create_hit_effect()
		get_tree().current_scene.add_child(player_hurt_sound.instance())

func _on_Hurtbox_invincibility_ended():
	blink_animation_player.play("Stop")
