extends Control

signal finished(success, reward_data)

var _button

func _ready():
    set_anchors_preset(Control.PRESET_FULL_RECT)
    _button = Button.new()
    _button.text = "Solve Locker Code"
    _button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _button.size_flags_vertical = Control.SIZE_EXPAND_FILL
    add_child(_button)
    _button.pressed.connect(_on_press)

func _on_press():
    emit_signal("finished", true, {"key_id":"elevator_keycard"})
    queue_free()
