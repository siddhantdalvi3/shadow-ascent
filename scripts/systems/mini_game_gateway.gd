extends Node3D

signal completed(success, reward_data)

@export var mini_game_path: String = ""
@export var reward_type: String = ""
@export var reward_payload: Variant
@export var time_cost: float = 0.0

var _instance

func open():
	if mini_game_path == "":
		emit_signal("completed", true, reward_payload)
		return
	var ps: PackedScene = load(mini_game_path)
	if ps:
		_instance = ps.instantiate()
		get_tree().root.add_child(_instance)
		if _instance.has_signal("finished"):
			_instance.connect("finished", Callable(self, "_on_finished"))
	else:
		emit_signal("completed", true, reward_payload)

func _on_finished(success, data):
	if _instance:
		_instance.queue_free()
		_instance = null
	emit_signal("completed", success, data)
