@tool
extends Node3D

@export var bake_environment: bool = false: set = _set_bake_environment
@export var clear_environment: bool = false: set = _set_clear_environment

# UI Nodes (Lazy loaded to prevent editor errors)
var complete_floor_button: Button
var instruction_label: Label
var obj1_checkbox: CheckBox
var obj2_checkbox: CheckBox
var obj3_checkbox: CheckBox

var tutorial_step = 0
var objectives_completed = 0
var movement_learned = false
var zombies_cleared = 0
var npcs_helped = 0

func _ready():
	if Engine.is_editor_hint():
		# Editor-only logic: Ensure environment exists
		if not has_node("Environment"):
			print("Environment missing in editor, auto-generating...")
			_setup_environment()
		return
	
	# Initialize UI references safely
	complete_floor_button = get_node_or_null("TutorialUI/BottomPanel/TutorialText/ButtonContainer/CompleteFloorButton")
	instruction_label = get_node_or_null("TutorialUI/BottomPanel/TutorialText/InstructionLabel")
	obj1_checkbox = get_node_or_null("TutorialUI/TopPanel/FloorInfo/ObjectivesContainer/ObjectivesList/Obj1")
	obj2_checkbox = get_node_or_null("TutorialUI/TopPanel/FloorInfo/ObjectivesContainer/ObjectivesList/Obj2")
	obj3_checkbox = get_node_or_null("TutorialUI/TopPanel/FloorInfo/ObjectivesContainer/ObjectivesList/Obj3")
	
	if not has_node("Environment"):
		printerr("CRITICAL: Environment node is missing! Please check 'Bake Environment' in the editor before playing.")
	
	if complete_floor_button:
		complete_floor_button.pressed.connect(_on_complete_floor_pressed)
	else:
		print("WARNING: Tutorial UI nodes missing!")

	print("Starting Tutorial Floor...")
	
	# Start tutorial sequence
	_start_tutorial()
	_setup_fade_in()
	
	# Connect signals for baked entities (if they exist)
	_connect_baked_entities()

func _connect_baked_entities():
	# If zombies/NPCs were baked, find them and connect signals
	# Check the new "Entities" container first
	var entities_node = get_node_or_null("Environment/Entities")
	if entities_node:
		for child in entities_node.get_children():
			_connect_entity_signals(child)
		return

	# Fallback for old structure or direct children
	var env = get_node_or_null("Environment")
	if env:
		for child in env.get_children():
			_connect_entity_signals(child)

func _connect_entity_signals(child):
	if child.has_signal("zombie_died") and not child.zombie_died.is_connected(_on_zombie_cleared):
		child.zombie_died.connect(_on_zombie_cleared)
		# Adjust path for new depth (Environment/Entities/Zombie -> ../../../Player)
		# But since we might be in different depths, let's use a safe relative path
		# Player is usually a sibling of Environment.
		# TutorialFloor (self) -> Player
		# Zombie -> Entities -> Environment -> TutorialFloor -> Player
		child.player_path = NodePath("../../../Player")
		
	if child.has_signal("npc_helped") and not child.npc_helped.is_connected(_on_npc_helped):
		child.npc_helped.connect(_on_npc_helped)

func _set_bake_environment(value):
	if value:
		_setup_environment()
		bake_environment = false
		notify_property_list_changed() # Force editor update

func _set_clear_environment(value):
	if value:
		_clear_environment_nodes()
		clear_environment = false
		notify_property_list_changed() # Force editor update

func _clear_environment_nodes():
	if has_node("Environment"):
		$Environment.free()

func _setup_fade_in():
	var overlay = get_node_or_null("TutorialUI/FadeOverlay")
	if not overlay: return
	
	overlay.visible = true
	overlay.color = Color.BLACK
	overlay.modulate.a = 1.0
	
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): overlay.visible = false)

func _setup_environment():
	_clear_environment_nodes()
	
	# Create a container for the environment to keep the scene tree clean
	var env_container = Node3D.new()
	env_container.name = "Environment"
	add_child(env_container)
	env_container.owner = self # Bake the container itself

	# Organize into sub-containers
	var geometry_node = Node3D.new()
	geometry_node.name = "Geometry"
	env_container.add_child(geometry_node)
	geometry_node.owner = self

	var floors_node = Node3D.new()
	floors_node.name = "Floors"
	geometry_node.add_child(floors_node)
	floors_node.owner = self

	var walls_node = Node3D.new()
	walls_node.name = "Walls"
	geometry_node.add_child(walls_node)
	walls_node.owner = self

	var props_node = Node3D.new()
	props_node.name = "Props"
	env_container.add_child(props_node)
	props_node.owner = self
	# Reverting Y offset as user reported floating issues.
	# Resetting to 0.0 (Ground level)
	props_node.position.y = 0.0

	var shelves_node = Node3D.new()
	shelves_node.name = "Shelves"
	props_node.add_child(shelves_node)
	shelves_node.owner = self

	var furniture_node = Node3D.new()
	furniture_node.name = "Furniture"
	props_node.add_child(furniture_node)
	furniture_node.owner = self

	var scatter_node = Node3D.new()
	scatter_node.name = "Scatter"
	props_node.add_child(scatter_node)
	scatter_node.owner = self
	
	var entities_node = Node3D.new()
	entities_node.name = "Entities"
	env_container.add_child(entities_node)
	entities_node.owner = self
	# Resetting to 0.0 to match props
	entities_node.position.y = 0.0
	
	# Dynamic Market Generation using Mini Market Kit
	var market_kit_path = "res://assets/kits/kenney_mini-market/Models/FBX format/"
	
	# Scale factor: Kenney's FBX models are roughly 1 unit base.
	# We scale them up to be "chunky" and fill the view.
	var S = 3.0
	# Store scale for other functions to use (via metadata or just passing it)
	self.set_meta("scale_factor", S)
	
	# Load assets
	var floor_tile_scene = load(market_kit_path + "floor.fbx")
	var wall_scene = load(market_kit_path + "wall.fbx")
	var wall_window_scene = load(market_kit_path + "wall-window.fbx")
	var shelf_boxes_scene = load(market_kit_path + "shelf-boxes.fbx")
	var shelf_bags_scene = load(market_kit_path + "shelf-bags.fbx")
	var shelf_end_scene = load(market_kit_path + "shelf-end.fbx")
	var freezer_scene = load(market_kit_path + "freezer.fbx")
	var register_scene = load(market_kit_path + "cash-register.fbx")
	var basket_scene = load(market_kit_path + "shopping-basket.fbx")
	var cart_scene = load(market_kit_path + "shopping-cart.fbx")
	
	# 0. Safety Floor (Prevents falling through gaps)
	var safety_col_shape = BoxShape3D.new()
	safety_col_shape.size = Vector3(200, 1.0, 200)
	
	var safety_body = StaticBody3D.new()
	safety_body.name = "SafetyFloorBody"
	env_container.add_child(safety_body)
	safety_body.owner = self
	safety_body.position = Vector3(0, -0.5, 0)
	
	var col_node = CollisionShape3D.new()
	col_node.shape = safety_col_shape
	safety_body.add_child(col_node)
	col_node.owner = self
	
	# Make safety floor invisible or subtle (it's a fallback)
	# var safety_mesh = MeshInstance3D.new()
	# ... (Removed visible safety floor to avoid ugly gray box)
	
	# 1. GridMap Setup (Replaces individual floor/wall nodes)
	var tile_spacing = 1.0 * S
	var ceiling_height_tiles = 4 # 4 tiles high = ~12m ceiling (Super tall warehouse)
	
	# Create MeshLibrary from assets
	var mesh_lib = _create_mesh_library(floor_tile_scene, wall_scene, wall_window_scene)
	
	# Main GridMap (Floors, Walls) - Shadows ON
	var gridmap_main = GridMap.new()
	gridmap_main.name = "GridMap_Main"
	gridmap_main.mesh_library = mesh_lib
	gridmap_main.cell_size = Vector3(1, 1, 1) # Base mesh size
	gridmap_main.scale = Vector3(S, S, S) # Apply scale to the grid
	gridmap_main.collision_layer = 1
	gridmap_main.collision_mask = 1
	geometry_node.add_child(gridmap_main)
	gridmap_main.owner = self
	
	# Ceiling - Use a single MeshInstance for better performance and look
	var ceiling_node = Node3D.new()
	ceiling_node.name = "Ceiling"
	geometry_node.add_child(ceiling_node)
	ceiling_node.owner = self
	
	# Create single large ceiling plane
	var grid_radius = 10
	var ceiling_mesh = MeshInstance3D.new()
	ceiling_mesh.name = "CeilingPlane"
	var plane = PlaneMesh.new()
	# Size covers the whole grid plus some margin
	var total_size = (grid_radius * 2 + 6) * tile_spacing
	plane.size = Vector2(total_size, total_size)
	ceiling_mesh.mesh = plane
	ceiling_node.add_child(ceiling_mesh)
	ceiling_mesh.owner = self
	ceiling_mesh.position = Vector3(0, ceiling_height_tiles * tile_spacing, 0) # Ceiling height
	ceiling_mesh.rotation_degrees.x = 180 # Face down
	
	# Dark material for ceiling
	var c_mat = StandardMaterial3D.new()
	c_mat.albedo_color = Color(0.2, 0.2, 0.25) # Darker industrial color
	ceiling_mesh.material_override = c_mat
	ceiling_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# 2. Fill GridMap (Floors/Walls)
	print("Filling GridMap...")
	
	# Floors
	for x in range(-grid_radius, grid_radius + 1):
		for z in range(-grid_radius, grid_radius + 1):
			# Floor (Item 0)
			gridmap_main.set_cell_item(Vector3i(x, 0, z), 0, 0)
	
	# Walls (Stacked vertically)
	var wall_limit = grid_radius + 1 # Place walls outside the floor grid (at index 11)
	for i in range(-grid_radius, grid_radius + 1):
		for y in range(ceiling_height_tiles):
			# North Wall (z = -11) - Rot 0
			var item = 1 # Wall
			if (i % 3 == 0 and wall_window_scene and y == 0): item = 2 # Window only on bottom
			gridmap_main.set_cell_item(Vector3i(i, y, -wall_limit), item, 0)
			
			# South Wall (z = 11) - Rot 180 Y -> Index 10
			if abs(i) > 2 or y > 0: # Entrance gap only on bottom layer
				item = 1
				if (i % 3 == 0 and wall_window_scene and y == 0): item = 2
				gridmap_main.set_cell_item(Vector3i(i, y, wall_limit), item, 10)
				
			# East Wall (x = 11) - Rot -90 Y -> Index 16
			item = 1 # Use plain wall for sides
			gridmap_main.set_cell_item(Vector3i(wall_limit, y, i), item, 16)
			
			# West Wall (x = -11) - Rot 90 Y -> Index 22
			gridmap_main.set_cell_item(Vector3i(-wall_limit, y, i), item, 22)

	# 3. Add Market Aisles (More structured layout)
	if shelf_boxes_scene:
		print("Spawning shelves...")
		
		# Define Aisle Configuration
		# We want aisles where player walks, with shelves facing IN to the aisle.
		# Aisle 1: Between x=-6 and x=-2 (Center -4)
		# Aisle 2: Between x=2 and x=6 (Center 4)
		
		var shelf_rows = [
			{"x": - 6, "rot": - 90}, # Leftmost row, facing Right (East) -> Into Aisle 1
			{"x": - 2, "rot": 90}, # Left-mid row, facing Left (West) -> Into Aisle 1
			{"x": 2, "rot": - 90}, # Right-mid row, facing Right (East) -> Into Aisle 2
			{"x": 6, "rot": 90} # Rightmost row, facing Left (West) -> Into Aisle 2
		]
		
		for row_config in shelf_rows:
			var x_aisle = row_config["x"]
			var rot = row_config["rot"]
			
			for z in range(-6, 6): # Long aisles
				# Skip occasional spots for gaps/cross-aisles
				if z == 0: continue
				
				var shelf
				var shelf_name_prefix = "Shelf_Row_%d_%d" % [x_aisle, z]
				
				# End caps
				if z == -6:
					shelf = shelf_end_scene.instantiate() if shelf_end_scene else shelf_boxes_scene.instantiate()
					shelf.name = shelf_name_prefix + "_End_N"
					# End cap rotation logic is tricky, usually 0 or 180
					shelf.rotation_degrees.y = 0
				elif z == 5:
					shelf = shelf_end_scene.instantiate() if shelf_end_scene else shelf_boxes_scene.instantiate()
					shelf.name = shelf_name_prefix + "_End_S"
					shelf.rotation_degrees.y = 180
				else:
					# Standard shelf
					shelf = shelf_boxes_scene.instantiate() if (x_aisle + z) % 2 == 0 else shelf_bags_scene.instantiate()
					shelf.name = shelf_name_prefix + "_Mid"
					shelf.rotation_degrees.y = rot # Face the aisle
				
				shelves_node.add_child(shelf)
				shelf.owner = self
				shelf.scale = Vector3(S, S, S)
				
				# Tighter positioning
				shelf.position = Vector3(x_aisle * tile_spacing, 0, z * tile_spacing)
				_add_collision_recursive(shelf)

	# 4. Add Checkout Counters (Front)
	if register_scene:
		print("Spawning checkout...")
		for i in range(4):
			var reg = register_scene.instantiate()
			reg.name = "Register_%d" % i
			furniture_node.add_child(reg)
			reg.owner = self
			reg.scale = Vector3(S, S, S)
			# Tighter spacing for registers
			reg.position = Vector3(2.0 * tile_spacing - (i * 1.0 * tile_spacing), 0, 8 * tile_spacing) # Front area
			reg.rotation_degrees.y = 180
			_add_collision_recursive(reg)
	
	# 5. Add Freezers (Back Wall)
	if freezer_scene:
		print("Spawning freezers...")
		for i in range(8):
			var freezer = freezer_scene.instantiate()
			freezer.name = "Freezer_%d" % i
			furniture_node.add_child(freezer)
			freezer.owner = self
			freezer.scale = Vector3(S, S, S)
			# Tighter spacing: touching each other
			freezer.position = Vector3(-8 * tile_spacing + (i * 1.0 * tile_spacing), 0, -9 * tile_spacing)
			freezer.rotation_degrees.y = 0
			_add_collision_recursive(freezer)

	# 6. Add Scatter Props
	if cart_scene:
		print("Spawning carts...")
		for i in range(10):
			var cart = cart_scene.instantiate()
			cart.name = "Cart_%d" % i
			scatter_node.add_child(cart)
			cart.owner = self
			cart.scale = Vector3(S, S, S)
			var cx = randf_range(-8, 8) * tile_spacing
			var cz = randf_range(5, 9) * tile_spacing # Front area
			cart.position = Vector3(cx, 0, cz)
			cart.rotation_degrees.y = randf_range(0, 360)
			_add_collision_recursive(cart)

	if basket_scene:
		print("Spawning baskets...")
		for i in range(15):
			var basket = basket_scene.instantiate()
			basket.name = "Basket_%d" % i
			scatter_node.add_child(basket)
			basket.owner = self
			basket.scale = Vector3(S, S, S)
			var bx = randf_range(-9, 9) * tile_spacing
			var bz = randf_range(-9, 9) * tile_spacing
			basket.position = Vector3(bx, 0, bz)
			basket.rotation_degrees.y = randf_range(0, 360)
			_add_collision_recursive(basket)

	_spawn_zombies(entities_node, S)
	_spawn_npcs(entities_node, S)


func _process(delta):
	# Debug player position
	var p = get_node_or_null("Player")
	if p and p.global_position.y < -5:
		print("DEBUG: Player falling! Y=", p.global_position.y)
		# Emergency reset
		p.global_position = Vector3(0, 2, 0)
		p.velocity = Vector3.ZERO

func _add_collision_recursive(node):
	if node is MeshInstance3D:
		node.create_convex_collision()
		# Ensure the static body created is on the correct layer
		if node.get_child_count() > 0:
			var last_child = node.get_child(node.get_child_count() - 1)
			if last_child is StaticBody3D:
				last_child.collision_layer = 1
				last_child.collision_mask = 1
	
	for child in node.get_children():
		_add_collision_recursive(child)

func _disable_shadows_recursive(node):
	if node is GeometryInstance3D:
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	for child in node.get_children():
		_disable_shadows_recursive(child)

func _spawn_zombies(parent_node = self, scale_factor = 2.5):
	var zombie_scene = load("res://scenes/entities/Zombie.tscn")
	if not zombie_scene: return
	
	for i in range(5):
		var z = zombie_scene.instantiate()
		z.name = "Zombie_%d" % i
		parent_node.add_child(z)
		z.owner = self # Bake them too if requested
		# Spawn in aisles or open spaces, avoiding walls
		# Scale ranges by scale_factor to fill the map
		var zx = randf_range(-8, 8) * scale_factor
		var zz = randf_range(-8, 8) * scale_factor
		# Avoid center spawn (where player is)
		if abs(zx) < 2 * scale_factor and abs(zz) < 2 * scale_factor: zx += 4 * scale_factor
		
		z.position = Vector3(zx, 0.1, zz)
		# Signal connections happen in _ready now
		# z.zombie_died.connect(_on_zombie_cleared) 
		# z.player_path = NodePath("../Player")

func _spawn_npcs(parent_node = self, scale_factor = 2.5):
	var npc_scene = load("res://scenes/entities/NPC.tscn")
	if not npc_scene: return
	
	for i in range(2):
		var n = npc_scene.instantiate()
		n.name = "NPC_%d" % i
		parent_node.add_child(n)
		n.owner = self
		var nx = randf_range(-8, 8) * scale_factor
		var nz = randf_range(-8, 8) * scale_factor
		if abs(nx) < 2 * scale_factor and abs(nz) < 2 * scale_factor: nx -= 4 * scale_factor
		
		n.position = Vector3(nx, 0.1, nz)
		# Signal connections happen in _ready now
		# n.npc_helped.connect(_on_npc_helped)

func _on_zombie_cleared():
	zombies_cleared += 1
	if zombies_cleared >= 5:
		if obj2_checkbox: obj2_checkbox.button_pressed = true
		objectives_completed += 1
		if instruction_label: instruction_label.text = "Area clear! Now find and assist the NPCs (Green)."
		_check_completion()
	else:
		if instruction_label: instruction_label.text = "Zombie cleared! (" + str(zombies_cleared) + "/5)"

func _on_npc_helped():
	npcs_helped += 1
	if npcs_helped >= 2:
		if obj3_checkbox: obj3_checkbox.button_pressed = true
		objectives_completed += 1
		_check_completion()
	else:
		if instruction_label: instruction_label.text = "NPC assisted! (" + str(npcs_helped) + "/2)"

func _check_completion():
	if objectives_completed >= 3:
		if instruction_label: instruction_label.text = "All objectives complete! Head to the extraction point (or just click Finish)."
		if complete_floor_button:
			complete_floor_button.text = "Proceed to Results"
			complete_floor_button.disabled = false

func _start_tutorial():
	if instruction_label: instruction_label.text = "Welcome to the Mini Market! Use WASD to move, Shift to Sprint, Ctrl to Crouch."
	tutorial_step = 1
	if complete_floor_button: complete_floor_button.disabled = true

func _input(event):
	# Check for movement input to progress tutorial
	if tutorial_step == 1 and not movement_learned:
		if event is InputEventKey:
			var key_event = event as InputEventKey
			if key_event.pressed and key_event.keycode in [KEY_W, KEY_A, KEY_S, KEY_D]:
				_complete_movement_tutorial()

func _complete_movement_tutorial():
	if not movement_learned:
		movement_learned = true
		if obj1_checkbox: obj1_checkbox.button_pressed = true
		objectives_completed += 1
		if instruction_label: instruction_label.text = "Movement confirmed. Clean up the aisles! Interact (E) with 5 Red Zombies."
		tutorial_step = 2

func _on_complete_floor_pressed():
	print("Tutorial floor completed!")
	print("Objectives completed: ", objectives_completed, "/3")
	
	# Store results for the results screen
	GameData.last_floor_results = {
		"floor_number": 1,
		"floor_name": "Lobby & Utilities",
		"completion_time": 45.0, # Placeholder time
		"objectives_completed": objectives_completed,
		"total_objectives": 3,
		"detections": 0,
		"grade": "A"
	}
	
	_transition_to_results()

func _transition_to_results():
	var tween = create_tween()
	tween.tween_property($TutorialUI, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/ui/FloorResults.tscn"))

# --- Helper Functions for GridMap Generation ---

func _create_mesh_library(floor_scene, wall_scene, window_scene) -> MeshLibrary:
	var lib = MeshLibrary.new()
	
	# ID 0: Floor
	_add_mesh_to_lib(lib, 0, floor_scene)
	# ID 1: Wall
	_add_mesh_to_lib(lib, 1, wall_scene)
	# ID 2: Wall Window
	_add_mesh_to_lib(lib, 2, window_scene)
	
	return lib

func _add_mesh_to_lib(lib: MeshLibrary, id: int, scene: PackedScene):
	if not scene: return
	var instance = scene.instantiate()
	var mesh_instance = _find_mesh_instance(instance)
	if mesh_instance and mesh_instance.mesh:
		lib.create_item(id)
		lib.set_item_mesh(id, mesh_instance.mesh)
		# Collision
		var shape = mesh_instance.mesh.create_convex_shape()
		lib.set_item_shapes(id, [Transform3D.IDENTITY, shape])
	instance.free()

func _find_mesh_instance(node):
	if node is MeshInstance3D: return node
	for child in node.get_children():
		var res = _find_mesh_instance(child)
		if res: return res
	return null
