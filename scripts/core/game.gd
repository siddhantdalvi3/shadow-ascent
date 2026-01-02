# game.gd
# Game coordinator: handles caught flow and goal completion
extends Node

@onready var hud := get_tree().get_first_node_in_group("hud")
@onready var guard := get_parent().get_node_or_null("Guard")
@onready var player := get_parent().get_node_or_null("Player")
@onready var goal := get_parent().get_node_or_null("Goal")

func _ready():
	# Connect guard caught
	if guard and guard.has_signal("caught_player"):
		guard.connect("caught_player", Callable(self, "_on_caught"))
	# Connect goal area
	if goal and goal is Area3D:
		goal.body_entered.connect(_on_goal_body_entered)

func _on_caught():
	if hud and hud.has_method("show_message"):
		hud.show_message("Caught! Restarting...", 1.5)
	# Restart scene after a short delay
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()

func _on_goal_body_entered(body):
	if body == player:
		if hud and hud.has_method("show_message"):
			hud.show_message("Level Complete!", 2.0)
