extends CharacterBody3D
class_name Enemy

@export var aggro_threshold:float
@export var aggro_reset_time:float
@export var aggro_reset_rate:float = 1

@onready var sight_cone_detection:SightConeDetection = %SightCone
@onready var sphere_detection:SphereDetection = %SphereDetection
@onready var aggro_meter:ProgressBar = %AggroMeter
@onready var aggro_reset_timer:Timer = %AggroResetTimer
@onready var health_bar:ProgressBar = %HealthBar
@onready var health_component:HealthComponent = %HealthComponent

var aggro:float :
	set(value):
		aggro = value
		aggro_meter.value = value

var aggro_dropping:bool = false

func _ready() -> void:
	sight_cone_detection.sight_direction = -transform.basis.z
	aggro_meter.max_value = aggro_threshold
	health_bar.max_value = health_component.max_hp
	health_bar.value = health_component.current_hp

func _physics_process(delta: float) -> void:
	var sight_cone_detected = sight_cone_detection._detect_player()
	var sphere_detected = sphere_detection._detect_player()
	
	if sight_cone_detected:
		aggro_dropping = false
		aggro_reset_timer.start(aggro_reset_time)
		#aggro = clamp(aggro + (delta * (1 if Globals.player.crouching else 1.5 )), 0, aggro_threshold)
		aggro = move_toward(aggro, aggro_threshold, delta * (1.0 if Globals.player.crouching else 1.5))
	elif sphere_detected and !Globals.player.crouching:
		aggro_dropping = false
		aggro_reset_timer.start(aggro_reset_time)
		aggro = move_toward(aggro, aggro_threshold, delta)
	
	if aggro_dropping:
		aggro = clamp(aggro - (delta * aggro_reset_rate), 0, aggro_threshold)

#region Signal Callbacks

func _on_aggro_reset_timer_timeout() -> void:
	aggro_dropping = true


func _on_hp_changed(old_hp:int, new_hp:int) -> void:
	health_bar.value = new_hp


func _on_max_hp_changed(_old_max_hp:int, new_max_hp:int) -> void:
	health_bar.max_value = new_max_hp

#endregion
