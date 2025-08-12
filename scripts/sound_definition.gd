extends Resource
class_name SoundDefinition

var position:Vector3
var time:float
var sound_id:StringName

func _init(position:Vector3, sound_id:StringName, time:float = 0) -> void:
	self.position = position
	self.sound_id = sound_id
	if time == 0:
		self.time = Time.get_unix_time_from_system()
	else:
		self.time = time
