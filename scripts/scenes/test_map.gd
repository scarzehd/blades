extends Node3D

@onready var generator: Node3D = %Generator

func _on_generator_generation_finished() -> void:
	generator.get_parent().remove_child(generator)
	add_child(generator)
	
