Project Specification: Shadow Ascent (1-Month Plan)

1. Core Project Details

Field

Detail

Project Title

Shadow Ascent: The Training Yards

Description

A 3D third-person locomotion technical demo focused on an advanced Interactive System. The player navigates a complex urban environment using fluid, context-aware parkour locomotion (climbing, vaulting, ledge-hanging). This is an offline, single-player technical showcase.

Core Technical Focus

Interactive System: Constraint-Based Locomotion (Parkour).

Engine / Language

Godot Engine 4.x (Vulkan Renderer) / GDScript

Development Period

1 Month (4 Weeks) - Full-Time

2. System Requirements (Godot 4.x 3D)

These requirements are based on developing and running the game using the Godot 4.x Vulkan renderer for 3D projects.

Development System Requirements (Minimum)

OS: Windows 7+, macOS 10.12+, or Ubuntu 18.04+.

CPU: Dual-core processor (Intel/AMD).

RAM: 4 GB (Minimum for 3D development).

GPU: Graphics card with Vulkan 1.0 support or OpenGL 3.3 Core Profile support (required for the editor and smooth 3D rendering).

Storage: SSD highly recommended for faster scene loading.

Playing System Requirements (Recommended)

CPU: Quad-core processor or better.

RAM: 8 GB or more.

GPU: Dedicated GPU with good Vulkan support (e.g., NVIDIA GeForce 10 series or AMD equivalent) for smooth framerates at high resolution.

3. Protagonist Story: Kael's First Ascent

The Protagonist: Kael

Kael is a former cartographer for the City Planning Bureau. He uses his intimate knowledge of the city's architecture to move where others cannot.

The Objective

This technical demo showcases Kael's skills. The goal is to navigate a complex, abandoned factory district ("The Training Yards") by mastering its parkour challenges, culminating in reaching a final goal point.

The Level

Level 1: The Training Yards (Locomotion Test): Kael must navigate a complex, abandoned factory district. (Focus: Mastery of Parkour, Climbing, and Vaulting systems.) This will be the only level in the project.

4. Development Timeline (4 Weeks)

Phase

Week

Activities & Goals

Focus (CS Deliverable)

I: Foundation & Prototypes

Week 1

Learning Godot & Core Setup. Both teammates complete initial Godot 4 tutorials. Set up version control (Git). T1 creates basic CharacterBody3D movement (run, jump). T2 blocks out Level 1 geometry with simple shapes (CSG or Kenney Assets).

Basic Player Controller; Scene Management; Version Control Setup

II: Core Locomotion System

Week 2

Implement the Core Locomotion (HSM). T1 builds the full Constraint-Based Locomotion State Machine (Grounded, Airborne, Climbing states). T2 refines Level 1 geometry to create specific parkour paths (high walls, gaps, low obstacles).

Constraint-Based Locomotion (Climbing)

III: Advanced Locomotion & Game Loop

Week 3

Implement Advanced States & UI. T1 implements advanced parkour states (e.g., Vaulting, Ledge Hang/Climb Up). T2 builds the core Game Loop: Main Menu, Pause Menu, and a "Win" trigger at the end of the level.

Advanced Locomotion (Vaulting); Core Game Loop

IV: Polish, Bug Fixing, Documentation

Week 4

Finalization. Both teammates fix all major bugs. T1 fine-tunes physics and camera controls. T2 adds basic lighting, sound effects, and polish to the level. Both write the Master's project documentation, focusing on the design and implementation of the Locomotion system.

Final Technical Demo; Academic Documentation

5. Teammate Steps & Task Distribution (1-Month Plan)

Given the 1-month timeline, the focus is split between Systems Programming and Level/UI Design.

Teammate 1: Lead Systems Programmer (Player & Locomotion)

Focus: All player-related code. Implementing the core technical deliverable (the parkour system).

Task Category

Week

Specific Steps

Godot Foundation

1

Complete the official "Your first 3D game" Godot tutorial. Learn CharacterBody3D and GDScript basics.

Basic Movement

1

Implement movement, jumping, and gravity. Add basic capsule collision and a third-person camera.

Locomotion Core (HSM)

2

Implement the Hierarchical State Machine (HSM). Create Grounded, Airborne states. Implement Raycasting for detecting climbable walls and create the Climbing state.

Advanced Parkour

3

Implement the Vaulting state (auto-jumping over low obstacles) and LedgeHang / LedgeClimbUp states.

Polish

4

Fine-tune all physics values (speed, gravity, jump height) to feel "good." Work with T2 to fix any collision bugs. Write the technical documentation for the State Machine.

Teammate 2: Level Designer & UI/Game Loop Programmer

Focus: Building the "playground" for the player and creating the "game" wrapper around the core mechanic.

Task Category

Week

Specific Steps

Godot Foundation

1

Complete the official "Your first 3D game" Godot tutorial. Learn Godot's Scene System and Control Nodes (for UI).

Level Blockout

1

Download Kenney Assets. Use Godot's GridMaps or manual placement to build the Training Yards (Level 1) with simple shapes.

Level Design

2

Refine Level 1 geometry to create specific, intentional parkour paths that test T1's climbing and jumping systems.

Game Loop & UI

3

Create a Main Menu scene (Start, Quit buttons). Create a Pause Menu. Create a global script (Global.gd) to handle scene loading. Add a "Win" Area3D trigger to the end of the level.

Polish

4

Add simple lighting (DirectionalLight3D, WorldEnvironment) to make the level look better. Add basic sound effects (using AudioStreamPlayer) for jump, land, and climbing.

6. Specific Resources to Obtain

Since the team is new to Godot, focusing on official, beginner-friendly resources for Godot 4 is essential.

Official Godot 4 Documentation: The official documentation is extensive and high-quality.

Start Here: Search for "Godot Engine Your first 3D game" tutorial.

For Locomotion: Search for "Godot 4 CharacterBody3D movement" and "Godot 4 state machine tutorial" (for the parkour system).

For UI: Search for "Godot 4 creating a main menu."

Kenney Assets (Art Assets): To save time on 3D modeling, download free, low-poly 3D models from Kenney (e.g., "Prototype Textures" or "City Kit"). Their style is clean, functional, and ideal for prototyping.

Visual Noise/Sound Effects: Use free sound libraries (like Freesound) for footstep and jump sounds. Focus on quality, not quantity.

Version Control: Mandatory. Use Git and GitHub (or similar) from Day 1. Every teammate must commit their work daily.
