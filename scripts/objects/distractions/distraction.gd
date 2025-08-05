extends RigidBody3D
class_name Distraction

@onready var enemy_sound_maker: EnemySoundMaker = %EnemySoundMaker

var has_played:bool = false

func _on_body_entered(body: Node) -> void:
	if body is StaticBody3D and not has_played:
		enemy_sound_maker.play_sound()
		has_played = true


func _on_lifetime_timer_timeout() -> void:
	await create_tween().tween_property(self, "scale", Vector3(0.001, 0.001, 0.001), 1).finished
	queue_free()
