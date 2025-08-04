extends Resource
class_name AIBehavior

@export var actions:Array[AIAction]
@export var interrupt_overrides:Array[StringName]
@export var conditions:Array[AICondition]

var current_action:int

func check_conditions(state:AIState) -> bool:
	for condition in conditions:
		if not condition._check_condition(state):
			return false
	
	return true

func start(enemy:Enemy):
	if not actions.size() > 0:
		return
	current_action = 0
	actions[current_action]._start(enemy)

func end(enemy:Enemy, interrupt_id:StringName = "") -> bool:
	if interrupt_overrides.has(interrupt_id):
		return false
	actions[current_action]._end(enemy, interrupt_id)
	return true

func update(enemy:Enemy, delta:float) -> bool:
	if not actions.size() > 0:
		return false
	var cont := actions[current_action]._update(enemy, delta)
	
	if not cont:
		actions[current_action]._end(enemy)
		current_action += 1
		if current_action >= actions.size():
			return false
		actions[current_action]._start(enemy)
	
	return true
