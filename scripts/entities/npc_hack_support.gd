extends Node3D

signal completed(reward_data)

@export var hack_duration: float = 2.0

func begin_hack():
	await get_tree().create_timer(hack_duration).timeout
	emit_signal("completed", {"camera_disable": true})
