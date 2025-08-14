extends Area3D
class_name EnemySoundMaker

@onready var collision_shape_3d:CollisionShape3D = %CollisionShape3D
@onready var audio_stream_player_3d:AudioStreamPlayer3D = %AudioStreamPlayer3D

@export var radius:float = 5.0 :
	set(value):
		radius = value
		if collision_shape_3d:
			collision_shape_3d.shape.radius = value
@export var audio:AudioStream :
	set(value):
		audio = value
		if audio_stream_player_3d:
			audio_stream_player_3d.stream = value
@export var bypass_walls:bool = false

@export var sound_id:StringName

@export var aggro:float = 0.2

func _ready() -> void:
	collision_shape_3d.shape.radius = radius
	audio_stream_player_3d.stream = audio

func play_sound():
	audio_stream_player_3d.play()
	for body in get_overlapping_bodies():
		if body is Enemy:
			if not bypass_walls:
				var space_state = get_world_3d().direct_space_state
				var query = PhysicsRayQueryParameters3D.create(global_position, body.global_position, 1)
				var result = space_state.intersect_ray(query)
				if not result or result.collider != body:
					continue
			
			#body.enemy_ai.ai_state.last_heard_player = Time.get_unix_time_from_system()
			#body.enemy_ai.ai_state.last_heard_player_pos = global_position
			body.enemy_ai.ai_state.add_sound_definition(SoundDefinition.new(global_position, sound_id))
			body.enemy_ai.ai_state.aggro += aggro
