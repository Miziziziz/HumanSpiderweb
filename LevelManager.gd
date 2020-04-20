extends Node

var level_list = [
	"res://levels/Intro.tscn",
	"res://levels/Tutorial1.tscn",
	"res://levels/TutorialFood.tscn",
	"res://levels/TutorialGuard.tscn",
	"res://levels/Scavenge.tscn",
	"res://levels/TutorialMultiplePeople.tscn",
	"res://levels/Churn.tscn",
	"res://levels/ServerRoom.tscn",
	"res://levels/Combination.tscn",
	"res://levels/RunForIt.tscn",
	"res://levels/Outro.tscn"
	
]

#func _process(delta):
#	if Input.is_action_just_pressed("continue"):
#		load_next_level()

var level_ind = 0
func load_next_level():
	level_ind += 1
	level_ind %= level_list.size()
	get_tree().change_scene(level_list[level_ind])
	$AudioStreamPlayer.play()
