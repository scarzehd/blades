extends AIAction
class_name AIPursueAction

var last_seen_pos:Vector3

func _start(enemy:Enemy):
	last_seen_pos = Globals.player.global_position

func _end(enemy:Enemy, interrupt_id:StringName = ""):
	enemy.velocity = Vector3.ZERO

func _update(enemy:Enemy, delta:float) -> bool:
	if enemy.player_detected:
		last_seen_pos = Globals.player.global_position
	
	enemy.navigation_agent.target_position = last_seen_pos
	
	var next_pos = enemy.navigation_agent.get_next_path_position()
	
	enemy.velocity = enemy.global_position.direction_to(next_pos) * enemy.speed
	enemy.look_at(Vector3(next_pos.x, enemy.global_position.y, next_pos.z))
	
	if enemy.navigation_agent.is_navigation_finished() and not enemy.player_detected:
		return false
	
	return true
