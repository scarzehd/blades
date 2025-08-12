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
	
	var enemy_sounds_reversed = Array(enemy.enemy_ai.current_conditions.sounds)
	enemy_sounds_reversed.reverse()
	
	for sound in enemy_sounds_reversed:
		if sounds.has(sound.sound_id) == not invert:
			sound_definition = sound
			return
	
	end()

func start_prioritize():
	for sound_id in sounds:
		for enemy_sound in enemy.enemy_ai.current_conditions.sounds:
			if enemy_sound.sound_id == sound_id:
				sound_definition = enemy_sound
	
	end()

func _end():
	enemy.velocity = Vector3.ZERO

func _update(delta:float):
	pass
