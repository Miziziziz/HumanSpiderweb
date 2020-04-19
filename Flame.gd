extends Area2D


var speed = 200

func _ready():
	connect("body_entered", self, "burn_target")
	connect("area_entered", self, "burn_target_area")
func init():
	$Sprite.global_rotation = 0

func _physics_process(delta):
	if scale.x < 2.0:
		scale += Vector2.ONE * delta
	translate(Vector2.RIGHT.rotated(global_rotation) * speed * delta)
#	if coll:
#		if coll.collider.has_method("burn"):
#			coll.collider.burn()
#		queue_free()

func burn_target(coll):
	if coll.has_method("burn"):
		coll.burn()
	queue_free()

func burn_target_area(coll):
	if coll.has_method("burn"):
		coll.burn()
	queue_free()
