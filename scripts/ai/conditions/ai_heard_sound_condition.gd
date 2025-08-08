extends AICondition
class_name AIHeardSoundCondition

@export var sound_ids:Dictionary[StringName, float]
@export var all:bool = false

func _check_condition(ai_state:AIState) -> bool:
	if all:
		return check_all(ai_state)
	
	for sound_id in sound_ids:
		var time = sound_ids[sound_id]
		var result = ai_state.heard_sound_within(sound_id, time)
		if result != null:
			print(Time.get_unix_time_from_system() - result.time)
			return true
		
	return false

func check_all(ai_state:AIState) -> bool:
	for sound_id in sound_ids:
		var time = sound_ids[sound_id]
		if not ai_state.heard_sound_within(sound_id, time):
			return false
	
	return true
