extends Resource
class_name AIAction

func _start(enemy:Enemy):
	pass

func _end(enemy:Enemy, interrupt_id:StringName = ""):
	pass

func _update(enemy:Enemy, delta:float) -> bool:
	return false
