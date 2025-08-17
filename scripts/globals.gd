extends Node

var player:Player

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_reset"):
		get_tree().reload_current_scene()
