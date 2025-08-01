extends Node3D
class_name Transform3DTo2D

@export var path:NodePath

func _process(delta: float) -> void:
	var target = get_node(path)
	if target is not CanvasItem:
		return
	var camera = get_viewport().get_camera_3d()
	
	var behind_camera = camera.is_position_behind(global_position)
	target.visible = not behind_camera
	if behind_camera:
		return
	target.position = camera.unproject_position(global_position)
