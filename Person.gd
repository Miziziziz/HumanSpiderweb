extends RigidBody2D

onready var anim_player = $Graphics/AnimationPlayer

export var move_force = 1.0

var facing_right = true

signal travelled
signal dead 

var is_dead = false
var is_active = true

func _ready():
	$StartFireTimer.connect("timeout", self, "finish_burn")

func set_person_active():
	is_active = true
	mass = 0.1
	last_pos = global_position

func set_person_inactive():
	is_active = false
	mass = 0.01

var last_pos = Vector2()
func _physics_process(delta):
	if !is_active or is_dead:
		return
	var move_vec = Vector2()
	if Input.is_action_pressed("move_down"):
		move_vec += Vector2.DOWN
	if Input.is_action_pressed("move_up"):
		move_vec += Vector2.UP
	if Input.is_action_pressed("move_right"):
		move_vec += Vector2.RIGHT
	if Input.is_action_pressed("move_left"):
		move_vec += Vector2.LEFT
	move_vec = move_vec.normalized()
	
	apply_central_impulse(move_vec * move_force)
	
	if facing_right and move_vec.x < 0:
		flip()
	elif !facing_right and move_vec.x > 0:
		flip()
	
	if move_vec == Vector2.ZERO:
		anim_player.play("idle")
	else:
		anim_player.play("walk")
	emit_signal("travelled", global_position.distance_to(last_pos))
	last_pos = global_position

func flip():
	$Graphics.scale.x *= -1
	facing_right = !facing_right

func burn():
	die()

func die():
	if is_dead:
		return
	anim_player.play("die")
	is_dead = true
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Hitbox/CollisionShape2D.call_deferred("set_disabled", true)
	$StartFireTimer.start()
	$Graphics/Body/Fire.emitting = true
	emit_signal("dead")

func finish_burn():
	$Graphics/Body/Fire.emitting = false
	$Graphics.modulate = Color.black
