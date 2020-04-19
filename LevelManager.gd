extends Node

var level_list = [
	"res://levels/Tutorial1.tscn",
	"res://levels/TutorialFood.tscn",
	"res://levels/TutorialGuard.tscn",
]
var level_ind = 0
func load_next_level():
	level_ind += 1
	level_ind %= level_list.size()
	get_tree().change_scene(level_list[level_ind])
