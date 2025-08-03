extends PlayerDetection
class_name SightConeDetection

@export var sight_distance:float
@export_range(0, 360, 1, "radians_as_degrees") var sight_angle:float
@export_flags_3d_physics var collision_layers:int

func _detect_player() -> bool:
	var player_pos = Globals.player.global_position
	print(-global_transform.basis.z)
	if player_pos.distance_to(global_position) > sight_distance:
		return false
	
	var angle_to_player = (-global_transform.basis.z).angle_to(player_pos - global_position)
	
	print(rad_to_deg(angle_to_player))
	
	if angle_to_player > sight_angle:
		return false
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, player_pos, collision_layers)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is Player:
		return true
	
	return false
