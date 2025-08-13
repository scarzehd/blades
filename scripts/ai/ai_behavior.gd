extends Node3D
class_name AIBehavior

@export var next_behavior:AIBehavior

var transitions:Array[AITransition]

var enemy:Enemy

var running:bool

func _ready() -> void:
	for child in get_children():
		if child is AITransition:
			transitions.append(child)

func _start():
	pass

func _end():
	pass

func _update(_delta:float):
	pass

func end(shutdown:bool = false):
	_end()
	running = false
	if shutdown:
		return
	if next_behavior != null:
		enemy.enemy_ai.start_behavior(next_behavior)
		return
	var transition = check_transitions()
	if transition:
		enemy.enemy_ai.start_behavior(transition.target_behavior)
	else:
		enemy.enemy_ai.start_behavior(enemy.enemy_ai.behaviors[0])

func _physics_process(delta: float) -> void:
	if running:
		_update(delta)
		var transition := check_transitions()
		if transition:
			_end()
			running = false
			enemy.enemy_ai.start_behavior(transition.target_behavior)

func check_transitions() -> AITransition:
	for transition in transitions:
		if transition.check_conditions(enemy.enemy_ai.ai_state):
			return transition
	return null
