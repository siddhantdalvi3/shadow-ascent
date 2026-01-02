# Shadow Ascent Prototype Test Guide

## Overview
This guide outlines how to test the complete prototype flow for Shadow Ascent, from the welcome screen through to the ending.

## Scene Flow Architecture

### 1. Welcome Screen (`WelcomeScreen.tscn`)
- **Purpose**: Game introduction and initial user engagement
- **Navigation**: Press any key → Main Menu
- **Test**: Verify fade-in animation and input detection

### 2. Main Menu (`MainMenu.tscn`)
- **Purpose**: Primary navigation hub
- **Navigation Options**:
  - Start Game → Floor Briefing
  - Options → (Placeholder)
  - Credits → (Placeholder)
  - Exit Game → Quit application
- **Test**: Verify all buttons work and fade transitions

### 3. Floor Briefing (`FloorBriefing.tscn`)
- **Purpose**: Mission preparation and loadout selection
- **Features**:
  - Floor information display
  - Weapon selection (Stealth Knife, Silenced Pistol, Smoke Grenades)
  - Tool selection (Lockpicks, Hacking Device, Grappling Hook)
- **Navigation**: BEGIN FLOOR → Tutorial Floor (Floor 1) or Game Floor (Floor 2+)
- **Test**: Verify loadout selection and proper scene routing

### 4. Tutorial Floor (`TutorialFloor.tscn`)
- **Purpose**: Teach basic game mechanics
- **Features**:
  - Movement tutorial (WASD keys)
  - Objective tracking
  - Auto-completion for demonstration
- **Navigation**: Complete Tutorial → Floor Results
- **Test**: Verify objective completion and progression

### 5. Game Floor (`GameFloor.tscn`)
- **Purpose**: Main gameplay experience
- **Features**:
  - 3D environment with basic geometry
  - Objective tracking system
  - Timer and detection counter
  - Simulated gameplay progression
- **Controls**:
  - Keys 1, 2, 3: Complete objectives manually
  - Key D: Simulate detection
  - Pause button: Pause/resume game
- **Navigation**: Complete Floor → Floor Results
- **Test**: Verify objective system and performance tracking

### 6. Floor Results (`FloorResults.tscn`)
- **Purpose**: Performance evaluation and progression
- **Features**:
  - Completion time display
  - Objectives completed ratio
  - Detection count
  - Performance grade (S, A, B, C, F)
  - Rewards system
- **Navigation Options**:
  - Retry Floor → Floor Briefing
  - Continue to Next Floor → Floor Briefing (next floor)
  - Main Menu → Main Menu
- **Test**: Verify grade calculation and proper navigation

### 7. Penthouse Ending (`PenthouseEnding.tscn`)
- **Purpose**: Game conclusion and final statistics
- **Features**:
  - Story conclusion
  - Final statistics summary
  - Credits
  - Auto-scrolling narrative
- **Navigation Options**:
  - Play Again → Welcome Screen
  - Main Menu → Main Menu
- **Test**: Verify auto-scroll and final stats display

## Testing Checklist

### Basic Navigation
- [ ] Welcome Screen → Main Menu transition
- [ ] Main Menu → Floor Briefing transition
- [ ] Floor Briefing → Tutorial/Game Floor transition
- [ ] Game Floor → Floor Results transition
- [ ] Floor Results → Next Floor/Ending transition
- [ ] Ending → Welcome/Main Menu transition

### Game Data Persistence
- [ ] Loadout selection carries between scenes
- [ ] Floor progression tracks correctly
- [ ] Performance statistics accumulate
- [ ] Final statistics display correctly

### UI Functionality
- [ ] All buttons respond to clicks
- [ ] Checkboxes update objective status
- [ ] Timer displays correctly
- [ ] Grade calculation works properly
- [ ] Fade transitions work smoothly

### Prototype Features
- [ ] Auto-objective completion in tutorial
- [ ] Manual objective completion with keys 1-3
- [ ] Detection simulation with key D
- [ ] Pause/resume functionality
- [ ] Scene routing based on floor number

## Known Limitations (Prototype)
- No actual 3D gameplay mechanics
- Simplified objective system
- Auto-completion for demonstration
- Basic visual design
- No audio implementation
- Limited animation system

## Next Steps for Full Development
1. Implement actual stealth gameplay mechanics
2. Add detailed 3D environments for each floor
3. Create enemy AI and detection systems
4. Implement inventory and upgrade systems
5. Add audio and visual effects
6. Create detailed animations and cutscenes
7. Implement save/load functionality
8. Add accessibility features
9. Optimize performance
10. Add multiplayer features (if desired)

## File Structure
```
scenes/
├── WelcomeScreen.tscn
├── MainMenu.tscn
├── FloorBriefing.tscn
├── TutorialFloor.tscn
├── GameFloor.tscn
├── FloorResults.tscn
└── PenthouseEnding.tscn

scripts/
├── welcome_screen.gd
├── main_menu.gd
├── floor_briefing.gd
├── tutorial_floor.gd
├── game_floor.gd
├── floor_results.gd
├── penthouse_ending.gd
└── game_data.gd (singleton)
```

This prototype demonstrates the complete game flow and provides a foundation for full development of Shadow Ascent.