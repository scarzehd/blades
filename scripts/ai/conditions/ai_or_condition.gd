extends AICondition
class_name AIOrCondition

@export var conditions:Array[AICondition]

func _check_condition(ai_state:AIState) -> bool:
	for condition in conditions:
		if condition._check_condition(ai_state):
			return true
	
	return false
