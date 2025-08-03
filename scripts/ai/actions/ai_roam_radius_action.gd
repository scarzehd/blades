extends AIAction
class_name AIRoamRadiusAction

@export var radius:float

var target_point:Vector3

func _start(enemy:Enemy):
	while true:
		var theta:float = randf() * 2 * PI
		var point = (Vector3(cos(theta), 0, sin(theta)) * sqrt(randf()) * radius) + enemy.global_position
		target_point = NavigationServer3D.map_get_closest_point(enemy.get_world_3d().get_navigation_map(), point)
		enemy.navigation_agent.target_position = target_point
		var path = enemy.navigation_agent.get_current_navigation_path()
		var distance:float = 0
		var previous:Vector3
		for vector in path:
			distance += previous.distance_to(vector)
			previous = vector
		if distance > radius:
			continue
		break

func _update(enemy:Enemy, delta:float) -> bool:
	var next_pos := enemy.navigation_agent.get_next_path_position()
	enemy.velocity = enemy.global_position.direction_to(next_pos) * enemy.speed
	if enemy.global_position != next_pos:
		enemy.look_at(Vector3(next_pos.x, enemy.global_position.y, next_pos.z))
	
	if enemy.navigation_agent.is_navigation_finished():
		return false
	
	return true

func _end(enemy:Enemy, _interrupt_id:StringName = ""):
	enemy.velocity = Vector3.ZERO
