extends RigidBody2D


onready var pinjoint = $PinJoint2DA
var burned = false
func _ready():
	$StartFireTimer.connect("timeout", self, "finish_burn")
	$Ashes.hide()

func burn():
	if burned:
		return
	burned = true
	$Fire.emitting = true
	$StartFireTimer.start()
	$CollisionShape2D.call_deferred("set_disabled", true)

func finish_burn():
	var connected_to = pinjoint.get_node(pinjoint.node_a)
	if connected_to and connected_to.has_method("burn"):
		connected_to.burn()
	pinjoint.node_a = self.get_path()
	pinjoint.node_b = self.get_path()
	$Fire.emitting = false
	$Sprite.hide()
	$Ashes.show()
	
