extends Control

@onready var floor_title = $HBoxContainer/BriefingPanel/FloorTitle
@onready var begin_floor_button = $HBoxContainer/LoadoutPanel/BeginFloorButton

# Weapon buttons
@onready var pistol_button = $HBoxContainer/LoadoutPanel/WeaponGrid/PistolButton
@onready var rifle_button = $HBoxContainer/LoadoutPanel/WeaponGrid/RifleButton
@onready var shotgun_button = $HBoxContainer/LoadoutPanel/WeaponGrid/ShotgunButton
@onready var smg_button = $HBoxContainer/LoadoutPanel/WeaponGrid/SMGButton

# Tool buttons
@onready var flashlight_button = $HBoxContainer/LoadoutPanel/ToolGrid/FlashlightButton
@onready var medkit_button = $HBoxContainer/LoadoutPanel/ToolGrid/MedkitButton
@onready var keycard_button = $HBoxContainer/LoadoutPanel/ToolGrid/KeycardButton
@onready var grapple_button = $HBoxContainer/LoadoutPanel/ToolGrid/GrappleButton

var current_floor = 1
var selected_weapon = ""
var selected_tools = []

func _ready():
	# Connect button signals
	begin_floor_button.pressed.connect(_on_begin_floor_pressed)
	
	# Connect weapon buttons
	pistol_button.pressed.connect(_on_weapon_selected.bind("Pistol"))
	rifle_button.pressed.connect(_on_weapon_selected.bind("Rifle"))
	shotgun_button.pressed.connect(_on_weapon_selected.bind("Shotgun"))
	smg_button.pressed.connect(_on_weapon_selected.bind("SMG"))
	
	# Connect tool buttons
	flashlight_button.toggled.connect(_on_tool_toggled.bind("Flashlight"))
	medkit_button.toggled.connect(_on_tool_toggled.bind("Medkit"))
	keycard_button.toggled.connect(_on_tool_toggled.bind("Keycard"))
	grapple_button.toggled.connect(_on_tool_toggled.bind("Grapple"))
	
	# Set tool buttons as toggle buttons
	flashlight_button.toggle_mode = true
	medkit_button.toggle_mode = true
	keycard_button.toggle_mode = true
	grapple_button.toggle_mode = true
	
	# Update floor info
	_update_floor_info()
	
	# Fade in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _update_floor_info():
	match current_floor:
		1:
			floor_title.text = "FLOOR 1: LOBBY & UTILITIES"
		2:
			floor_title.text = "FLOOR 2: RESIDENTIAL"
		3:
			floor_title.text = "FLOOR 3: SECURITY HUB"
		4:
			floor_title.text = "FLOOR 4: ATRIUM RACEWAY"
		5:
			floor_title.text = "FLOOR 5: EXECUTIVE OFFICES"
		6:
			floor_title.text = "FLOOR 6: PENTHOUSE"

func _on_weapon_selected(weapon_name: String):
	selected_weapon = weapon_name
	print("Selected weapon: ", weapon_name)
	
	# Update button states
	pistol_button.button_pressed = (weapon_name == "Pistol")
	rifle_button.button_pressed = (weapon_name == "Rifle")
	shotgun_button.button_pressed = (weapon_name == "Shotgun")
	smg_button.button_pressed = (weapon_name == "SMG")

func _on_tool_toggled(tool_name: String, pressed: bool):
	if pressed:
		if tool_name not in selected_tools:
			selected_tools.append(tool_name)
	else:
		selected_tools.erase(tool_name)
	
	print("Selected tools: ", selected_tools)

func _on_begin_floor_pressed():
	print("Beginning floor: ", GameData.current_floor)
	print("Selected weapon: ", selected_weapon)
	print("Selected tools: ", selected_tools)
	
	# Store loadout in GameData
	GameData.selected_weapon = selected_weapon
	GameData.selected_tools = selected_tools
	
	# Navigate to appropriate floor scene
	var floor_scene: String
	if GameData.current_floor == 1:
		floor_scene = "res://scenes/floors/TutorialFloor.tscn"
	else:
		floor_scene = "res://scenes/floors/GameFloor.tscn"
	
	_transition_to_scene(floor_scene)

func _transition_to_scene(scene_path: String):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file(scene_path))
