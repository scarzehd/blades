extends Node3D
class_name EnemyAI

@export var behaviors:Array[AIBehavior]

var current_conditions:AIState = AIState.new()
var enemy:Enemy :
	set(value):
		enemy = value
		current_conditions.enemy = value

var current_behavior:AIBehavior

func interrupt(interrupt_id:StringName):
	if not current_behavior:
		return
	if not current_behavior.end(enemy, interrupt_id):
		return
	current_behavior = choose_behavior()
	current_behavior.start(enemy)

func start_ai():
	if not behaviors.size() > 0:
		return
	current_behavior = choose_behavior()
	current_behavior.start(enemy)

func end_ai():
	if current_behavior:
		current_behavior.end(enemy, "dead")
		current_behavior = null

func choose_behavior() -> AIBehavior:
	for behavior in behaviors:
		if behavior.check_conditions(current_conditions):
			return behavior
	
	return behaviors[behaviors.size() - 1]

func _physics_process(delta: float) -> void:
	if not current_behavior:
		return
	
	if not current_behavior._update(enemy, delta) and current_behavior.end(enemy):
		current_behavior = choose_behavior()
		current_behavior.start(enemy)
