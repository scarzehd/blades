extends AICondition
class_name AIAggroCondition

@export var threshold:float = 1.0
@export var percentage:bool = false
@export var when_above:bool = true

func _check_condition(ai_state:AIState) -> bool:
	var aggro_threshold = threshold # Copy this because AIConditions must be stateless
	if percentage:
		aggro_threshold *= ai_state.enemy.aggro_threshold
	
	if when_above:
		return ai_state.aggro >= aggro_threshold
	
	return ai_state.aggro <= aggro_threshold
	
	return false
