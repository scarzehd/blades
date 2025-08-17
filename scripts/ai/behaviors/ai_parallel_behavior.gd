extends AIBehavior
class_name AIParallelBehavior

var behaviors:Array[AIBehavior]

func _ready() -> void:
	super._ready()
	for child in get_children():
		if child is AIBehavior:
			behaviors.append(child)

func _update(delta:float):
	for behavior in behaviors:
		behavior._update(delta)

func _start():
	for behavior in behaviors:
		behavior._start()

func _end():
	for behavior in behaviors:
		behavior._end()
