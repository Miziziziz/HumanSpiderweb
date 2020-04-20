extends Node2D




func _process(delta):
	var is_locked = false
	for child in $Scanners.get_children():
		if !child.person_scanned:
			is_locked = true
	if !is_locked:
		$LaserDoor.disable()
