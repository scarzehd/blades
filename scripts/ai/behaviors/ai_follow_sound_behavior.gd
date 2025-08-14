extends AIBehavior
class_name AIFollowSoundBehavior

@export var sounds:Array[StringName]
@export var invert:bool = false
@export var prioritize:bool = false

var sound_definition:SoundDefinition

func _start():
	if prioritize:
		start_prioritize()
		return
	
	for sound in enemy.enemy_ai.ai_state.sounds:
		if sounds.has(sound.sound_id) == not invert:
			sound_definition = sound
			return
	
	end()

func start_prioritize():
	for sound_id in sounds:
		for enemy_sound in enemy.enemy_ai.ai_state.sounds:
			if enemy_sound.sound_id == sound_id:
				sound_definition = enemy_sound
	
	end()

func _end():
	enemy.velocity = Vector3.ZERO

func _update(delta:float):
	pass
