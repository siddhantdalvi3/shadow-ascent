extends CharacterBody3D

signal npc_helped

var helped: bool = false

func interact():
	if helped: return
	helped = true
	print("NPC assisted!")
	emit_signal("npc_helped")
	
	# Visual feedback (jump for joy)
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 0.5, 0.2)
	tween.tween_property(self, "position:y", position.y, 0.2)
