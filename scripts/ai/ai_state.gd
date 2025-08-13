extends Resource
class_name AIState

# I don't like the hard dependence on the specific enemy here.
# It's not an issue yet, but it still feels wrong.
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

var sounds:Array[SoundDefinition]
const MAX_SOUNDS_REMEMBERED = 10

var player_sounds:Array[StringName] = [&"player_footstep"]

# See notes under enemy variable
var aggro:float :
	set(value):
		if value > enemy.aggro_threshold:
			base_aggro += (value - enemy.aggro_threshold) * .25
		aggro = clamp(value, base_aggro, enemy.aggro_threshold)
		enemy.aggro_meter.value = value

var base_aggro:float :
	set(value):
		base_aggro = value
		enemy.base_aggro_meter.value = value
		aggro = aggro

var aggro_dropping:bool = false

func seen_player_within(time:float) -> bool:
	return last_seen_player + time >= Time.get_unix_time_from_system()

func heard_player_within(time:float) -> bool:
	return last_heard_player + time >= Time.get_unix_time_from_system()

func detected_player_within(time:float) -> bool:
	return last_detected_player + time >= Time.get_unix_time_from_system()

func attacked_within(time:float) -> bool:
	return last_attacked + time >= Time.get_unix_time_from_system()

func add_sound_definition(sound_definition:SoundDefinition):
	sounds.append(sound_definition)
	if sounds.size() > MAX_SOUNDS_REMEMBERED:
		sounds.sort_custom(func(a, b): return a.time < b.time)
		sounds.remove_at(0)
	
	if player_sounds.has(sound_definition.sound_id):
		last_heard_player = sound_definition.time
		last_heard_player_pos = sound_definition.position

func heard_sound_within(sound_id:StringName, time:float) -> SoundDefinition:
	if sounds.size() == 0:
		return null
	var sounds_reversed = Array(sounds)
	sounds_reversed.reverse()
	if sound_id == &"":
		var sound = sounds_reversed[0]
		if sound.time + time >= Time.get_unix_time_from_system():
			return sounds_reversed[0]
	for sound in sounds_reversed:
		if sound.sound_id == sound_id and sound.time + time >= Time.get_unix_time_from_system():
			return sound
	
	return null
