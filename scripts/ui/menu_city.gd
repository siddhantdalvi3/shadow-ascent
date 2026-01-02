extends Node3D

@onready var pivot := $CameraPivot

var rotate_speed := 0.3

func _process(delta):
	if pivot:
		pivot.rotate_y(deg_to_rad(rotate_speed) * delta)
