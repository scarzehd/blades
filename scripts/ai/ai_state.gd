extends Resource
class_name AIState

var enemy:Enemy

var last_attacked:float

var last_seen_player:float :
	set(value):
		last_seen_player = value
		last_detected_player = value

var last_seen_player_pos:Vector3 :
	set(value):
		last_seen_player_pos = value
		last_detected_player_pos = value

var last_heard_player:float :
	set(value):
		last_heard_player = value
		if last_detected_player < value: last_detected_player = value

var last_heard_player_pos:Vector3 :
	set(value):
		last_heard_player_pos = value
		last_detected_player_pos = value

var last_detected_player:float

var last_detected_player_pos:Vector3
