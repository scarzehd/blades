extends Resource
class_name AIBehavior

@export var actions:Array[AIAction]
@export var interrupt_overrides:Array[StringName]

var current_action:int

func _check_conditions(conditions:AIConditions) -> bool:
	return false

func start(enemy:Enemy):
	if not actions.size() > 0:
		return
	current_action = 0
	actions[current_action]._start(enemy)

func end(enemy:Enemy, interrupt_id:StringName = ""):
	if interrupt_overrides.has(interrupt_id):
		return
	actions[current_action]._end(enemy, interrupt_id)

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
