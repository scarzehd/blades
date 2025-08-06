extends Resource
class_name AIBehavior

@export var interrupt_overrides:Array[StringName]
@export var conditions:Array[AICondition]

func check_conditions(state:AIState) -> bool:
	for condition in conditions:
		if not condition._check_condition(state):
			return false
	
	return true

func start(enemy:Enemy):
	_start(enemy)

func _start(enemy:Enemy):
	pass

func end(enemy:Enemy, interrupt_id:StringName = "") -> bool:
	if interrupt_overrides.has(interrupt_id): return false
	_end(enemy)
	return true

func _end(enemy:Enemy):
	pass

func _update(enemy:Enemy, delta:float) -> bool:
	return false
