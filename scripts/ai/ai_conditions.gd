extends Resource
class_name AIConditions

var enemy:Enemy

var last_attacked:float

var last_seen_player:float :
	set(value):
		last_seen_player = value
		if last_detected_player < value: last_detected_player = value

var last_heard_player:float :
	set(value):
		last_heard_player = value
		if last_detected_player < value: last_detected_player = value

var last_detected_player:float
