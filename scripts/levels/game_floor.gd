extends Node3D

@onready var floor_title = $GameUI/TopPanel/FloorInfo/FloorTitle
@onready var timer_label = $GameUI/TopPanel/FloorInfo/Timer
@onready var status_label = $GameUI/BottomPanel/StatusContainer/StatusLabel
@onready var obj1_checkbox = $GameUI/TopPanel/ObjectivesPanel/ObjectivesList/Obj1
@onready var obj2_checkbox = $GameUI/TopPanel/ObjectivesPanel/ObjectivesList/Obj2
@onready var obj3_checkbox = $GameUI/TopPanel/ObjectivesPanel/ObjectivesList/Obj3
@onready var pause_button = $GameUI/BottomPanel/StatusContainer/ButtonContainer/PauseButton
@onready var complete_floor_button = $GameUI/BottomPanel/StatusContainer/ButtonContainer/CompleteFloorButton

var floor_start_time: float
var objectives_completed = 0
var total_objectives = 3
var detections = 0
var is_paused = false
var optional_bonuses = 0
var objective_manager

func _ready():
	# Connect button signals
	pause_button.pressed.connect(_on_pause_pressed)
	complete_floor_button.pressed.connect(_on_complete_floor_pressed)
	
	# Initialize floor
	_initialize_floor()
	floor_start_time = Time.get_time_dict_from_system()["unix"]
	
	# Fade in
	$GameUI.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property($GameUI, "modulate:a", 1.0, 0.5)

func _initialize_floor():
	var current_floor = GameData.current_floor
	var floor_name = GameData.get_floor_name(current_floor)
	
	floor_title.text = "FLOOR %d: %s" % [current_floor, floor_name.to_upper()]
	
	objective_manager = load("res://scripts/systems/objective_manager.gd").new()
	add_child(objective_manager)
	objective_manager.objective_completed.connect(_on_objective_completed)
	match current_floor:
		2:  # Residential
			objective_manager.add_objective({"id":"locker_code","title":"Locker code mini-game","type":"mini_game","status":"pending","reward":{"key_id":"elevator_keycard"}})
			objective_manager.add_objective({"id":"access_terminal","title":"Access security terminal","type":"puzzle","status":"pending","dependencies":["locker_code"]})
			objective_manager.add_objective({"id":"reach_elevator","title":"Reach elevator","type":"navigate","status":"pending","dependencies":["access_terminal"]})
			obj1_checkbox.text = "Locker code mini-game"
			obj2_checkbox.text = "Access security terminal"
			obj3_checkbox.text = "Reach elevator"
		3:  # Security Hub
			objective_manager.add_objective({"id":"sudoku","title":"Sudoku terminal","type":"mini_game","status":"pending","reward":{"camera_disable":true}})
			objective_manager.add_objective({"id":"hack_server","title":"Hack central server","type":"npc_task","status":"pending","dependencies":["sudoku"]})
			objective_manager.add_objective({"id":"extract_data","title":"Extract security data","type":"navigate","status":"pending","dependencies":["hack_server"]})
			obj1_checkbox.text = "Sudoku terminal"
			obj2_checkbox.text = "Hack central server"
			obj3_checkbox.text = "Extract security data"
		4:  # Atrium Raceway
			objective_manager.add_objective({"id":"rc_race","title":"Complete RC race","type":"mini_game","status":"pending","reward":{"buff":{"type":"sprint","value":0.1,"duration":120}}})
			objective_manager.add_objective({"id":"avoid_detection","title":"Avoid detection systems","type":"navigate","status":"pending","dependencies":["rc_race"]})
			objective_manager.add_objective({"id":"reach_upper","title":"Reach upper levels","type":"navigate","status":"pending","dependencies":["avoid_detection"]})
			obj1_checkbox.text = "Complete RC race"
			obj2_checkbox.text = "Avoid detection systems"
			obj3_checkbox.text = "Reach upper levels"
		5:  # Executive Offices
			obj1_checkbox.text = "Infiltrate executive area"
			obj2_checkbox.text = "Access CEO terminal"
			obj3_checkbox.text = "Download classified files"
		6:  # Penthouse
			obj1_checkbox.text = "Reach penthouse level"
			obj2_checkbox.text = "Confront the truth"
			obj3_checkbox.text = "Escape with evidence"
		_:
			obj1_checkbox.text = "Complete primary objective"
			obj2_checkbox.text = "Complete secondary objective"
			obj3_checkbox.text = "Reach floor exit"

func _process(delta):
	if not is_paused:
		_update_timer()

func _update_timer():
	var current_time = Time.get_time_dict_from_system()["unix"]
	var elapsed = current_time - floor_start_time
	var minutes = int(elapsed / 60)
	var seconds = int(elapsed) % 60
	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

func _on_objective_completed(id, reward):
	objectives_completed += 1
	if id == "locker_code":
		obj1_checkbox.button_pressed = true
		status_label.text = "Status: Locker mini-game completed"
		if reward.has("key_id"):
			GameData.add_item("keys", reward.key_id, 1)
	elif id == "access_terminal" or id == "avoid_detection" or id == "hack_server" or id == "extract_data" or id == "reach_elevator" or id == "reach_upper":
		if objectives_completed == 1:
			obj1_checkbox.button_pressed = true
		elif objectives_completed == 2:
			obj2_checkbox.button_pressed = true
		elif objectives_completed >= 3:
			obj3_checkbox.button_pressed = true
		status_label.text = "Status: Objective completed"
	elif id == "sudoku":
		obj1_checkbox.button_pressed = true
		status_label.text = "Status: Sudoku completed"
	elif id == "rc_race":
		obj1_checkbox.button_pressed = true
		status_label.text = "Status: RC race completed"
		if reward.has("buff"):
			GameData.add_buff(reward.buff.type, reward.buff.value, int(reward.buff.duration))
			optional_bonuses += 1
	if objectives_completed >= total_objectives:
		complete_floor_button.text = "Proceed to Results"

func _complete_objective(objective_number: int):
	if objective_number == 1:
		var o = objective_manager.objectives[0]
		objective_manager.complete(o.id)
	elif objective_number == 2 and objective_manager.objectives.size() > 1:
		var o2 = objective_manager.objectives[1]
		if not objective_manager.is_blocked(o2.id):
			objective_manager.complete(o2.id)
	elif objective_number == 3 and objective_manager.objectives.size() > 2:
		var o3 = objective_manager.objectives[2]
		if not objective_manager.is_blocked(o3.id):
			objective_manager.complete(o3.id)

func _on_pause_pressed():
	is_paused = !is_paused
	if is_paused:
		pause_button.text = "Resume"
		status_label.text = "Status: Game Paused"
		get_tree().paused = true
	else:
		pause_button.text = "Pause"
		status_label.text = "Status: Infiltrating..."
		get_tree().paused = false

func _on_complete_floor_pressed():
	var current_time = Time.get_time_dict_from_system()["unix"]
	var completion_time = current_time - floor_start_time
	var grade = GameData.calculate_grade(objectives_completed, total_objectives, completion_time, detections, optional_bonuses)
	GameData.last_floor_results = {
		"floor_number": GameData.current_floor,
		"floor_name": GameData.get_floor_name(GameData.current_floor),
		"completion_time": completion_time,
		"objectives_completed": objectives_completed,
		"total_objectives": total_objectives,
		"detections": detections,
		"grade": grade
	}
	GameData.player_progress.total_time += completion_time
	GameData.player_progress.total_detections += detections
	if not GameData.player_progress.best_grades.has(GameData.current_floor):
		GameData.player_progress.best_grades[GameData.current_floor] = grade
	else:
		var prev = String(GameData.player_progress.best_grades[GameData.current_floor])
		if _grade_better(grade, prev):
			GameData.player_progress.best_grades[GameData.current_floor] = grade
	
	print("Floor %d completed!" % GameData.current_floor)
	print("Time: %.1fs, Objectives: %d/%d, Grade: %s" % [completion_time, objectives_completed, total_objectives, grade])
	
	_transition_to_results()

func _transition_to_results():
	var tween = create_tween()
	tween.tween_property($GameUI, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/ui/FloorResults.tscn"))

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				if objectives_completed == 0:
					_complete_objective(1)
			KEY_2:
				if objectives_completed == 1:
					_complete_objective(2)
			KEY_3:
				if objectives_completed == 2:
					_complete_objective(3)
			KEY_D:
				detections += 1
				status_label.text = "Status: DETECTED! Detections: %d" % detections
			KEY_M:
				_open_minigame_for_current_floor()
			KEY_E:
				_complete_npc_task()

func _open_minigame_for_current_floor():
	var f = GameData.current_floor
	if f == 2:
		objective_manager.complete("locker_code", {"key_id":"elevator_keycard"})
	elif f == 3:
		objective_manager.complete("sudoku", {"camera_disable":true})
	elif f == 4:
		objective_manager.complete("rc_race", {"buff":{"type":"sprint","value":0.1,"duration":120}})

func _complete_npc_task():
	var f = GameData.current_floor
	if f == 3:
		if not objective_manager.is_blocked("hack_server"):
			objective_manager.complete("hack_server")
	elif f == 2:
		if not objective_manager.is_blocked("access_terminal"):
			objective_manager.complete("access_terminal")

func _grade_better(a: String, b: String) -> bool:
	var order := ["F","C","B","A","S"]
	return order.find(a) > order.find(b)
