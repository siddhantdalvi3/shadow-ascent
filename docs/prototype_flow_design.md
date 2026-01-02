# Shadow Ascent - Prototype Flow Design

## Complete Game Flow Architecture

```
[Welcome Screen] 
    ↓
[Main Menu] 
    ↓ (Start Game)
[Floor Briefing + Loadout]
    ↓
[Tutorial Floor - Lobby/Utilities]
    ↓
[Floor Results Screen]
    ↓ (Continue)
[Floor Briefing + Loadout] (Floor 2)
    ↓
[Residential Floor]
    ↓
[Floor Results Screen]
    ↓ (Continue)
[Floor Briefing + Loadout] (Floor 3)
    ↓
[Security Hub Floor]
    ↓
[Floor Results Screen]
    ↓ (Continue)
[Floor Briefing + Loadout] (Floor 4)
    ↓
[Atrium Raceway Floor]
    ↓
[Floor Results Screen]
    ↓ (Continue)
[Floor Briefing + Loadout] (Floor 5)
    ↓
[Executive Offices Floor]
    ↓
[Floor Results Screen]
    ↓ (Continue)
[Final Briefing]
    ↓
[Penthouse Floor - Final Boss]
    ↓
[Victory/Ending Screen]
    ↓
[Credits] → [Main Menu]
```

## Scene Breakdown & Wireframe Requirements

### 1. Welcome Screen
**Purpose**: Atmospheric introduction, set tone
**Elements**:
- Game title "Shadow Ascent"
- Subtitle "Atlas Tower Challenge"
- Background: Dark tower silhouette
- "Press any key to continue" prompt
- Ambient sound/music

**Wireframe Needs**:
- Full-screen background
- Centered title text
- Fade-in animation
- Input detection

### 2. Main Menu
**Purpose**: Primary navigation hub
**Elements**:
- Game logo
- Menu options: Start Game, Options, Credits, Exit
- Background: Tower exterior view
- UI: Clean, industrial theme

**Wireframe Needs**:
- Vertical button layout
- Hover/selection states
- Background parallax (optional)
- Sound toggle

### 3. Floor Briefing + Loadout
**Purpose**: Mission preparation and context
**Elements**:
- Floor name and number
- Objective list (zombies, NPCs, gunfights, mini-games)
- Loadout selection (weapons, tools, health items)
- Floor map preview
- "Begin Floor" button

**Wireframe Needs**:
- Split layout: briefing left, loadout right
- Objective checklist UI
- Equipment selection grid
- Floor diagram/minimap

### 4. Tutorial Floor (Lobby/Utilities)
**Purpose**: Teach core mechanics
**Elements**:
- Basic movement tutorial
- Combat introduction (zombie encounters)
- NPC interaction demo
- Objective completion flow
- UI tutorials (health, ammo, objectives)

**Wireframe Needs**:
- 3D environment with clear tutorial zones
- Overlay UI for instructions
- Progress indicators
- Interactive tutorial elements

### 5. Game Floors (Residential, Security Hub, etc.)
**Purpose**: Core gameplay experience
**Elements**:
- Floor-specific environment
- Zombie encounters
- NPC quest givers
- Gunfight scenarios
- Mini-game triggers (racing in Atrium)
- Objective markers
- Exit unlock mechanism

**Wireframe Needs**:
- 3D level geometry
- Enemy spawn points
- NPC placement
- Interactive object markers
- UI overlays (health, ammo, objectives)
- Mini-map

### 6. Floor Results Screen
**Purpose**: Performance feedback and progression
**Elements**:
- Completion time
- Objectives completed
- Detection count
- Performance grade (S, A, B, C)
- Rewards earned
- "Continue" or "Retry Floor" options

**Wireframe Needs**:
- Results table/grid
- Performance metrics visualization
- Grade display
- Button navigation

### 7. Penthouse Floor (Final)
**Purpose**: Climactic finale
**Elements**:
- Final boss encounter or challenge
- Trophy acquisition sequence
- Victory celebration
- Transition to ending

**Wireframe Needs**:
- Dramatic environment
- Trophy placement
- Victory animation triggers
- Cinematic camera angles

### 8. Victory/Ending Screen
**Purpose**: Game completion celebration
**Elements**:
- Victory message
- Final statistics
- Trophy display
- Story conclusion text
- "Play Again" or "Main Menu" options

**Wireframe Needs**:
- Trophy showcase
- Statistics summary
- Celebration effects
- Navigation buttons

## Prototyping Implementation Strategy

### Phase 1: Static Wireframes (Week 1)
1. Create basic UI scenes in Godot
2. Use ColorRect nodes for layout blocks
3. Add Label nodes for text content
4. Implement basic button navigation

### Phase 2: Interactive Flow (Week 2)
1. Add scene transition logic
2. Implement button functionality
3. Create basic state management
4. Add placeholder animations

### Phase 3: Content Integration (Week 3)
1. Replace placeholders with actual content
2. Add basic 3D environments
3. Implement core mechanics
4. Polish UI and transitions

## Technical Requirements

### Godot Scenes Needed:
- `WelcomeScreen.tscn`
- `MainMenu.tscn`
- `FloorBriefing.tscn`
- `TutorialFloor.tscn`
- `ResidentialFloor.tscn`
- `SecurityHubFloor.tscn`
- `AtriumRacewayFloor.tscn`
- `ExecutiveOfficesFloor.tscn`
- `PenthouseFloor.tscn`
- `FloorResults.tscn`
- `VictoryScreen.tscn`

### Scripts Needed:
- `GameManager.gd` (scene transitions, state management)
- `UIManager.gd` (UI interactions, animations)
- `FloorManager.gd` (floor-specific logic)
- `PlayerProgress.gd` (save/load progress)

### Assets Needed:
- UI theme (fonts, colors, button styles)
- Background images/textures
- Sound effects and music
- 3D models (basic geometric shapes for prototyping)

## Next Steps

1. **Choose your prototyping approach** (Godot wireframes recommended)
2. **Start with Welcome Screen and Main Menu** (quickest wins)
3. **Create one complete floor cycle** (Briefing → Floor → Results)
4. **Test navigation flow** before adding content
5. **Iterate based on playtesting feedback**

Would you like me to start implementing any of these scenes in Godot?