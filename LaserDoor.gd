extends Area2D

var disabled = false

func disable():
	disabled = true
	for child in get_children():
		child.hide()

func _ready():
	connect("body_entered", self, "burn_target")
	connect("area_entered", self, "burn_target_area")

func burn_target(coll):
	if disabled:
		return
	if coll.has_method("burn"):
		coll.burn()

func burn_target_area(coll):
	if disabled:
		return
	if coll.has_method("burn"):
		coll.burn()
