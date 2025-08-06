extends CharacterBody3D
class_name Player

@onready var head:Node3D = %Head
@onready var camera:Camera3D = %Camera3D
@onready var step_up:CollisionShape3D = %StepUp
@onready var weapon_container:Node3D = %WeaponContainer
@onready var collision_shape:CollisionShape3D = %CollisionShape3D
@onready var health_component:HealthComponent = %HealthComponent
@onready var distraction_timer:Timer = %DistractionTimer

# Mouse input
const X_SENSITIVITY:float = 0.2
const Y_SENSITIVITY:float = 0.2
var mouse_input:Vector2 = Vector2.ZERO
var mouse_rotation:Vector2 = Vector2.ZERO

# Movement
const MAX_SPEED:float = 10
const ACCELERATION:float = 1.5
const DRAG:float = 0.7

const JUMP_VELOCITY:float = 4.5

const GRAVITY:float = 0.25

const MAX_STEP:float = 0.5
var was_on_floor:bool = false
var snapped_down_last_frame:bool = false

var movement_override = false

# Crouching
var crouching:bool = false
const CROUCH_MOVE_MULTIPLIER:float = 0.5
const CROUCH_TIME:float = 0.15
var crouch_tween:Tween

# Weapons
var weapon:Weapon
var weapon_drawn:bool = false

# Distractions
const DISTRACTION_COOLDOWN:float = 5
const DISTRACTION_THROW_FORCE:float = 20
@export var distractions:Dictionary[PackedScene, int]
var distraction_ready:bool = true

func _ready() -> void:
	Globals.player = self
	
	for child in weapon_container.get_children():
		if not weapon and child is Weapon:
			weapon = child
		else:
			child.queue_free()

func _process(_delta: float) -> void:
	# This needs to be done to fix weapon jitter with physics interpolation.
	weapon_container.global_transform = camera.get_global_transform_interpolated()

func _physics_process(delta: float) -> void:
	if not movement_override:
		move(delta)
		update_camera(delta)
		handle_crouch()
		handle_weapon_input()
		handle_distraction()

func _unhandled_input(event: InputEvent) -> void:
	if not movement_override:
		handle_mouse_input(event)

#region Mouse Input

func handle_mouse_input(event:InputEvent):
	if event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			mouse_input += -event.relative

func update_camera(delta):
	mouse_rotation.x += mouse_input.y * delta * X_SENSITIVITY
	mouse_rotation.x = clamp(mouse_rotation.x, deg_to_rad(-90), deg_to_rad(90))
	mouse_rotation.y += mouse_input.x * delta * Y_SENSITIVITY
	
	camera.transform.basis = Basis.from_euler(Vector3(mouse_rotation.x, 0, 0))
	camera.rotation.z = 0
	
	head.basis = Basis.from_euler(Vector3(0, mouse_rotation.y, 0))
	
	mouse_input = Vector2.ZERO

#endregion

#region Movement

func move(delta):
	var max_speed = get_max_speed()
	
	var tmod = delta * 60
	
	step_up.disabled = false
	
	if not is_on_floor():
		velocity.y -= GRAVITY * tmod
		step_up.disabled = true
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and velocity.length() < max_speed:
		velocity.x += ACCELERATION * direction.x * tmod
		velocity.z += ACCELERATION * direction.z * tmod
	
	var normalized_velocity = velocity.normalized()
	var move_dir = Vector3(normalized_velocity.x, 0, normalized_velocity.z)
	
	# If we're not inputting anything, our speed is too high, or we're trying to move backwards, apply drag
	if !direction or velocity.length() > max_speed or direction.dot(move_dir) < .5:
		velocity.x *= clampf(DRAG * tmod, 0, 1)
		velocity.z *= clampf(DRAG * tmod, 0, 1)
	
	update_step_up_position(Vector2(move_dir.x, move_dir.z))
	move_and_slide()
	snap_down_stairs()

func snap_down_stairs():
	var did_snap = false
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor or snapped_down_last_frame):
		var test_result = PhysicsTestMotionResult3D.new()
		var params = PhysicsTestMotionParameters3D.new()
		params.from = global_transform
		params.motion = Vector3(0, -MAX_STEP, 0)
		if PhysicsServer3D.body_test_motion(get_rid(), params, test_result):
			var travel = test_result.get_travel().y
			position.y += travel
			apply_floor_snap()
			did_snap = true
	
	was_on_floor = is_on_floor()
	snapped_down_last_frame = did_snap

func update_step_up_position(direction:Vector2):
	step_up.position = Vector3(direction.x * 0.7, 0 if crouching else -0.5, direction.y * 0.7)

#endregion

#region Movement Variables

func get_max_speed() -> float:
	return MAX_SPEED * (CROUCH_MOVE_MULTIPLIER if crouching else 1.0) * (weapon.heft if weapon_drawn else 1.0)

#endregion

#region Crouching

func handle_crouch():
	if Input.is_action_just_pressed("crouch"):
		start_crouch()
	
	if Input.is_action_just_released("crouch"):
		end_crouch()

func start_crouch():
	if crouch_tween and crouch_tween.is_running():
		crouch_tween.kill()
	
	crouch_tween = create_tween()
	crouch_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	crouch_tween.tween_property(self, "crouching", true, 0)
	crouch_tween.set_parallel()
	crouch_tween.tween_property(head, "position", Vector3(0, 0, 0), CROUCH_TIME)
	crouch_tween.tween_property(collision_shape.shape, "height", 1, CROUCH_TIME)
	#crouch_tween.tween_property(step_up.shape, "length", .25, CROUCH_TIME)

func end_crouch():
	if crouch_tween and crouch_tween.is_running():
		crouch_tween.kill()
	
	crouch_tween = create_tween()
	crouch_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	crouch_tween.set_parallel()
	crouch_tween.tween_property(head, "position", Vector3(0, 0.5, 0), CROUCH_TIME)
	crouch_tween.tween_property(collision_shape.shape, "height", 2, CROUCH_TIME)
	#crouch_tween.tween_property(step_up.shape, "length", .5, CROUCH_TIME)
	crouch_tween.chain().tween_property(self, "crouching", false, 0)

#endregion

#region Weapons

func equip_weapon(weapon_scene:PackedScene) -> Weapon:
	var new_weapon:Weapon = weapon_scene.instantiate()
	assert(new_weapon is Weapon)
	weapon.queue_free()
	weapon = new_weapon
	head.add_child(weapon)
	return weapon

func draw_weapon():
	weapon_drawn = true
	weapon.draw()

func stow_weapon():
	weapon_drawn = false
	weapon.stow()

func handle_weapon_input():
	if not weapon:
		return
	if weapon.can_swap and Input.is_action_just_pressed("swap"):
		if weapon_drawn:
			stow_weapon()
		else:
			draw_weapon()
	
	if weapon.can_fire:
		if Input.is_action_pressed("fire"):
			weapon.fire(-camera.global_basis.z)
		elif Input.is_action_just_pressed("alt_fire"):
			var end_pos = global_position + -camera.global_basis.z * weapon.weapon_range
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(global_position, end_pos, 1, [Globals.player.get_rid()])
			var result = space_state.intersect_ray(query)
	
			if not (result and result.collider is Enemy):
				return
			
			var enemy:Enemy = result.collider
			
			if enemy.enemy_ai.current_conditions.detected_player_within(1) or enemy.enemy_ai.current_conditions.attacked_within(1):
				return
			
			velocity = Vector3.ZERO
			var was_crouching = crouching
			if was_crouching:
				end_crouch()
				await crouch_tween.finished
				#update_step_up_position(Vector2.ZERO)
			movement_override = true
			step_up.disabled = true
			enemy.enemy_ai.end_ai()
			await weapon.stealth_kill(enemy)
			enemy.health_component.current_hp = 0
			if was_crouching and Input.is_action_pressed("crouch"):
				start_crouch()
			step_up.disabled = false
			movement_override = false

#endregion

#region Distraction

func handle_distraction():
	if Input.is_action_just_pressed("distraction") and distraction_ready:
		distraction_ready = false
		distraction_timer.start(DISTRACTION_COOLDOWN)
		var total_weight = 0
		for scene in distractions.keys():
			total_weight += distractions[scene]
		
		var rand = randf_range(0, total_weight)
		
		var chosen_scene:PackedScene = distractions.keys()[0]
		
		for scene in distractions.keys():
			rand -= distractions[scene]
			
			if rand <= 0:
				chosen_scene = scene
				break
		
		var distraction:Distraction = chosen_scene.instantiate()
		
		add_child(distraction)
		
		distraction.global_position = head.global_position + (-camera.global_basis.z * 0.25)
		distraction.apply_central_impulse(-camera.global_basis.z * DISTRACTION_THROW_FORCE)

func _on_distraction_timer_timeout() -> void:
	distraction_ready = true

#endregion
