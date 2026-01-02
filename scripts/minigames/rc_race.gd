extends Control

signal finished(success, reward_data)

var _button
var _label
var _start_time: float

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_label = Label.new()
	_label.text = "RC Race"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_label)
	_button = Button.new()
	_button.text = "Finish Race"
	_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_button)
	_button.pressed.connect(_on_press)
	_start_time = float(Time.get_time_dict_from_system()["unix"])

func _on_press():
	var elapsed := float(Time.get_time_dict_from_system()["unix"]) - _start_time
	var reward := {"buff":{"type":"sprint","value":0.1,"duration":120}, "time": elapsed}
	emit_signal("finished", true, reward)
	queue_free()
