extends AICondition
class_name AIDetectedPlayerCondition

@export var heard_player_window:float = 0
@export var seen_player_window:float = 0
@export var both:bool = false

func _check_condition(conditions:AIState) -> bool:
	var seen_player = conditions.seen_player_within(seen_player_window)
	var heard_player = conditions.heard_player_within(heard_player_window)
	
	var done_both = seen_player and heard_player
	var done_either = seen_player or heard_player
	if (both and done_both) or (not both and done_either):
		return true
	return false
