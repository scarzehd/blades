extends Node3D
class_name AICondition

@export var threshold:float = 1.0
@export var percentage:bool = false

func _check_condition(_ai_state:AIState) -> bool:
	return true
