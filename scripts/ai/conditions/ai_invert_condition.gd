extends AICondition
class_name AIInvertCondition

var condition:AICondition

func _ready() -> void:
	assert(get_children().size() > 0)
	var child = get_child(0)
	if child is AICondition:
		condition = get_child(0)

func _check_condition(ai_state:AIState) -> bool:
	return not condition._check_condition(ai_state)
