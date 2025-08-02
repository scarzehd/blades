extends AIAction
class_name AIWaitAction

@export var wait_time:float

var start_time:float

func _start(enemy:Enemy):
	start_time = Time.get_unix_time_from_system()

func _update(enemy:Enemy, delta:float) -> bool:
	if Time.get_unix_time_from_system() >= start_time + wait_time:
		return false
	return true
