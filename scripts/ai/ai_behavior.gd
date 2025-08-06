extends Node3D
class_name AIBehavior

var transitions:Array[AITransition]

var enemy:Enemy

var running:bool

func _ready() -> void:
	for child in get_children():
		if child is AITransition:
			transitions.append(child)

func _start():
	pass

func end():
	_end()
	running = false
	var transition = check_transitions()
	if transition:
		enemy.enemy_ai.start_behavior(transition.target_behavior)

func _end():
	pass

func _update(delta:float):
	pass

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
		if transition.check_conditions(enemy.enemy_ai.current_conditions):
			return transition
	return null
