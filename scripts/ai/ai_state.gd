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
		last_detected_player = value

var last_heard_player_pos:Vector3 :
	set(value):
		last_heard_player_pos = value
		last_detected_player_pos = value

var last_detected_player:float

var last_detected_player_pos:Vector3

func seen_player_within(time:float) -> bool:
	return last_seen_player + time >= Time.get_unix_time_from_system()

func heard_player_within(time:float) -> bool:
	return last_heard_player + time >= Time.get_unix_time_from_system()

func detected_player_within(time:float) -> bool:
	return last_detected_player + time >= Time.get_unix_time_from_system()

func attacked_within(time:float) -> bool:
	return last_attacked + time >= Time.get_unix_time_from_system()
