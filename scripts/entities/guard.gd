# guard.gd
# Minimal guard with waypoint patrol and LOS detection
extends CharacterBody3D

@export var speed: float = 3.0
@export var fov_deg: float = 70.0
@export var view_range: float = 15.0
@export var player_path: NodePath
@export var suspicion_rate: float = 20.0
@export var suspicion_decay: float = 8.0
# Chase behavior
@export var chase_threshold: float = 60.0
@export var resume_threshold: float = 30.0
@export var chase_speed: float = 6.0
# Search behavior
@export var search_time: float = 3.0
@export var search_speed: float = 3.3
var suspicion: float = 0.0
var chasing: bool = false
var searching: bool = false
var _search_timer: float = 0.0
var _last_seen_pos: Vector3 = Vector3.ZERO
var _osc_time: float = 0.0

var player: Node3D
var waypoints: Array[Node3D] = []
var _current_wp: int = 0

func _ready():
	# Cache player and waypoints
	if player_path != NodePath(""):
		player = get_node(player_path)
	# Collect waypoints from a child container named "Waypoints"
	if has_node("Waypoints"):
		for child in get_node("Waypoints").get_children():
			if child is Node3D:
				waypoints.append(child)
	if waypoints.is_empty():
		push_warning("Guard has no waypoints; will idle.")

func _physics_process(delta):
	# Base patrol movement (will be overridden by chase/search states)
	if not waypoints.is_empty():
		var target := waypoints[_current_wp].global_transform.origin
		var to_target := target - global_transform.origin
		if to_target.length() > 0.2:
			var dir := to_target.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			look_at(global_transform.origin + dir, Vector3.UP)
		else:
			_current_wp = (_current_wp + 1) % waypoints.size()
	else:
		velocity.x = 0
		velocity.z = 0

	# Detection and state
	var saw := player and can_see_player(player.global_transform.origin)
	if saw:
		_last_seen_pos = player.global_transform.origin
		suspicion = min(100.0, suspicion + suspicion_rate * delta)
	else:
		suspicion = max(0.0, suspicion - suspicion_decay * delta)

	# Transitions
	var hud := get_tree().get_first_node_in_group("hud")
	# Enter chase when seeing and above threshold
	if saw and suspicion >= chase_threshold and not chasing:
		chasing = true
		searching = false
		if hud and hud.has_method("show_message"):
			hud.show_message("Chased!", 1.2)
	# Lose sight during chase -> start search
	elif not saw and chasing:
		chasing = false
		searching = true
		_search_timer = search_time
		if hud and hud.has_method("show_message"):
			hud.show_message("Lost sight...", 1.2)
	# Resume patrol when suspicion low or search timeout
	elif searching and (suspicion <= resume_threshold or _search_timer <= 0.0):
		searching = false
		if hud and hud.has_method("show_message"):
			hud.show_message("Evaded", 1.0)

	# Movement override when chasing
	if chasing and player:
		var to_player := player.global_transform.origin - global_transform.origin
		var dir2 := to_player.normalized()
		velocity.x = dir2.x * chase_speed
		velocity.z = dir2.z * chase_speed
		look_at(global_transform.origin + dir2, Vector3.UP)

	# Movement and behavior when searching
	if searching:
		# Decay faster during search
		suspicion = max(0.0, suspicion - (suspicion_decay * 1.5) * delta)
		var to_last := _last_seen_pos - global_transform.origin
		if to_last.length() > 0.25:
			var dir3 := to_last.normalized()
			velocity.x = dir3.x * search_speed
			velocity.z = dir3.z * search_speed
			look_at(global_transform.origin + dir3, Vector3.UP)
		else:
			# Oscillate look while stationary
			_osc_time += delta
			rotate_y(sin(_osc_time * 2.5) * delta * 1.2)
			velocity.x = 0
			velocity.z = 0
		_search_timer -= delta

	# Update HUD suspicion
	if hud and hud.has_method("update_suspicion"):
		hud.update_suspicion(suspicion)

	# Caught flow: emit signal after brief hold above threshold
	if suspicion >= catch_threshold:
		_caught_hold += delta
		if _caught_hold >= catch_hold_time:
			emit_signal("caught_player")
	else:
		_caught_hold = 0.0
	
	move_and_slide()

func can_see_player(ppos: Vector3) -> bool:
	var origin := global_transform.origin
	var to_player := ppos - origin
	var dist := to_player.length()
	if dist > view_range:
		return false
	var forward := -global_transform.basis.z
	var angle: float = rad_to_deg(acos(clamp(forward.normalized().dot(to_player.normalized()), -1.0, 1.0)))
	if angle > fov_deg * 0.5:
		return false
	# Line of sight raycast
	var space := get_world_3d().direct_space_state
	var res := space.intersect_ray(PhysicsRayQueryParameters3D.create(origin + Vector3(0,1.6,0), ppos))
	if res.is_empty():
		return false
	return res.get("collider") == player

signal caught_player
@export var catch_threshold: float = 100.0
@export var catch_hold_time: float = 0.2
var _caught_hold: float = 0.0
