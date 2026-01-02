extends Node

signal completed(reward_data)
signal failed(reason)

var state: String = "idle"

func offer():
	state = "offering"

func start():
	state = "active"

func complete(reward_data := {}):
	state = "completed"
	emit_signal("completed", reward_data)

func fail(reason := ""):
	state = "failed"
	emit_signal("failed", reason)
