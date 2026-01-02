extends Node3D

signal completed(reward_data)

@export var reward_key_id: String = ""

func accept_and_start():
	await get_tree().create_timer(1.0).timeout
	var reward := {}
	if reward_key_id != "":
		reward = {"key_id": reward_key_id}
	emit_signal("completed", reward)
