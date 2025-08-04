extends PlayerDetection
class_name SightConeDetection

@export var sight_distance:float
@export var close_sight_distance:float
@export_range(0, 360, 1, "radians_as_degrees") var sight_angle:float
@export_range(0, 360, 1, "radians_as_degrees") var close_sight_angle:float
@export_flags_3d_physics var collision_layers:int

func _detect_player() -> bool:
	var player_pos = Globals.player.global_position
	var distance = player_pos.distance_to(global_position)
	if distance > sight_distance:
		return false
	
	var angle_to_player = (-global_transform.basis.z).angle_to(player_pos - global_position)
	
	var current_sight_angle = sight_angle
	if distance <= close_sight_distance:
		current_sight_angle = close_sight_angle
	
	if angle_to_player > current_sight_angle:
		return false
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, player_pos, collision_layers)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is Player:
		return true
	
	return false
