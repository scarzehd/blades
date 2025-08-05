extends RigidBody3D
class_name Distraction

@onready var enemy_sound_maker: EnemySoundMaker = %EnemySoundMaker

var has_played:bool = false

func _on_body_entered(body: Node) -> void:
	if body is StaticBody3D and not has_played:
		enemy_sound_maker.play_sound()
		has_played = true
