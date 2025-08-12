extends Node3D
class_name EnemyAI

var behaviors:Array[AIBehavior]
var universal_transitions:Array[AITransition]

var current_conditions:AIState = AIState.new()
var enemy:Enemy :
	set(value):
		enemy = value
		for behavior in behaviors:
			behavior.enemy = value

var current_behavior:AIBehavior

func _ready() -> void:
	for child in get_children():
		if child is AIBehavior:
			behaviors.append(child)
		if child is AITransition:
			universal_transitions.append(child)

func start_ai():
	if not is_node_ready(): await ready
	if not behaviors.size() > 0:
		return
	start_behavior(behaviors[0])

func end_ai():
	if current_behavior:
		current_behavior.end(true)
		current_behavior = null

func start_behavior(new_behavior:AIBehavior):
	if current_behavior and current_behavior.running:
		current_behavior.end()
	current_behavior = new_behavior
	current_behavior.running = true
	current_behavior._start()
