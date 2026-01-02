extends Control

@onready var press_any_key_label = $CenterContainer/VBoxContainer/PressAnyKey
@onready var animation_player = $AnimationPlayer
@onready var menu_viewport = $MenuBackground/SubViewportContainer/SubViewport

var can_continue = false

func _ready():
	# Start fade-in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.5)
	tween.tween_callback(_enable_input)
	
	# Start blinking animation for "Press any key"
	_start_blink_animation()

	# Load Kenney city diorama into SubViewport
	_load_menu_city()

func _enable_input():
	can_continue = true

func _start_blink_animation():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(press_any_key_label, "modulate:a", 0.3, 1.0)
	tween.tween_property(press_any_key_label, "modulate:a", 1.0, 1.0)

func _load_menu_city():
	var scene: PackedScene = load("res://scenes/MenuCity.tscn")
	if scene and menu_viewport:
		var root := scene.instantiate()
		menu_viewport.add_child(root)
		menu_viewport.size = Vector2(get_viewport().size.x, get_viewport().size.y)

func _input(event):
	if can_continue and (event is InputEventKey or event is InputEventMouseButton):
		if event.pressed:
			_transition_to_main_menu()

func _transition_to_main_menu():
	can_continue = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_load_main_menu)

func _load_main_menu():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
