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
		enemy.navigation_agent.target_position = point
		var previous:Vector3 = enemy.navigation_agent.get_next_path_position()
		var path = enemy.navigation_agent.get_current_navigation_path()
		var distance:float = 0
		for vector in path:
			distance += previous.distance_to(vector)
			previous = vector
		if distance > radius:
			continue
		break

func _update(_delta:float):
	if not waited:
		return
	var next_pos := enemy.navigation_agent.get_next_path_position()
	enemy.set_desired_velocity(enemy.global_position.direction_to(next_pos) * enemy.speed)
	if enemy.global_position != next_pos:
		var look_at_target = Vector3(next_pos.x, enemy.global_position.y, next_pos.z)
		look_at_target -= enemy.global_position
		look_at_target = (-enemy.global_basis.z).slerp(look_at_target, 0.1)
		look_at_target += enemy.global_position
		enemy.look_at(look_at_target)
	
	if enemy.navigation_agent.is_navigation_finished():
		enemy.enemy_ai.start_behavior(self)

func _end():
	enemy.set_desired_velocity(Vector3.ZERO)
	waited = false
