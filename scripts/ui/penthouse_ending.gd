extends Control

@onready var scroll_container = $ScrollingContainer
@onready var content_container = $ScrollingContainer/ContentContainer
@onready var floors_value = $ScrollingContainer/ContentContainer/StatsContainer/StatsGrid/FloorsValue
@onready var time_value = $ScrollingContainer/ContentContainer/StatsContainer/StatsGrid/TimeValue
@onready var detections_value = $ScrollingContainer/ContentContainer/StatsContainer/StatsGrid/DetectionsValue
@onready var overall_grade_value = $ScrollingContainer/ContentContainer/StatsContainer/StatsGrid/OverallGradeValue
@onready var play_again_button = $ScrollingContainer/ContentContainer/ButtonContainer/PlayAgainButton
@onready var main_menu_button = $ScrollingContainer/ContentContainer/ButtonContainer/MainMenuButton

var auto_scroll_speed = 30.0  # pixels per second
var is_auto_scrolling = true

func _ready():
	# Connect button signals
	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Display final statistics
	_display_final_stats()
	
	# Start fade in and auto-scroll
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	tween.tween_callback(_start_auto_scroll)

func _display_final_stats():
	# Calculate final statistics from GameData
	var progress = GameData.player_progress
	
	floors_value.text = "%d/6" % progress.floors_completed
	
	# Format total time
	var minutes = int(progress.total_time / 60)
	var seconds = int(progress.total_time) % 60
	time_value.text = "%d:%02d" % [minutes, seconds]
	
	detections_value.text = str(progress.total_detections)
	
	# Calculate overall grade
	var overall_grade = _calculate_overall_grade()
	overall_grade_value.text = overall_grade
	
	# Color the grade
	match overall_grade:
		"S":
			overall_grade_value.modulate = Color.GOLD
		"A":
			overall_grade_value.modulate = Color.GREEN
		"B":
			overall_grade_value.modulate = Color.CYAN
		"C":
			overall_grade_value.modulate = Color.YELLOW
		"F":
			overall_grade_value.modulate = Color.RED

func _calculate_overall_grade() -> String:
	var progress = GameData.player_progress
	
	# Base score from completion
	var completion_ratio = float(progress.floors_completed) / 6.0
	var base_score = completion_ratio * 100
	
	# Time bonus (assuming 15 minutes is par time for full game)
	var time_modifier = 0
	if progress.total_time < 600:  # 10 minutes
		time_modifier = 20
	elif progress.total_time < 900:  # 15 minutes
		time_modifier = 10
	elif progress.total_time > 1800:  # 30 minutes
		time_modifier = -20
	
	# Detection penalty
	var detection_penalty = progress.total_detections * 3
	
	var final_score = base_score + time_modifier - detection_penalty
	
	if final_score >= 95:
		return "S"
	elif final_score >= 85:
		return "A"
	elif final_score >= 75:
		return "B"
	elif final_score >= 65:
		return "C"
	else:
		return "F"

func _start_auto_scroll():
	# Begin automatic scrolling through the ending
	is_auto_scrolling = true

func _process(delta):
	if is_auto_scrolling:
		var current_scroll = scroll_container.scroll_vertical
		var max_scroll = content_container.size.y - scroll_container.size.y
		
		if current_scroll < max_scroll:
			scroll_container.scroll_vertical += auto_scroll_speed * delta
		else:
			is_auto_scrolling = false

func _input(event):
	# Allow player to control scrolling
	if event is InputEventMouseButton or event is InputEventKey:
		is_auto_scrolling = false

func _on_play_again_pressed():
	print("Starting new game...")
	# Reset game data
	GameData.reset_game_data()
	_transition_to_scene("res://scenes/ui/WelcomeScreen.tscn")

func _on_main_menu_pressed():
	print("Returning to main menu...")
	_transition_to_scene("res://scenes/ui/MainMenu.tscn")

func _transition_to_scene(scene_path: String):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file(scene_path))
