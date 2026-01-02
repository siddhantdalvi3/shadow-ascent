# bootstrap_input.gd
# Ensures InputMap actions exist and are bound for immediate play.
extends Node

func _ready():
	setup_input_actions()

func setup_input_actions():
	var actions := {
		"move_forward": [KEY_W, KEY_UP],
		"move_back": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE],
		"sprint": [KEY_SHIFT],
		"crouch": [KEY_CTRL],
		"interact": [KEY_E],
		"pause": [KEY_ESCAPE]
	}
	for action in actions.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode in actions[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = keycode
			InputMap.action_add_event(action, ev)
	# Back-compat for older action names found in player.gd before rewrite
	var legacy := {
		"forward": [KEY_W, KEY_UP],
		"backward": [KEY_S, KEY_DOWN],
		"left": [KEY_A, KEY_LEFT],
		"right": [KEY_D, KEY_RIGHT]
	}
	for action in legacy.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode in legacy[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = keycode
			InputMap.action_add_event(action, ev)
