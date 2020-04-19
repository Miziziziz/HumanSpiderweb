extends RigidBody2D

func _ready():
	$FinishFireTimer.connect("timeout", self, "finish_burn")

signal ate_food
var is_dead = false
func eat():
	emit_signal("ate_food")

func burn():
	is_dead = true
	$FinishFireTimer.start()
	$Fire.emitting = true

func finish_burn():
	$Fire.emitting = false
	modulate = Color.black
