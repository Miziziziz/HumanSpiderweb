extends Area2D

func _ready():
	connect("body_entered", self, "on_body_entered")


func on_body_entered(body):
	if body.has_method("eat"):
		body.eat()
		queue_free()
