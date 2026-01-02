extends CharacterBody3D

signal zombie_died

@export var speed: float = 2.0
@export var detection_range: float = 10.0
@export var player_path: NodePath

var player: Node3D
var dead: bool = false

func _ready():
	if player_path:
		player = get_node(player_path)
	
	# Ensure we are in the "interactable" group or similar if we want to click to kill
	# For now, let's just make it simple: if player interacts, it dies.
	
func _physics_process(delta):
	if dead: return
	
	# Simple chase logic
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < detection_range:
			var dir = (player.global_position - global_position).normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			look_at(player.global_position, Vector3.UP)
		else:
			velocity.x = move_toward(velocity.x, 0, speed * delta)
			velocity.z = move_toward(velocity.z, 0, speed * delta)
	
	move_and_slide()

func interact():
	die()

func die():
	if dead: return
	dead = true
	print("Zombie cleared!")
	emit_signal("zombie_died")
	
	# Visual feedback (fall over and shrink)
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", -90.0, 0.5)
	# CharacterBody3D doesn't have modulate, so we scale down instead
	tween.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.5)
	tween.tween_callback(queue_free)
