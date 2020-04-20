extends Node2D


func play():
	get_child(randi() % get_child_count()).play()
