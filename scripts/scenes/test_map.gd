extends Node3D

@onready var generator: TileGenerator = %Generator

func _on_generator_generation_finished() -> void:
	if not is_node_ready():
		await ready
	generator.get_parent().remove_child(generator)
	add_child(generator)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is not Enemy:
			continue
		
		enemy.enemy_ai.start_ai()
	#%TestEnemy.enemy_ai.start_ai()
