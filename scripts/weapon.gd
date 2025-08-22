extends Node3D
class_name Weapon

@onready var animation_player:AnimationPlayer = %AnimationPlayer
@onready var upswing_timer:Timer = %UpswingTimer
@onready var fire_rate_timer:Timer = %FireRateTimer

@export_category("Stats")
@export var weapon_range:float = 1 ## In engine units.
@export var damage:float = 1
@export var attack_interval:float = 1 ## The amount of time one swing takes in seconds.
@export var upswing:float = 0.1 ## The delay between pressing the fire button and casting the ray.
@export var heft:float = 1 ## As a multiplier to move speed.
@export var kill_speed:float = 1 ## As a multiplier of animation time.
@export var parry_window:float = 1 ## The Length of the parry window in seconds.
@export var guard:float = 1 ## As an inverse multiplier to the increase in the tension meter on block.
@export var guard_upswing:float = 0.1 ## The amount of time after swinging before the weapon's damage is actually dealt.

@export var shader_materials:Array[ShaderMaterial]

## True if we can swap weapons. We're not drawing, stowing, or firing.
var can_swap:bool = true
var can_fire:bool = false
var can_block:bool = false

var weapon_drawn:bool = false
var blocking:bool = false
@onready var current_guard:float = guard

func fire(direction:Vector3):
	if not can_fire:
		return
	
	can_fire = false
	can_swap = false
	can_block = false
	
	animation_player.stop() # If the fire animation is longer than the fire rate, we need to stop playing the animation
	animation_player.play("fire")
	
	fire_rate_timer.start(attack_interval)
	upswing_timer.start(upswing)
	await upswing_timer.timeout
	
	var end_pos = Globals.player.head.global_position + direction * weapon_range
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(Globals.player.head.global_position, end_pos, 2, [Globals.player.get_rid()])
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is HealthComponent:
		result.collider.current_hp -= damage
	
	await fire_rate_timer.timeout
	can_fire = true
	can_swap = true
	can_block = true

func draw():
	can_swap = false
	animation_player.play("draw")
	await animation_player.animation_finished
	weapon_drawn = true
	can_swap = true
	can_fire = true
	can_block = true

func stow():
	can_block = false
	if blocking:
		await end_block()
	can_swap = false
	can_fire = false
	animation_player.play("stow")
	await animation_player.animation_finished
	weapon_drawn = false
	can_swap = true

func stealth_kill(enemy:Enemy):
	#for material in shader_materials:
		#material.set_shader_parameter("enabled", false)
	var player = Globals.player
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_parallel()
	
	var old_camera_transform = player.camera.global_transform
	var target_camera_transform = player.camera.global_transform.looking_at(enemy.global_position)
	tween.tween_property(player.camera, "global_transform", target_camera_transform, 0.2)
	await tween.finished
	animation_player.play("stealth_kill", -1, kill_speed)
	await animation_player.animation_finished
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(player.camera, "global_transform", old_camera_transform, 0.2)
	await tween.finished
	#for material in shader_materials:
		#material.set_shader_parameter("enabled", true)

func start_block():
	animation_player.play("start_block")
	can_fire = false
	await get_tree().create_timer(guard_upswing).timeout
	blocking = true

func end_block():
	blocking = false
	animation_player.play("end_block")
	await animation_player.animation_finished
	can_fire = true
	return null

func block_modify_damage(damage:float) -> float:
	if not blocking:
		return damage
	if damage > current_guard:
		damage -= current_guard
		current_guard = 0
	else:
		current_guard -= damage
		damage = 0
	
	if current_guard <= 0:
		Globals.player.unequip_weapon.call_deferred()
	
	return damage
