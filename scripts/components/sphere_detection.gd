extends PlayerDetection
class_name SphereDetection

@export var detection_range := 3.0
@export var wall_bypass:bool = false
@export_flags_3d_physics var collision_layers:int

func _detect_player() -> bool:
	var player_pos = Globals.player.global_position
	if player_pos.distance_to(global_position) > detection_range:
		return false
	
	if wall_bypass:
		return true
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, player_pos, collision_layers)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is Player:
		return true
	
	return false
