extends Control

@onready var subviewport: SubViewport = $SubViewportContainer/SubViewport

func _ready():
	_resize_subviewport()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_resize_subviewport()

func _resize_subviewport():
	if subviewport:
		var sz := Vector2i(get_viewport().get_visible_rect().size)
		subviewport.size = sz
