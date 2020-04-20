extends RigidBody2D

func _ready():
	$FinishFireTimer.connect("timeout", self, "finish_burn")

var last_velo = Vector2()
var last_velo_len = 0
func _process(delta):
	$Graphics/Shadow.global_position = global_position + Vector2(0, 10)
	$Graphics/Shadow.global_rotation = 0
	var velo = linear_velocity
	if velo.length() > last_velo.length() + 10.0 or rad2deg(velo.angle_to(last_velo)) > 10:
		$GooshSounds.play()
	last_velo = velo

signal ate_food
var is_dead = false
func eat():
	emit_signal("ate_food")
	$Head/FoodParticles.emitting = true
	$MunchSound.play()

func burn():
	is_dead = true
	$FinishFireTimer.start()
	$Fire.emitting = true

func finish_burn():
	$Fire.emitting = false
	modulate = Color.black
