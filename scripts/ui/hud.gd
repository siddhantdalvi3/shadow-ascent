# hud.gd
# Simple HUD displaying suspicion percentage
extends CanvasLayer

@onready var label: Label = $Suspicion
var _suspicion: float = 0.0
@onready var msg_label: Label = $Message
func update_suspicion(value: float):
	_suspicion = clamp(value, 0.0, 100.0)
	label.text = "Suspicion: %d%%" % int(round(_suspicion))
	# Color feedback: green <30, yellow <70, red otherwise
	var col := Color(0.2, 0.9, 0.2)
	if _suspicion >= 70.0:
		col = Color(0.9, 0.2, 0.2)
	elif _suspicion >= 30.0:
		col = Color(0.95, 0.75, 0.15)
	label.add_theme_color_override("font_color", col)

func show_message(text: String, seconds: float = 1.0):
	msg_label.text = text
	msg_label.visible = true
	await get_tree().create_timer(seconds).timeout
	msg_label.visible = false
