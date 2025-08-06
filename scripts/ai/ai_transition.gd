extends Node3D
class_name AITransition

@export var target_behavior:AIBehavior

var conditions:Array[AICondition]

func _ready() -> void:
	for child in get_children():
		if child is AICondition:
			conditions.append(child)

func check_conditions(state:AIState) -> bool:
	for condition in conditions:
		if not condition._check_condition(state):
			return false
	
	return true
