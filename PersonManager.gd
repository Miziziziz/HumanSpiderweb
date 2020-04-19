extends Node2D

var people = []
var active_ind = 0

onready var cam = $Camera2D
var default_zoom_level = 1.2
func _ready():
	cam.zoom = Vector2.ONE * default_zoom_level
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for child in get_children():
		if "is_active" in child:
			people.append(child)
			child.connect("travelled", $PlayerUI/Stomach, "decrease")
			child.connect("dead", self, "check_if_dead")
		if child.has_method("eat"):
			child.connect("ate_food", $PlayerUI/Stomach, "increase")
	set_all_people_inactive()
	people[active_ind].set_person_active()

func set_all_people_inactive():
	for person in people:
		person.set_person_inactive()

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		for node in get_tree().get_nodes_in_group("instanced"):
			node.queue_free()
		
	if Input.is_action_just_pressed("switch_person_left"):
		active_ind -= 1
		if active_ind < 0:
			active_ind = people.size() - 1
		set_all_people_inactive()
		people[active_ind].set_person_active()
	if Input.is_action_just_pressed("switch_person_right"):
		active_ind += 1
		active_ind %= people.size()
		set_all_people_inactive()
		people[active_ind].set_person_active()
	
	var avg_pos = Vector2()
	for person in people:
		avg_pos += person.global_position
	avg_pos /= people.size()
	cam.global_position = avg_pos

func check_if_dead():
	for person in people:
		if !person.is_dead:
			return
	$PlayerUI2/RestartMessage.show()
