extends AICondition
class_name AIDetectedPlayerCondition

@export var heard_player_window:float = 0
@export var seen_player_window:float = 0
@export var both:bool = false

func _check_condition(conditions:AIState) -> bool:
	var seen_player = conditions.last_seen_player + seen_player_window >= Time.get_unix_time_from_system()
	var heard_player = conditions.last_heard_player + heard_player_window >= Time.get_unix_time_from_system()
	
	var done_both = seen_player and heard_player
	var done_either = seen_player or heard_player
	if (both and done_both) or (not both and done_either):
		return true
	return false
