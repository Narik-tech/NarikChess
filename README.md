# Game Modes

## 4D Chess (aka 5D Chess)
- Standard chess movement, plus the ability to move back in time.
- Time travel creates branching timelines.

## Classic Chess
- Standard chess rules.

# Variants

## Conway Chess
- Four Conway’s Game of Life squares start at the center of the board.
- Conway squares block piece movement.
- **Survival:** A Conway square remains alive if adjacent to **2 or 3** other Conway squares or chess pieces.
- **Birth:** A Conway square spawns in an empty square if adjacent to **exactly 3** other Conway squares or chess pieces, with at least **1** being a Conway square.

## Duck Chess
- At game start, Black chooses an empty square to place the duck.
- On every move, the active player must move the duck to an empty square.
- The duck blocks all movement through its square.

## Spell Chess
- Players may cast up to **one spell per turn**.
- **Available spells:**
  - **Freeze**  
    Prevents all pieces from moving for one turn within a **3×3×3×3** area.  
    Uses: **3**
  - **Wall**  
    Permanently blocks movement on a chosen square once placed.  
    Uses: **1**
- Any additional spell scripts added to `mods/spell_chess/spell_scripts` are automatically detected and added as selectable spells with base logic.

# Features
- Variants are compatible with both game modes.
- Multiple variants can be played simultaneously.
- The project is designed for flexible alterations to core gameplay.

# Current Limitations
- Local play only.
- No check or checkmate detection. A player wins by capturing the enemy king.

# Build Structure
- All variants are implemented as mods in a **Mods** folder, separate from the main build.
- Any script extending `Mod` added to this folder is automatically detected and appears as a selectable option in the main menu.
