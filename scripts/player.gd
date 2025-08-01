extends CharacterBody3D
class_name Player

@onready var head:Node3D = %Head
@onready var camera:Camera3D = %Camera3D
@onready var step_up:CollisionShape3D = %StepUp
@onready var weapon_container:Node3D = %WeaponContainer
@onready var collision_shape:CollisionShape3D = %CollisionShape3D
@onready var health_component:HealthComponent = %HealthComponent

# Mouse input
const X_SENSITIVITY = 0.2
const Y_SENSITIVITY = 0.2
var mouse_input:Vector2 = Vector2.ZERO
var mouse_rotation:Vector2 = Vector2.ZERO

# Movement
const MAX_SPEED = 10
const ACCELERATION = 1.5
const DRAG = 0.7

const JUMP_VELOCITY = 4.5

const GRAVITY = 0.25

const MAX_STEP = 0.5
var was_on_floor = false
var snapped_down_last_frame = false

# Crouching
var crouching := false
const CROUCH_MOVE_MULTIPLIER := 0.5
const CROUCH_TIME := 0.15
var crouch_tween:Tween

# Weapons
var weapon:Weapon
var weapon_drawn:bool = false

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
	handle_crouch()
	handle_weapon_input()

func _physics_process(delta: float) -> void:
	move(delta)
	update_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
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
	
	if not is_on_floor():
		velocity.y -= GRAVITY * tmod
	
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
	step_up.position = Vector3(direction.x, -0.5, direction.y)

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
	crouch_tween.tween_property(head, "position", Vector3(0, -0.25, 0), CROUCH_TIME)
	crouch_tween.tween_property(collision_shape.shape, "height", 1, 0)
	crouch_tween.tween_property(self, "crouching", true, 0)

func end_crouch():
	if crouch_tween and crouch_tween.is_running():
		crouch_tween.kill()
	
	crouch_tween = create_tween()
	crouch_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	crouch_tween.tween_property(head, "position", Vector3(0, 0.5, 0), CROUCH_TIME)
	crouch_tween.tween_property(collision_shape.shape, "height", 2, 0)
	crouch_tween.tween_property(self, "crouching", false, 0)

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
	
	if weapon.can_fire and Input.is_action_pressed("fire"):
		weapon.fire(-camera.global_basis.z)

#endregion
