extends CharacterBody3D
class_name Enemy

@export var start_ai_on_ready:bool = false

@export var aggro_threshold:float
@export var aggro_reset_time:float
@export var aggro_reset_rate:float = 1
@export var damage_aggro:float = 0.5
@export var speed:float = 5

@onready var sight_cone_detection:SightConeDetection = %SightCone
#@onready var sphere_detection:SphereDetection = %SphereDetection
@onready var aggro_meter:ProgressBar = %AggroMeter
@onready var base_aggro_meter:ProgressBar = %BaseAggroMeter
@onready var aggro_reset_timer:Timer = %AggroResetTimer
@onready var health_bar:ProgressBar = %HealthBar
@onready var health_component:HealthComponent = %HealthComponent
@onready var enemy_ai:EnemyAI = %EnemyAI
@onready var navigation_agent:NavigationAgent3D = %NavigationAgent3D

func _ready() -> void:
	aggro_meter.max_value = aggro_threshold
	base_aggro_meter.max_value = aggro_threshold
	health_bar.max_value = health_component.max_hp
	health_bar.value = health_component.current_hp
	enemy_ai.enemy = self
	if start_ai_on_ready:
		enemy_ai.start_ai()

func _physics_process(delta: float) -> void:
	if health_component.current_hp == 0:
		move_and_slide()
		return
	velocity.y -= 0.25
	
	var sight_cone_detected = sight_cone_detection._detect_player()
	#var sphere_detected = sphere_detection._detect_player()
	
	#print(-global_basis.z)
	
	if sight_cone_detected:
		enemy_ai.ai_state.aggro_dropping = false
		aggro_reset_timer.start(aggro_reset_time)
		#aggro = clamp(aggro + (delta * (1 if Globals.player.crouching else 1.5 )), 0, aggro_threshold)
		var aggro_change = delta * (1.0 if Globals.player.crouching else 1.5)
		#base_aggro = move_toward(base_aggro, aggro_threshold, aggro_change * 0.25)
		enemy_ai.ai_state.aggro += aggro_change
		#if enemy_ai.ai_state.last_seen_player + 0.5 < Time.get_unix_time_from_system():
		enemy_ai.ai_state.last_seen_player = Time.get_unix_time_from_system()
		enemy_ai.ai_state.last_seen_player_pos = Globals.player.global_position
	#elif sphere_detected and !Globals.player.crouching and Globals.player.velocity.length() > 0.1:
		#player_detected = true
		#aggro_dropping = false
		#aggro_reset_timer.start(aggro_reset_time)
		#aggro = move_toward(aggro, aggro_threshold, delta)
		##if enemy_ai.ai_state.last_heard_player + 0.5 < Time.get_unix_time_from_system():
		#enemy_ai.ai_state.last_heard_player = Time.get_unix_time_from_system()
		#enemy_ai.ai_state.last_heard_player_pos = Globals.player.global_position
	
	if enemy_ai.ai_state.aggro_dropping:
		enemy_ai.ai_state.aggro -= delta * aggro_reset_rate
	
	move_and_slide()

func set_desired_velocity(new_desired_velocity:Vector3):
	if navigation_agent.avoidance_enabled:
		navigation_agent.velocity = new_desired_velocity
	else:
		_on_navigation_agent_3d_velocity_computed(new_desired_velocity)

#region Signal Callbacks

func _on_aggro_reset_timer_timeout() -> void:
	enemy_ai.ai_state.aggro_dropping = true


func _on_hp_changed(old_hp:int, new_hp:int) -> void:
	health_bar.value = new_hp
	# Check if hp was changed because of damage.
	# Make sure hp didn't lower because max hp did.
	if new_hp <= 0:
		enemy_ai.end_ai()
		return
	if new_hp < old_hp and new_hp != health_component.max_hp:
		enemy_ai.ai_state.aggro += damage_aggro
		enemy_ai.ai_state.base_aggro += damage_aggro
		aggro_reset_timer.start(aggro_reset_time)
		enemy_ai.ai_state.aggro_dropping = false
		enemy_ai.ai_state.last_attacked = Time.get_unix_time_from_system()
		enemy_ai.ai_state.last_heard_player = Time.get_unix_time_from_system()

func _on_max_hp_changed(_old_max_hp:int, new_max_hp:int) -> void:
	health_bar.max_value = new_max_hp

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	var y = velocity.y
	if safe_velocity.y > 0:
		y = safe_velocity.y
	velocity = Vector3(safe_velocity.x, y, safe_velocity.z)

#endregion
