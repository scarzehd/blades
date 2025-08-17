extends AIBehavior
class_name AIAttackBehavior

@export var damage:float

@export var attack_range:float
@export var desired_range:float

@export var upswing:float
@export var attack_interval:float

@export var attack_move_multiplier:float = 1

var last_seen_pos:Vector3

var attacking:bool

func _start():
	last_seen_pos = enemy.enemy_ai.ai_state.last_detected_player_pos
	attacking = false

func _end():
	enemy.set_desired_velocity(Vector3.ZERO)

func _update(delta:float):
	var detected_player = enemy.enemy_ai.ai_state.detected_player_within(delta * 2)
	if detected_player:
		last_seen_pos = Globals.player.global_position
	
	enemy.navigation_agent.target_position = last_seen_pos
	
	var next_pos = enemy.navigation_agent.get_next_path_position()
	
	var look_at_target:Vector3
	
	if enemy.enemy_ai.ai_state.seen_player_within(delta * 2):
		look_at_target = Vector3(last_seen_pos.x, enemy.global_position.y, last_seen_pos.z)
	elif enemy.global_position != next_pos:
		look_at_target = Vector3(next_pos.x, enemy.global_position.y, next_pos.z)
	
	look_at_target -= enemy.global_position
	look_at_target = (-enemy.global_basis.z).slerp(look_at_target, 0.4)
	look_at_target += enemy.global_position
	
	enemy.look_at(look_at_target)
	
	if not attacking and detected_player and enemy.global_position.distance_to(Globals.player.global_position) <= desired_range:
		start_attack()
	
	var velocity = enemy.global_position.direction_to(next_pos) * enemy.speed
	
	if attacking:
		velocity *= attack_move_multiplier
	
	enemy.set_desired_velocity(velocity)

func start_attack():
	attacking = true
	enemy.animation_player.play("attack")
	await get_tree().create_timer(upswing).timeout
	if Globals.player.global_position.distance_to(enemy.global_position) <= attack_range:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(enemy.sight_cone_detection.global_position, Globals.player.global_position, 1 | 2, [enemy.health_component.get_rid()])
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var result = space_state.intersect_ray(query)
		if result and result.collider.owner is Player:
			Globals.player.health_component.current_hp -= damage
	
	await get_tree().create_timer(attack_interval - upswing).timeout
	attacking = false
