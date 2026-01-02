extends Control

@onready var floor_name_label = $CenterContainer/ResultsPanel/FloorInfo/FloorName
@onready var time_value = $CenterContainer/ResultsPanel/ResultsGrid/TimeValue
@onready var objectives_value = $CenterContainer/ResultsPanel/ResultsGrid/ObjectivesValue
@onready var detections_value = $CenterContainer/ResultsPanel/ResultsGrid/DetectionsValue
@onready var grade_value = $CenterContainer/ResultsPanel/GradeContainer/GradeValue
@onready var rewards_list = $CenterContainer/ResultsPanel/RewardsList
@onready var retry_button = $CenterContainer/ResultsPanel/ButtonContainer/RetryButton
@onready var continue_button = $CenterContainer/ResultsPanel/ButtonContainer/ContinueButton
@onready var main_menu_button = $CenterContainer/ResultsPanel/ButtonContainer/MainMenuButton

func _ready():
	# Connect button signals
	retry_button.pressed.connect(_on_retry_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Display results
	_display_results()
	
	# Fade in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _display_results():
	var results = GameData.last_floor_results
	
	# Update floor info
	floor_name_label.text = "FLOOR %d: %s" % [results.floor_number, results.floor_name.to_upper()]
	
	# Update stats
	time_value.text = "%.1fs" % results.completion_time
	objectives_value.text = "%d/%d" % [results.objectives_completed, results.total_objectives]
	detections_value.text = str(results.detections)
	
	# Update grade with color
	grade_value.text = results.grade
	match results.grade:
		"S":
			grade_value.modulate = Color.GOLD
		"A":
			grade_value.modulate = Color.GREEN
		"B":
			grade_value.modulate = Color.CYAN
		"C":
			grade_value.modulate = Color.YELLOW
		"F":
			grade_value.modulate = Color.RED
	
	# Update rewards based on performance
	_update_rewards(results)
	
	# Update button availability
	if results.floor_number >= 6:  # Penthouse completed
		continue_button.text = "View Ending"
	elif results.objectives_completed < results.total_objectives:
		continue_button.disabled = true
		continue_button.text = "Complete Objectives to Continue"

func _update_rewards(results):
	# Clear existing rewards
	for child in rewards_list.get_children():
		child.queue_free()
	
	# Add rewards based on performance
	if results.objectives_completed == results.total_objectives:
		_add_reward("• Floor Access: " + GameData.get_floor_name(results.floor_number + 1))
	
	var xp_reward = results.objectives_completed * 50
	if results.grade in ["A", "S"]:
		xp_reward += 50
	_add_reward("• Experience Points: +" + str(xp_reward))
	
	if results.detections == 0:
		_add_reward("• Stealth Bonus: +25 XP")
	
	if results.grade == "S":
		_add_reward("• Perfect Performance Bonus: +100 XP")

func _add_reward(text: String):
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rewards_list.add_child(label)

func _on_retry_pressed():
	print("Retrying floor...")
	_transition_to_scene("res://scenes/FloorBriefing.tscn")

func _on_continue_pressed():
	var results = GameData.last_floor_results
	
	if results.floor_number >= 6:
		# Go to ending
		_transition_to_scene("res://scenes/ui/PenthouseEnding.tscn")
	else:
		# Advance to next floor
		GameData.advance_to_next_floor()
		_transition_to_scene("res://scenes/ui/FloorBriefing.tscn")

func _on_main_menu_pressed():
	print("Returning to main menu...")
	_transition_to_scene("res://scenes/ui/MainMenu.tscn")

func _transition_to_scene(scene_path: String):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file(scene_path))
