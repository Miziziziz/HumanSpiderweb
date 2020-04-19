extends TextureRect

var stomach_size = 1.0
var decrease_per_step = 0.0005
var increase_per_eat = 0.5

var start_pos = 15
var start_size = 46

var end_pos = 56
var end_size = 5

signal died

func _ready():
	update_ui()

func decrease(amnt):
	stomach_size -= amnt * decrease_per_step
	if stomach_size <= 0:
		emit_signal("died")
	clamp(stomach_size, 0.0, 1.0)
	update_ui()

func increase():
	stomach_size += increase_per_eat
	clamp(stomach_size, 0.0, 1.0)
	update_ui()

func update_ui():
	var pos = lerp(end_pos, start_pos, stomach_size)
	var size = lerp(end_size, start_size, stomach_size)
	$StomachBar.rect_size.y = size
	$StomachBar.rect_position.y = pos
