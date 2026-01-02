# player.gd
# Shadow Ascent — Player Controller (camera-relative, sprint, crouch, jump buffer)
extends CharacterBody3D

# Speeds (m/s)
@export var WALK_SPEED: float = 5.0
@export var SPRINT_SPEED: float = 8.0
@export var CROUCH_SPEED: float = 2.8

# Acceleration
@export var ACCEL_GROUND: float = 18.0
@export var ACCEL_AIR: float = 6.0

# Jump
@export var JUMP_VELOCITY: float = 4.8
@export var COYOTE_TIME: float = 0.12
@export var JUMP_BUFFER: float = 0.12

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

# Gravity
var GRAVITY: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Stance
var crouching: bool = false
var sprinting: bool = false

# Cached nodes
var _capsule_shape: CapsuleShape3D
@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D

# FPV look
@export var mouse_sensitivity: float = 0.12
var _yaw: float = 0.0
var _pitch: float = 0.0
const PITCH_MIN := deg_to_rad(-85.0)
const PITCH_MAX := deg_to_rad(85.0)

func _ready():
	# Cache collision shape for crouch height adjustments
	var col := $CollisionShape3D
	if col and col.shape is CapsuleShape3D:
		_capsule_shape = col.shape
	print("Player controller ready.")
	# Capture mouse for FPV and ensure camera is current
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if _camera:
		_camera.current = true
	
	# Hide own body mesh to prevent camera obstruction
	var mesh = get_node_or_null("MeshInstance3D")
	if mesh:
		mesh.visible = false

func _input(event):
	# Sprint (hold)
	sprinting = Input.is_action_pressed("sprint")
	# Crouch (hold)
	crouching = Input.is_action_pressed("crouch")
	# Jump buffer: record intent even if not on floor
	if event.is_action_pressed("jump"):
		_jump_buffer_timer = JUMP_BUFFER
	# Mouse look handling
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * mouse_sensitivity * 0.01 * TAU
		_pitch = clamp(_pitch - event.relative.y * mouse_sensitivity * 0.01 * TAU, PITCH_MIN, PITCH_MAX)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Interaction
	if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_E):
		_interact()

func _interact():
	if not _camera: return
	var space := get_world_3d().direct_space_state
	var origin := _camera.global_position
	var forward := -_camera.global_transform.basis.z
	var end := origin + forward * 3.0 # 3 meters reach
	
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result := space.intersect_ray(query)
	if not result.is_empty():
		var collider = result.collider
		if collider.has_method("interact"):
			collider.interact()
		elif collider.get_parent().has_method("interact"): # sometimes collider is a child
			collider.get_parent().interact()

func _physics_process(delta):
	# Update stance capsule height
	if _capsule_shape:
		_capsule_shape.height = lerp(_capsule_shape.height, (1.2 if crouching else 1.8), 12.0 * delta)

	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		_coyote_timer = COYOTE_TIME

	# Timers
	_coyote_timer = max(_coyote_timer - delta, 0.0)
	_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)

	# Camera-relative input
	var cam := _camera
	var right := Input.get_action_strength("move_right")
	var left := Input.get_action_strength("move_left")
	var back := Input.get_action_strength("move_back")
	var forward := Input.get_action_strength("move_forward")
	if right == 0.0 and InputMap.has_action("right"):
		right = Input.get_action_strength("right")
	if left == 0.0 and InputMap.has_action("left"):
		left = Input.get_action_strength("left")
	if back == 0.0 and InputMap.has_action("backward"):
		back = Input.get_action_strength("backward")
	if forward == 0.0 and InputMap.has_action("forward"):
		forward = Input.get_action_strength("forward")
	var input_vec := Vector2(
		right - left,
		forward - back
	)
	var dir := Vector3.ZERO
	if input_vec.length() > 0.0 and cam:
		input_vec = input_vec.normalized()
		var cam_forward := -cam.global_transform.basis.z
		var cam_right := cam.global_transform.basis.x
		cam_forward.y = 0.0
		cam_right.y = 0.0
		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()
		dir = (cam_forward * input_vec.y + cam_right * input_vec.x).normalized()

	# Horizontal acceleration
	var target_speed := WALK_SPEED
	if crouching:
		target_speed = CROUCH_SPEED
	elif sprinting:
		target_speed = SPRINT_SPEED
	var accel := (ACCEL_GROUND if is_on_floor() else ACCEL_AIR)
	var horiz := Vector3(velocity.x, 0.0, velocity.z)
	horiz = horiz.move_toward(dir * target_speed, accel * delta)
	velocity.x = horiz.x
	velocity.z = horiz.z

	# Jump with coyote time and buffer, with mantle
	if _jump_buffer_timer > 0.0:
		if _attempt_mantle():
			_jump_buffer_timer = 0.0
			_coyote_timer = 0.0
		elif is_on_floor() or _coyote_timer > 0.0:
			velocity.y = JUMP_VELOCITY
			_jump_buffer_timer = 0.0
			_coyote_timer = 0.0

	# Apply yaw to body and pitch to head for FPV
	rotation.y = _yaw
	if _head:
		_head.rotation.x = _pitch

	move_and_slide()

func _attempt_mantle() -> bool:
	var space := get_world_3d().direct_space_state
	var origin := global_transform.origin + Vector3(0, 1.0, 0)
	var facing := -global_transform.basis.z
	facing.y = 0.0
	if facing.length() == 0.0:
		return false
	facing = facing.normalized()
	var forward_end := origin + facing * 1.0
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(origin, forward_end))
	if hit.is_empty():
		return false
	var hit_pos: Vector3 = hit.position
	# Probe upward to find top within mantle height
	var up_pos := hit_pos + Vector3(0, 1.2, 0)
	var down := space.intersect_ray(PhysicsRayQueryParameters3D.create(up_pos, up_pos + Vector3(0, -2.0, 0)))
	if down.is_empty():
		return false
	var top: Vector3 = down.position
	# Small clearance check above top
	var clearance := space.intersect_ray(PhysicsRayQueryParameters3D.create(top + Vector3(0, 1.7, 0), top + Vector3(0, 1.8, 0)))
	if not clearance.is_empty():
		return false
	global_transform.origin = top + Vector3(0, 0.1, 0)
	velocity = Vector3.ZERO
	return true
