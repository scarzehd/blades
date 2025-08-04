extends CharacterBody3D
class_name Enemy

@export var start_ai_on_ready:bool = true

@export var aggro_threshold:float
@export var aggro_reset_time:float
@export var aggro_reset_rate:float = 1
@export var speed:float = 5

@onready var sight_cone_detection:SightConeDetection = %SightCone
@onready var sphere_detection:SphereDetection = %SphereDetection
@onready var aggro_meter:ProgressBar = %AggroMeter
@onready var aggro_reset_timer:Timer = %AggroResetTimer
@onready var health_bar:ProgressBar = %HealthBar
@onready var health_component:HealthComponent = %HealthComponent
@onready var enemy_ai:EnemyAI = %EnemyAI
@onready var navigation_agent:NavigationAgent3D = %NavigationAgent3D

var player_detected:bool

var aggro:float :
	set(value):
		aggro = value
		aggro_meter.value = value

var aggro_dropping:bool = false

func _ready() -> void:
	aggro_meter.max_value = aggro_threshold
	health_bar.max_value = health_component.max_hp
	health_bar.value = health_component.current_hp
	enemy_ai.enemy = self
	if start_ai_on_ready:
		enemy_ai.start_ai()

func _physics_process(delta: float) -> void:
	if health_component.current_hp == 0:
		move_and_slide()
		return
	
	var sight_cone_detected = sight_cone_detection._detect_player()
	var sphere_detected = sphere_detection._detect_player()
	player_detected = false
	
	#print(-global_basis.z)
	
	if sight_cone_detected:
		player_detected = true
		aggro_dropping = false
		aggro_reset_timer.start(aggro_reset_time)
		#aggro = clamp(aggro + (delta * (1 if Globals.player.crouching else 1.5 )), 0, aggro_threshold)
		aggro = move_toward(aggro, aggro_threshold, delta * (1.0 if Globals.player.crouching else 1.5))
		#if enemy_ai.current_conditions.last_seen_player + 0.5 < Time.get_unix_time_from_system():
		enemy_ai.current_conditions.last_seen_player = Time.get_unix_time_from_system()
		enemy_ai.interrupt("seen_player")
	elif sphere_detected and !Globals.player.crouching and Globals.player.velocity.length() > 0.1:
		aggro_dropping = false
		player_detected = true
		aggro_reset_timer.start(aggro_reset_time)
		aggro = move_toward(aggro, aggro_threshold, delta)
		#if enemy_ai.current_conditions.last_heard_player + 0.5 < Time.get_unix_time_from_system():
		enemy_ai.current_conditions.last_heard_player = Time.get_unix_time_from_system()
		enemy_ai.interrupt("heard_player")
	
	if aggro_dropping:
		aggro = clamp(aggro - (delta * aggro_reset_rate), 0, aggro_threshold)
	
	move_and_slide()

#region Signal Callbacks

func _on_aggro_reset_timer_timeout() -> void:
	aggro_dropping = true


func _on_hp_changed(old_hp:int, new_hp:int) -> void:
	health_bar.value = new_hp
	# Check if hp was changed because of damage.
	# Make sure hp didn't lower because max hp did.
	if new_hp <= 0:
		enemy_ai.end_ai()
		return
	if new_hp < old_hp and new_hp != health_component.max_hp:
		aggro += 0.5
		aggro_reset_timer.start(aggro_reset_time)
		aggro_dropping = false
		enemy_ai.current_conditions.last_attacked = Time.get_unix_time_from_system()
		enemy_ai.current_conditions.last_heard_player = Time.get_unix_time_from_system()
		enemy_ai.interrupt("damaged")


func _on_max_hp_changed(_old_max_hp:int, new_max_hp:int) -> void:
	health_bar.max_value = new_max_hp

#endregion
