extends Control

@onready var start_game_button = $CenterContainer/VBoxContainer/MenuButtons/StartGameButton
@onready var options_button = $CenterContainer/VBoxContainer/MenuButtons/OptionsButton
@onready var credits_button = $CenterContainer/VBoxContainer/MenuButtons/CreditsButton
@onready var exit_button = $CenterContainer/VBoxContainer/MenuButtons/ExitButton
@onready var menu_viewport = $MenuBackground/SubViewportContainer/SubViewport

func _ready():
	# Connect button signals
	start_game_button.pressed.connect(_on_start_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Focus the start game button
	start_game_button.grab_focus()
	
	# Fade in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

	# Load Kenney city diorama into SubViewport
	_load_menu_city()

func _on_start_game_pressed():
	print("Starting game...")
	_transition_to_scene("res://scenes/ui/FloorBriefing.tscn")

func _on_options_pressed():
	print("Options menu - Not implemented yet")
	# TODO: Implement options menu

func _on_credits_pressed():
	print("Credits - Not implemented yet")
	# TODO: Implement credits screen

func _on_exit_pressed():
	print("Exiting game...")
	get_tree().quit()

func _transition_to_scene(scene_path: String):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file(scene_path))

func _load_menu_city():
	var scene: PackedScene = load("res://scenes/MenuCity.tscn")
	if scene and menu_viewport:
		var root := scene.instantiate()
		menu_viewport.add_child(root)
		menu_viewport.size = Vector2(get_viewport().size.x, get_viewport().size.y)
