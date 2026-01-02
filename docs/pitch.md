# Shadow Ascent: The Silent Yards — Pitch

## Elevator Pitch (45 seconds)
Shadow Ascent is a tight, replayable stealth‑parkour game set in an abandoned industrial yard. As Kael, a nimble urban infiltrator, you read the geometry, time patrols and spotlights, and chain fluid moves—vaults, climbs, ledge‑hangs—to reach a sealed gantry. It’s about mastery of movement, smart route‑finding, and the thrill of staying unseen.

---

## 1) Idea
A vertical, floor-by-floor first-person action adventure set inside a sprawling high-rise. Each floor is a self-contained level with clear objectives: defeat infected zombies, assist NPCs with story-driven tasks, survive gunfights, and tackle optional mini-games (like timed races). Clear the floor to unlock the next one and push upward toward the top, where a coveted trophy awaits.

### Player Fantasy
Be the building’s unstoppable ascender—resourceful, fast, and brave—balancing combat, objectives, and route choices to climb ever higher.

---

## 2) Genre
- 3D first-person action-adventure with survival combat, questing, and mini-games.
- Level-based progression across floors of a single building; high replayability via alternate objective orders and routes.
- Mix of stealth and gunplay; optional racing/time-trial challenges woven into certain floors.

---

## 3) Core Challenge
- Multi-objective triage: choose the order to clear zombies, help NPCs, and engage gunfights under pressure.
- Combat variety: crowd control against zombies; cover-based shooting against armed foes.
- Vertical navigation: read floor layouts, stairwells, elevators, and shortcuts to keep momentum.
- Resource management: juggle ammo, tools, health; prepare for the next floor’s demands.
- Risk vs reward: optional mini-games and side tasks grant buffs or access, but cost time.
- Stealth choices: when to avoid heavy fights to conserve resources and hit objectives faster.

Difficulty escalates with denser hordes, stronger enemy squads, timed locks, environmental hazards, and more complex objective chains.

---

## 4) Design (Rough Sketches)

### UI/Flow (ASCII)
```
[Title] -> [Start]
            |
            v
   [Floor Briefing + Loadout]
            |
            v
[Floor N: Objectives (zombies, NPCs, gunfight, mini-game)]
            |
            v
[Stairwell/Elevator Unlocked] -> [Results: time, objectives, detections]
            |
            v
   [Continue to Next Floor / Retry]
```

### Level Topology (ASCII)
```
Lobby -> Utilities -> Residential -> Security Hub -> Atrium Raceway
   -> Executive Offices -> Penthouse (Trophy)
```
- Lobby/Utilities: basic zombies, first NPC tasks, learn loop flow.
- Residential: tight corridors, multi-room objectives, stealth detours.
- Security Hub: armed squads, camera zones, locked doors.
- Atrium Raceway: timed racing mini-game with vertical shortcuts.
- Executive Offices: layered objectives under higher enemy density.
- Penthouse: final floor with climactic encounters and the trophy.

### Visual Cues
- Clear objective markers, signage, and elevator/stair indicators.
- Hazard lights for lockdown areas, camera cones, and infection zones.
- Mini-game start/finish gates and route banners for races.

---

## Locomotion (Constraint‑Based)
- Vault: forward speed + obstacle height/width within ranges.
- Climb: reachable ledges or ladders within hand distance + facing angle.
- Ledge‑Hang: valid edge above chest height and clear top surface.
- Mantle: rise from hang to stand when space above is open.
- Optional: crouch‑walk (lower profile), sprint (flow maintenance).

Each action validates distances, normals, and velocity; failure is readable (too far, wrong angle).

---

## Stealth System (Simple & Readable)
- Line‑of‑sight cones from spotlights and patrol guards.
- Detection meter: fills in light, drains in shadow/cover.
- States: calm → suspicious → alarm (opens gates, activates extra lights).
- Tools: crouch to lower profile, use height advantage, break sight with geometry.

---

## Core Loop
Observe → Plan route → Execute chain → Avoid detection → Finish → Retry for better time and fewer detections; collect seals on advanced lines.

---

## Controls (Keyboard)
- Move: `WASD`
- Camera: `Mouse`
- Jump: `Space`
- Sprint: `Shift`
- Crouch: `Ctrl`
- Interact / Vault / Climb / Hang: `E` (context‑aware)

---

## Story Beat
Atlas Tower was built as a showcase—a vertical campus and competitive venue where the Ascension Trophy crowns the fastest, smartest climber. On event night, a biosecurity breach floods lower floors with infected crews while mercenary squads seize upper levels. Kael chooses to keep climbing: helping trapped workers, outmaneuvering hostile factions, and clearing each floor to reach the penthouse—securing the trophy and restoring order in the process.

---

## Content Scope
- One handcrafted industrial yard with multiple viable routes.
- Scoring: completion time, detection count, and seals collected.
- Replay hooks: speedrun medals, stealth grades, route tags (safe vs. fast).

---

## Feature Pillars
- Readable movement: environment clearly tells you what’s possible.
- Smooth chaining: mechanics built to flow from one action to the next.
- Stealth clarity: sightlines and cones are predictable, fair, and learnable.
- High replayability: compact level with many lines and optimizations.

---

## Presentation Outline
- Hook: stealth‑parkour fantasy in industrial rooftops and conveyors.
- Genre & Pillars: traversal, stealth, readability, replayability.
- Core Challenge: geometry reading + timing.
- Design: UI flow and topology sketches.
- Systems: locomotion constraints + stealth cones.
- Content Scope: scoring, collectibles, routes.