# Shadow Ascent — Production Requirements Checklist

A concise, actionable checklist to guide development of a production‑style, replayable stealth‑parkour game in Godot 4, using Kenney industrial assets.

## Core Vision
- [ ] Define genre: 3D third‑person stealth traversal with constraint‑based parkour
- [ ] Establish player fantasy: nimble infiltrator mastering movement and stealth
- [ ] Lock art direction: Kenney low‑poly industrial yard, moody lighting
- [ ] Confirm camera angle: shoulder/behind‑back, free orbit, soft collision avoidance

## Narrative & Setting
- [ ] Finalize short premise: Kael infiltrates abandoned yards to reach sealed gantry
- [ ] Define mission goals: reach gantry, avoid detection, optional collectibles
- [ ] Identify environmental storytelling elements: signage, crates, spotlights, sirens

## Input & Controls (Godot InputMap)
- [ ] Map `move_forward/back/left/right`
- [ ] Map `jump`, `sprint`, `crouch/toggle`, `interact`
- [ ] Map camera `look_x`, `look_y` (mouse), optional `reset_camera`
- [ ] Add `pause` and `menu` actions

## Player Controller
- [ ] Camera‑relative movement with acceleration and deceleration
- [ ] Sprint modifier (stamina optional)
- [ ] Crouch stance (smaller capsule, slower move, lower profile)
- [ ] Jump with coyote time and buffered input
- [ ] Vault low obstacles (height threshold)
- [ ] Ledge detection: hang, climb up if space is clear
- [ ] Mantle up to slightly higher platforms (within threshold)
- [ ] Grounding checks, step handling, slide on steep slopes

## Camera System
- [ ] Third‑person follow camera with orbit (mouse drag)
- [ ] Collision and wall‑push‑in (soft avoid geometry)
- [ ] Adjustable distance and height; pitch limits
- [ ] Optional target lock (future)

## Environment & Level Topology
- [ ] Blockout yard with platforms, gaps, catwalks, stacked crates
- [ ] Place spotlights and shadowed paths to enable stealth routing
- [ ] Add traversal affordances: rails, ledges, pipes, vaultable obstacles
- [ ] Mark navigation nodes/areas (for guard patrols)
- [ ] Optimize using low‑poly Kenney assets, consistent scale/metrics

## Stealth System
- [ ] Player visibility model: lit vs. shadow; crouch reduces silhouette
- [ ] Guard vision cones with distance falloff and peripheral leniency
- [ ] Suspicion meter: calm → curious → alerted
- [ ] Detection feedback: UI edge highlight, sound cue, spotlight flash
- [ ] Hide spots: crates stacks, under catwalks, behind pillars

## Guards & Moving Elements
- [ ] Basic guard scene: `CharacterBody3D` with patrol path
- [ ] State machine: patrol, investigate, chase, return
- [ ] Hearing events: footstep volume, landing thumps
- [ ] Spotlights (rotating), cameras (optional later)
- [ ] Navmesh setup for AI pathing

## Level Structure & Progression
- [ ] Clear start area with tutorial prompts
- [ ] Mid‑route with multiple stealth/movement solutions
- [ ] Final approach to sealed gantry (visible goal landmark)
- [ ] Optional collectibles or timed challenges for replay value

## UX & UI
- [ ] Minimal HUD: stamina (optional), detection/suspicion meter
- [ ] Subtle crosshair or center reticle for interaction
- [ ] Context prompts: “Vault”, “Climb”, “Hang”, “Interact”
- [ ] Pause menu and restart
- [ ] End screen: time, detections, route grade

## Audio & VFX
- [ ] Footsteps (surface‑aware if feasible)
- [ ] Jump/land and vault/ledge climb cues
- [ ] Ambient yard hums, spotlight motor loops
- [ ] Detection sting; chase music cue
- [ ] Simple shadow/lighting FX; optional dust motes near spotlights

## Data & Scoring
- [ ] Track run time, detections, alerts, route efficiency
- [ ] Grade performance (S/A/B/C) and expose restart
- [ ] Persist best scores locally (file or `ConfigFile`)

## Technical Setup
- [ ] Godot 4 project settings: physics delta, input, window
- [ ] Scene structure: `Main.tscn` → player, camera, environment, lights, UI
- [ ] Scripts structure: `scripts/` for camera, guards, utilities
- [ ] Asset import settings tuned (scale, collision where needed)

## Performance & Stability
- [ ] Use occlusion culling and LOD where helpful
- [ ] Limit overdraw with fog and lighting ranges
- [ ] Profile physics and AI; avoid per‑frame allocations
- [ ] Stable 60 FPS target on typical laptop GPU

## Build & Release
- [ ] Export presets for macOS/Windows/Linux
- [ ] Versioning and changelog
- [ ] Basic splash and title assets

## Testing & QA
- [ ] Smoke test traversal paths and stealth routes
- [ ] Edge cases: ledge alignment, vault height thresholds, camera collision
- [ ] Detection fairness and player feedback clarity
- [ ] Replayability: multiple solutions viable and learnable

## Documentation
- [ ] `README.md` with setup and controls
- [ ] `pitch.md` (done) and high‑level `requirements.md` (this file)
- [ ] Short dev notes for constraints and metrics

---

## MVP Cut (First Playable)
- [ ] `Main.tscn` with ground, simple blockout, lights
- [ ] Player controller: camera‑relative move, jump, sprint, crouch
- [ ] Basic vault over low obstacles
- [ ] Simple ledge hang and climb
- [ ] Follow camera with orbit and collision avoidance
- [ ] One guard with patrol path and vision cone detection
- [ ] Suspicion bar and detection feedback
- [ ] End goal: reach gantry; end screen with time/detections

## Nice‑to‑Have Enhancements
- [ ] Stamina system and exhaustion feedback
- [ ] Surface‑aware footstep audio and landing dust FX
- [ ] Target lock or line‑assist for jumps
- [ ] Multiple guard archetypes; cameras and rotating spotlights
- [ ] Leaderboard and ghost runs
- [ ] Photo mode and replays

## Immediate Next Steps
- [ ] Scaffold `Main.tscn` and wire `InputMap`
- [ ] Upgrade `player.gd` with sprint, crouch, vault, ledge hang
- [ ] Add `Guard.tscn` with patrol and detection cone