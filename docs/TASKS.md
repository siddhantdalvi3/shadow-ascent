# Shadow Ascent — Actionable Task List

A compact, execution‑ready checklist that mirrors requirements and implementation steps. Use this to track progress and open issues.

## 0) Project Setup
- [ ] Configure project settings (`display`, `physics`, `run/main_scene`).
- [ ] Verify Kenney asset imports (scale=1.0, collisions as needed).
- [ ] Maintain directory structure: `scenes/`, `scripts/`, `assets/`, `ui/`.

## 1) Input & Controls
- [ ] Create InputMap actions: `move_forward/back/left/right`, `jump`, `sprint`, `crouch`, `interact`, `pause`.
- [ ] Hook runtime bootstrap (`scripts/bootstrap_input.gd`).
- [ ] Mouse look via `_input` on camera; ensure cursor capture/release.

## 2) Main Scene
- [ ] Scaffold `scenes/Main.tscn` with: root `Node3D`, `DirectionalLight3D`, `WorldEnvironment` (fog), ground (`StaticBody3D`).
- [ ] Instance `scenes/Player.tscn` and `Camera3D` (`scripts/camera_follow.gd`).
- [ ] Set `run/main_scene` to `scenes/Main.tscn`.

## 3) Camera System
- [ ] Orbit follow around Player; tune `distance`, `height`, pitch limits.
- [ ] Add soft collision avoidance (raycast and push‑in) — v2.
- [ ] Smooth position/rotation with lerp/slerp.

## 4) Player Controller
- [ ] Camera‑relative movement (forward/right from camera basis).
- [ ] Acceleration/deceleration (ground/air values).
- [ ] Sprint (speed boost), crouch (lower capsule and slower).
- [ ] Jump buffering and coyote time.
- [ ] Character faces movement direction subtly.

## 5) Traversal Constraints
- [ ] Vault low obstacles (ShapeCast3D forward at knee height; threshold ≤ 1.0m).
- [ ] Ledge hang detection (wall cast + ledge cast); snap hands; shimmy.
- [ ] Climb up from hang when clearance allows (use `test_move`).
- [ ] Optional mantle for slightly higher obstacles.

## 6) Stealth Visibility & HUD
- [ ] Implement simple exposure model (lit vs shadowed; LOS to spotlight).
- [ ] Suspicion meter UI (`ui/HUD.tscn`: ProgressBar + subtle feedback).
- [ ] Hook guard detection to raise/decay suspicion; add detection sting.
- [ ] Prompt labels for `Vault`, `Climb`, `Hang`, `Interact`.

## 7) Guard AI
- [ ] Create `scenes/Guard.tscn` (capsule mesh + CollisionShape).
- [ ] Waypoint patrol system (cycle WP1→WP2→...).
- [ ] FOV cone check + LOS raycast; configurable `fov_deg`, `view_range`.
- [ ] States: patrol → investigate (on noise/partial sight) → chase → return.
- [ ] Hearing events from player (footsteps, landing) with distance gating.

## 8) Environment Pass
- [ ] Blockout routes with Kenney crates, catwalks, pipes at 1m grid.
- [ ] Place spotlights to shape stealth pockets and risk zones.
- [ ] Place traversal affordances with consistent metrics (rails/ledges).
- [ ] Tag props and lights via groups for logic hooks.

## 9) Goal & End Screen
- [ ] Visible final gantry with `Area3D` trigger.
- [ ] End screen `ui/EndScreen.tscn`: time, detections, grade (S/A/B/C).
- [ ] Persist best scores to `user://scores.cfg`.

## 10) Audio & VFX
- [ ] Footsteps (basic), jump/land cues.
- [ ] Spotlight motor loop; detection sting; chase cue.
- [ ] Simple fog/lighting tuning; optional dust motes.

## 11) Data & Scoring
- [ ] Track run time, detections, alerts, route efficiency.
- [ ] Grade runs and show restart option.

## 12) Performance & QA
- [ ] Convert static props to `StaticBody3D`; merge meshes where viable.
- [ ] Tune lights/shadows ranges; enable occlusion culling.
- [ ] QA: ledge alignment, vault fairness, camera collision stability, guard detection fairness.

## 13) Export & Docs
- [ ] Export presets for macOS/Windows/Linux; test.
- [ ] README with controls and setup; credits.
- [ ] Version/tag (`v0.1.0`), changelog.

---

## MVP (First Playable) Subset
- [ ] Main scene with ground, light, fog, camera.
- [ ] Player: camera‑relative move, sprint, crouch, jump buffer.
- [ ] Vault + ledge hang/climb (basic).
- [ ] One guard with patrol + LOS detection.
- [ ] Suspicion bar and detection feedback.
- [ ] Gantry goal and end screen with time/detections.

---

## Current Status Snapshot
- [x] Player scene/script relocated: `scenes/Player.tscn`, `scripts/player.gd`.
- [x] Main scene scaffolded; camera wired; input bootstrap added.
- [x] Player controller upgraded (camera‑relative, sprint/crouch, jump buffer).
- [x] Guard scene + LOS patrol scaffolded; instanced in Main.
- [ ] HUD and suspicion system pending.
- [ ] Vault/ledge/mantle constraints pending.
- [ ] Environment blockout and spotlights pending.
- [ ] Goal/end screen pending.