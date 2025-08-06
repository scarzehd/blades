extends AIBehavior
class_name AIRoamRadiusBehavior

@export var radius:float
@export var delay:float = 1

var waited = false
var target_point:Vector3

func _start():
	var timer = get_tree().create_timer(delay, false, true)
	timer.timeout.connect(func(): waited = true)
	while true:
		var theta:float = randf() * 2 * PI
		var point = (Vector3(cos(theta), 0, sin(theta)) * sqrt(randf()) * radius) + enemy.global_position
		#target_point = NavigationServer3D.map_get_closest_point(enemy.get_world_3d().get_navigation_map(), point)
		target_point = point
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

func _update(delta:float):
	if not waited:
		return
	var next_pos := enemy.navigation_agent.get_next_path_position()
	enemy.velocity = enemy.global_position.direction_to(next_pos) * enemy.speed
	if enemy.global_position != next_pos:
		var look_at_target = Vector3(next_pos.x, enemy.global_position.y, next_pos.z)
		look_at_target -= enemy.global_position
		look_at_target = (-enemy.global_basis.z).slerp(look_at_target, 0.1)
		look_at_target += enemy.global_position
		enemy.look_at(look_at_target)

func _end():
	enemy.velocity = Vector3.ZERO
	waited = false
