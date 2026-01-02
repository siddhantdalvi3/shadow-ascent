extends StaticBody3D

func interact():
	print("Box interacted!")
	var mesh = $MeshInstance3D
	if mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(randf(), randf(), randf())
		mesh.material_override = mat
