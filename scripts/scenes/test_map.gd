extends Node3D

@onready var generator: TileGenerator = %Generator

func _on_generator_generation_finished() -> void:
	if not is_node_ready():
		await ready
	generator.get_parent().remove_child(generator)
	add_child(generator)
	#%TestEnemy.enemy_ai.start_ai()
