extends Area2D

var person_scanned = false
var last_state = false
func _physics_process(delta):
	person_scanned = get_overlapping_bodies().size() > 0
	if person_scanned:
		if !last_state:
			$BeepSound.play()
		$Label.text = "id accepted"
	else:
		$Label.text = "scanning"
	last_state = person_scanned
