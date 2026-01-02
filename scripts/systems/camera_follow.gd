# camera_follow.gd
# Simple third-person camera that orbits around a target and follows.
extends Camera3D

@export var target_path: NodePath
@export var distance: float = 6.0
@export var height: float = 2.0
@export var mouse_sensitivity: float = 0.15
@export var min_pitch_deg: float = -20.0
@export var max_pitch_deg: float = 60.0

var _target: Node3D
var _yaw: float = 0.0
var _pitch: float = 10.0

func _ready():
	if target_path != NodePath(""):
		_target = get_node(target_path)
	if _target == null:
		push_warning("CameraFollow has no target set.")
	# Capture mouse when running; press Escape to release (optional for dev)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * mouse_sensitivity * 0.01 * TAU
		_pitch = clamp(_pitch - event.relative.y * mouse_sensitivity * 0.01 * TAU, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	if _target == null:
		return
	# Calculate camera position on an orbit around the target.
	var offset := Vector3(
		cos(_yaw) * distance,
		height,
		sin(_yaw) * distance
	)
	global_position = _target.global_transform.origin + offset.rotated(Vector3(0,1,0), 0)
	look_at(_target.global_transform.origin + Vector3(0, height * 0.5, 0), Vector3.UP)
