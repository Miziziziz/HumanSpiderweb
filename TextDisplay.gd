extends CanvasLayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	if Input.is_action_just_pressed("continue"):
		LevelManager.load_next_level()
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
