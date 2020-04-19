extends Area2D


func burn():
	get_parent().burn()
	$CollisionShape2D.call_deferred("set_disabled", true)
