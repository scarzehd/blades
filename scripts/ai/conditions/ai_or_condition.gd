extends AICondition
class_name AIOrCondition

var conditions:Array[AICondition]

func _ready() -> void:
	assert(get_children().size() > 0)
	for child in get_children():
		if child is AICondition:
			conditions.append(child)

func _check_condition(ai_state:AIState) -> bool:
	for condition in conditions:
		if condition._check_condition(ai_state):
			return true
	
	return false
