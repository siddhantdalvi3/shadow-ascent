# Shadow Ascent — In‑Depth Implementation Guide

A step‑by‑step plan to build a replayable stealth‑parkour prototype in Godot 4 using Kenney industrial assets. Each milestone includes goals, exact editor actions, files to create/edit, and practical tips.

## Guiding Principles
- Favor readable, constraint‑based traversal over complex animation systems.
- Keep the yard readable: strong silhouettes, clear affordances, consistent metrics.
- Prioritize stealth fairness: predictable cones, generous shadows, clear feedback.
- Build iteratively: playable every 1–2 milestones; polish after core pillars are proven.

## Metrics & Conventions
- Scale baseline: 1 Godot unit ≈ 1 meter.
- Player capsule: radius `0.4`, height `1.8` (crouch height `1.2`).
- Vaultable obstacle height: ≤ `1.0` m.
- Ledge hang height: chest level ≈ `1.3`–`1.5` m from feet.
- Camera distance: `4.5`–`6.0` m; height: `1.8`–`2.2` m; pitch: `-35°` to `+10°`.

---

## Milestone 0 — Project Setup
**Goal:** Ensure clean imports and consistent metrics.

- In `project.godot`:
  - Set `display/window/size/viewport_width` and `viewport_height` (e.g., `1280×720`).
  - Set `physics/common/physics_ticks_per_second` to `60`.
  - Confirm `run/main_scene` will later point to `scenes/Main.tscn`.
- Import Kenney assets:
  - Use Godot’s Import dock; ensure scale = `1.0`; generate collision if needed.
  - Create `assets/kits/...` structure already present.
- Create directories:
  - `scenes/`, `scripts/`, `assets/player/` (already present), `ui/`.

---

## Milestone 1 — InputMap & Main Scene
**Goal:** Wire actions and scaffold the main playable scene.

- Actions (Project → Project Settings → Input Map):
  - `move_forward` = `W`, `Up`; `move_back` = `S`, `Down`.
  - `move_left` = `A`, `Left`; `move_right` = `D`, `Right`.
  - `jump` = `Space`; `sprint` = `Shift`; `crouch` = `Ctrl`.
  - `interact` = `E`; `pause` = `Esc`.
  - Mouse: `look_x` and `look_y` (use `Mouse Motion` in code, no map needed).
- Create `scenes/Main.tscn`:
  - Root `Node3D` (`Main`).
  - `DirectionalLight3D` with soft shadows.
  - `WorldEnvironment` with tone mapping and mild fog.
  - `StaticBody3D` ground: large `BoxMesh` (e.g., `50×1×50`), `CollisionShape3D`.
  - Instance `assets/player/player.tscn`.
  - `Camera3D` as child of `Main` or separate rig; attach `scripts/camera_follow.gd`.
  - `CanvasLayer` for HUD (empty for now).
- Set Main scene as default: Project → Project Settings → `run/main_scene` → `scenes/Main.tscn`.

---

## Milestone 2 — Third‑Person Camera
**Goal:** Orbiting follow camera aligned with player, with collision avoidance.

- Use existing `scripts/camera_follow.gd` and expose:
  - `target_path` (drag Player node), `distance`, `height`, `mouse_sensitivity`, `pitch_min`, `pitch_max`.
- In `Main.tscn`:
  - Ensure camera script references the Player’s `global_transform.origin`.
  - Add simple collision avoidance by raycasting from target to desired cam pos; if hit, push camera closer.
- Tips:
  - Read input in `_unhandled_input(event)`; do orbit on mouse move only when RMB held (optional).
  - Smooth camera with `lerp` for position and `slerp` for rotation.

---

## Milestone 3 — Player Movement Foundation
**Goal:** Camera‑relative locomotion with acceleration, sprint, crouch, jump.

- Edit `assets/player/player.gd`:
  - Replace basic movement with camera‑relative direction and acceleration.
  - Add states: `grounded`, `airborne`, `crouching`, `sprinting`.
  - Implement coyote time (`~0.12s`) and jump buffer (`~0.12s`).

Example movement core (conceptual):
```gdscript
func _physics_process(delta):
    var cam := get_viewport().get_camera_3d()
    var input_vec := Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
    )
    var dir := Vector3.ZERO
    if input_vec.length() > 0.0:
        input_vec = input_vec.normalized()
        var cam_forward := -cam.global_transform.basis.z
        var cam_right := cam.global_transform.basis.x
        cam_forward.y = 0; cam_right.y = 0
        cam_forward = cam_forward.normalized(); cam_right = cam_right.normalized()
        dir = (cam_forward * input_vec.y + cam_right * input_vec.x).normalized()

    var target_speed := sprinting ? SPRINT_SPEED : (crouching ? CROUCH_SPEED : WALK_SPEED)
    var accel := is_on_floor() ? ACCEL_GROUND : ACCEL_AIR
    var horizontal := velocity
    horizontal.y = 0
    horizontal = horizontal.move_toward(dir * target_speed, accel * delta)
    velocity.x = horizontal.x
    velocity.z = horizontal.z

    if !is_on_floor():
        velocity.y -= GRAVITY * delta

    if jump_buffered and (is_on_floor() or coyote_timer > 0.0):
        velocity.y = JUMP_VELOCITY
        jump_buffered = false

    move_and_slide()
```

- Crouch: reduce capsule height via `CollisionShape3D.shape.height`; slow speed.
- Sprint: increase `target_speed`; optionally add stamina drain/regeneration later.

---

## Milestone 4 — Traversal Constraints (Vault, Ledge Hang, Mantle)
**Goal:** Add simple but robust traversal affordances.

- Vault:
  - Add a forward `ShapeCast3D` at knee height to detect low obstacles.
  - If obstacle top ≤ `VAULT_MAX_HEIGHT`, play a short motion arc:
    - Option A: physics impulse over the obstacle.
    - Option B: tween position across with grounded disable.
  - Lock player input during vault; preserve momentum on exit.
- Ledge Hang:
  - Use two casts: forward at chest to find wall, downwards at slight offset to find ledge top.
  - On detection, snap hands to ledge, set `state = HANG`; gravity off; allow shimmy left/right.
  - Climb Up: check `test_move` with raised capsule; if clear, translate up and forward to stand.
- Mantle:
  - For slightly higher obstacles than a vault, check vertical clearance and mantle with a slower climb.

Implementation sketch:
```gdscript
func try_vault():
    if vault_cast.is_colliding():
        var hit := vault_cast.get_collider()
        if hit_top_height <= VAULT_MAX_HEIGHT:
            start_vault()

func try_ledge():
    if wall_cast.is_colliding() and ledge_cast.is_colliding():
        enter_hang()
```

---

## Milestone 5 — Stealth Visibility & HUD
**Goal:** Basic visibility model with player feedback.

- Visibility model:
  - Tag bright areas using `OmniLight3D/SpotLight3D` with known groups (e.g., `light_sources`).
  - Sample light exposure via ray from player head toward dominant lights; or approximate with distance to nearest spotlight and whether a wall blocks line‑of‑sight.
  - Crouch reduces silhouette: multiply exposure by `0.7` when crouching.
- Suspicion meter:
  - `CanvasLayer` → `Control` → `ProgressBar` for suspicion (0–100).
  - Increase suspicion when inside a guard’s cone and exposure high; decay otherwise.
- UI feedback:
  - Screen edge flash or red vignette when detected.
  - Subtle prompt labels: `Vault`, `Climb`, `Hang` when casts valid.

---

## Milestone 6 — Guard AI (Patrol, Investigate, Chase)
**Goal:** One guard with believable patrol and detection.

- Scene `scenes/Guard.tscn`:
  - Root `CharacterBody3D` with `scripts/guard.gd`.
  - Children: `RayCast3D` for LOS, `Area3D`/mesh to visualize cone, `NavigationAgent3D`.
- Patrol:
  - Place `Path3D` or simple waypoint nodes; guard cycles through points.
  - Use `NavigationAgent3D` to move with `set_target_position()`; handle arrival tolerance.
- Vision cone:
  - Compute angle via dot product between guard forward and (player_pos − guard_pos).
  - If within `FOV` (e.g., 70°) and LOS ray hits player, raise suspicion.
- States:
  - `PATROL` → `INVESTIGATE` (upon noise or partial sight) → `CHASE` (confirmed sight) → `RETURN`.
- Hearing:
  - Emit events from player: footstep volume increases with speed and land impact.
  - Guard moves to event position if close and not in chase.

Detection logic sketch:
```gdscript
func can_see_player(player_pos) -> bool:
    var to_player := (player_pos - global_transform.origin)
    var dist := to_player.length()
    var angle := rad2deg(acos(to_player.normalized().dot(-global_transform.basis.z)))
    if angle > FOV * 0.5 or dist > VIEW_RANGE:
        return false
    los_cast.target_position = player_pos
    los_cast.force_raycast_update()
    return los_cast.is_colliding() and los_cast.get_collider() == player
```

---

## Milestone 7 — Goal, Flow, and End Screen
**Goal:** A complete loop with a win condition and summary.

- Place a visible goal: `gantry` with `Area3D` trigger.
- On enter, stop timers and show end screen with:
  - Time, detections, alerts, route grade (S/A/B/C).
  - Options: `Restart`, `Quit`.
- Persist best scores via `ConfigFile` in `user://scores.cfg`.

---

## Milestone 8 — Environment Pass & Polish
**Goal:** Make the yard readable and fun; add stealth routes and affordances.

- Blockout pass:
  - Use Kenney crates, catwalks, pipes, and factory props; maintain 1m grid.
  - Provide multiple routes: shadowed path, high‑risk fast path, puzzle route.
- Lights & shadows:
  - Position spotlights to create patrol hotspots; ensure escape pockets and cover.
- Traversal affordances:
  - Add rails and ledges at consistent heights; color cue edges slightly.
- SFX/VFX:
  - Footsteps (`AudioStreamPlayer3D`), spotlight motor loop, detection sting.

---

## Milestone 9 — Performance & QA
**Goal:** Stable 60 FPS with fair mechanics.

- Performance:
  - Convert static props to `StaticBody3D`; merge meshes where viable.
  - Limit shadow ranges; reduce light counts; enable occlusion culling.
- QA battery:
  - Ledge consistency across different orientations and scales.
  - Vault height fairness and recovery from failed vault.
  - Camera collision against walls; no jitter; no clipping.
  - Guard detection fairness; eliminate false positives through walls.

---

## Milestone 10 — Export & Wrap‑Up
**Goal:** Ship‑ready prototype.

- Exports:
  - Create presets for macOS/Windows/Linux; test in builds.
- Title splash and README:
  - Simple splash, controls page, credits.
- Versioning:
  - Semantic version (e.g., `v0.1.0`), changelog entries.

---

## File Index (Planned)
- `scenes/Main.tscn` — world root, lighting, UI, player, camera.
- `assets/player/player.tscn` — player scene (capsule, mesh, collision).
- `assets/player/player.gd` — movement, constraints, stealth hooks.
- `scripts/camera_follow.gd` — orbiting third‑person camera.
- `scenes/Guard.tscn` — guard with patrol, LOS.
- `scripts/guard.gd` — state machine, patrol/detect/chase.
- `ui/HUD.tscn` — suspicion bar, prompts.
- `ui/EndScreen.tscn` — results and actions.

---

## Immediate Implementation Checklist
1. Create `scenes/Main.tscn`, set as main scene, add light/ground.
2. Wire `scripts/camera_follow.gd` to `Camera3D` and target Player.
3. Upgrade `assets/player/player.gd` with camera‑relative move, sprint, crouch, jump buffer.
4. Add casts for vault and ledge; implement hang and climb.
5. Create `ui/HUD.tscn` with suspicion bar and prompts; hook player/guard signals.
6. Build `scenes/Guard.tscn` with patrol waypoints and LOS detection.
7. Place goal trigger; implement end screen with results and restart.
8. Iterate on blockout to ensure multiple stealth routes; tune lights.
9. Run QA battery and performance pass; fix fairness issues.
10. Add exports and README; tag `v0.1.0`.

---

## Tips & Pitfalls
- Use `ShapeCast3D` over many `RayCast3D` for robust ledge detection.
- Keep movement logic in `_physics_process`; only read inputs in `_input`/`_unhandled_input`.
- Avoid per‑frame allocations; reuse vectors and timers; pool tweens.
- For fairness, prioritize predictable cones and LOS; let shadows be generous.
- When in doubt, simplify: fewer animations, clearer geometry, tighter feedback.