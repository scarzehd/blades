extends AIBehavior
class_name AIInvestigateBehavior

enum InvestigateEventSortingMode {
	NEAREST,
	MOST_RECENT
}

@export var sounds:Array[StringName]
@export var invert_sounds:bool = false
@export var event_sorting_mode:InvestigateEventSortingMode = InvestigateEventSortingMode.MOST_RECENT
@export var delay_time:float = 1
@export var hover_time:float = 1

var investigate_position:Vector3

var phase:int = 0

var timer:Timer

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func _start():
	var filtered_sounds:Array[SoundDefinition]
	phase = 0
	timer.start(delay_time)
	
	if sounds.size() == 0:
		if not invert_sounds:
			filtered_sounds = Array(enemy.enemy_ai.ai_state.sounds)
	else:
		if invert_sounds:
			filtered_sounds = enemy.enemy_ai.ai_state.sounds.filter(func(sound): return not sounds.has(sound.sound_id))
		else:
			filtered_sounds = enemy.enemy_ai.ai_state.sounds.filter(func(sound): return sounds.has(sound.sound_id))
	
	match event_sorting_mode:
		InvestigateEventSortingMode.NEAREST:
			investigate_position = get_nearest(filtered_sounds)
		InvestigateEventSortingMode.MOST_RECENT:
			investigate_position = get_most_recent(filtered_sounds)
	
	enemy.navigation_agent.target_position = investigate_position

func get_nearest(of_sounds:Array[SoundDefinition]) -> Vector3:
	var closest:Vector3 = enemy.enemy_ai.ai_state.last_detected_player_pos
	var closest_distance:float = closest.distance_to(enemy.global_position)
	for sound in of_sounds:
		var distance = sound.position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest = sound.position
			closest_distance = distance
	
	return closest

func get_most_recent(of_sounds:Array[SoundDefinition]) -> Vector3:
	if of_sounds.size() == 0:
		return enemy.enemy_ai.ai_state.last_detected_player_pos
	
	var most_recent_sound = of_sounds[0]
	if enemy.enemy_ai.ai_state.last_detected_player > most_recent_sound.time:
		return enemy.enemy_ai.ai_state.last_detected_player_pos
	
	return most_recent_sound.position

func _update(delta:float):
	match phase:
		0:
			update_phase_0(delta)
		1:
			update_phase_1(delta)
		2:
			update_phase_2(delta)

func update_phase_0(_delta:float):
	var look_at_target = Vector3(investigate_position.x, enemy.global_position.y, investigate_position.z)
	look_at_target -= enemy.global_position
	look_at_target = (-enemy.global_basis.z).slerp(look_at_target, 0.1)
	look_at_target += enemy.global_position
	enemy.look_at(look_at_target)
	if timer.is_stopped():
		phase = 1

func update_phase_1(_delta:float):
	var next_pos := enemy.navigation_agent.get_next_path_position()
	enemy.set_desired_velocity(enemy.global_position.direction_to(next_pos) * enemy.speed)
	if enemy.global_position != next_pos:
		var look_at_target = Vector3(next_pos.x, enemy.global_position.y, next_pos.z)
		look_at_target -= enemy.global_position
		look_at_target = (-enemy.global_basis.z).slerp(look_at_target, 0.1)
		look_at_target += enemy.global_position
		enemy.look_at(look_at_target)
	
	if enemy.navigation_agent.is_navigation_finished():
		phase = 2
		enemy.set_desired_velocity(Vector3.ZERO)
		timer.start(hover_time)

func update_phase_2(_delta:float):
	if not timer.is_stopped():
		return
	
	end()

func _end():
	enemy.set_desired_velocity(Vector3.ZERO)
	phase = 0
	timer.stop()
