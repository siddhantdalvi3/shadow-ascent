extends Node

# Game state data
var current_floor = 1
var player_progress = {
	"floors_completed": 0,
	"total_time": 0.0,
	"total_detections": 0,
	"best_grades": {}
}

# Last floor results for results screen
var last_floor_results = {
	"floor_number": 1,
	"floor_name": "Lobby & Utilities",
	"completion_time": 0.0,
	"objectives_completed": 0,
	"total_objectives": 3,
	"detections": 0,
	"grade": "F"
}

# Player loadout
var selected_weapon = ""
var selected_tools = []
var inventory = {
	"keys": {},
	"tools": {},
	"ammo": {},
	"health_kits": 0,
	"buffs": []
}

func _ready():
	# Initialize game data
	reset_game_data()

func reset_game_data():
	current_floor = 1
	player_progress = {
		"floors_completed": 0,
		"total_time": 0.0,
		"total_detections": 0,
		"best_grades": {}
	}
	inventory = {
		"keys": {},
		"tools": {},
		"ammo": {},
		"health_kits": 0,
		"buffs": []
	}

func advance_to_next_floor():
	current_floor += 1
	player_progress.floors_completed += 1

func calculate_grade(objectives_completed: int, total_objectives: int, completion_time: float, detections: int, optional_bonuses: int = 0) -> String:
	var objective_ratio = float(objectives_completed) / float(total_objectives)
	var base_score = objective_ratio * 100
	var time_modifier = 0
	
	# Time bonus/penalty (assuming 60 seconds is par time)
	if completion_time < 30:
		time_modifier = 20
	elif completion_time < 60:
		time_modifier = 10
	elif completion_time > 120:
		time_modifier = -20
	
	# Detection penalty
	var detection_penalty = detections * 5
	var bonus = optional_bonuses * 10
	var final_score = base_score + time_modifier - detection_penalty + bonus
	
	if final_score >= 90:
		return "S"
	elif final_score >= 80:
		return "A"
	elif final_score >= 70:
		return "B"
	elif final_score >= 60:
		return "C"
	else:
		return "F"

func get_floor_name(floor_number: int) -> String:
	match floor_number:
		1:
			return "Lobby & Utilities"
		2:
			return "Residential"
		3:
			return "Security Hub"
		4:
			return "Atrium Raceway"
		5:
			return "Executive Offices"
		6:
			return "Penthouse"
		_:
			return "Unknown Floor"

func add_item(category: String, id: String, amount: int = 1):
	if not inventory.has(category):
		return
	var c = inventory[category]
	if typeof(c) == TYPE_DICTIONARY:
		c[id] = (c.get(id, 0) + amount)
		inventory[category] = c
	elif typeof(c) == TYPE_INT:
		inventory[category] = c + amount

func consume_item(category: String, id: String, amount: int = 1) -> bool:
	if not inventory.has(category):
		return false
	var c = inventory[category]
	if typeof(c) == TYPE_DICTIONARY:
		var cur = int(c.get(id, 0))
		if cur < amount:
			return false
		c[id] = cur - amount
		inventory[category] = c
		return true
	elif typeof(c) == TYPE_INT:
		if c < amount:
			return false
		inventory[category] = c - amount
		return true
	return false

func has_item(category: String, id: String) -> bool:
	if not inventory.has(category):
		return false
	var c = inventory[category]
	if typeof(c) == TYPE_DICTIONARY:
		return c.get(id, 0) > 0
	return false

func add_buff(buff_type: String, value: float, duration_sec: int):
	var expiry = int(Time.get_time_dict_from_system()["unix"]) + duration_sec
	inventory.buffs.append({"type": buff_type, "value": value, "expiry": expiry})

func get_active_buffs() -> Array:
	var now = int(Time.get_time_dict_from_system()["unix"]) 
	var active: Array = []
	for b in inventory.buffs:
		if b.expiry > now:
			active.append(b)
	return active
