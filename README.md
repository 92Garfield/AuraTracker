# AuraTracker

A World of Warcraft addon for tracking and displaying auras (buffs and debuffs) with advanced filtering and customization options.

## Features

- **Multiple AuraBars**: Up to 5 independent aura bars with individual configurations
- **Advanced Filtering**:
  - Blizzard filters (Helpful, Harmful, Player, Raid, Cancelable, etc.)
  - Special filters (Pre-Combat, Permanent, Consumable)
  - Aura Group filters (Show Only, Exclude)
  - Weapon enchants toggle
- **Aura Groups**: Create custom spell ID groups for targeted filtering
- **Profile Management**: Multiple profiles with easy switching, copying, and deletion
- **Customizable Appearance**: 
  - Adjustable icon size
  - Configurable columns and grow direction
  - Position controls
  - Optional area background display
- **Combat Visibility**: Show/hide bars based on combat state
- **Tooltips**: Optional tooltips on hover
- **Blizzard BuffFrame**: Option to hide default buff frame

## Installation

1. Download the latest release
2. Extract the `AuraTracker` folder to your `World of Warcraft\_retail_\Interface\AddOns\` directory
3. Restart World of Warcraft or reload UI (`/reload`)

## Usage

### Slash Commands

- `/auratracker` or `/at` - Open options panel
- `/at config` - Open options panel
- `/at show` - Show all aura windows
- `/at hide` - Hide all aura windows
- `/at help` - Show available commands

### Configuration

Open the options panel using `/auratracker` or through Interface > AddOns > AuraTracker.

#### General Settings
- Hide All Windows Out of Combat
- Hide Blizzard BuffFrame
- Show Area (background display)

#### AuraBar Settings (1-5)
Each AuraBar can be independently configured with:
- Enable/disable toggle
- Show only in combat option
- Tooltips on/off
- Blizzard API filters
- Special filters (pre-combat, permanent, consumable)
- Aura group filters
- Weapon enchants toggle
- Appearance (size, columns, grow direction)
- Position (X, Y, anchor point)

#### Aura Groups
Create custom groups of spell IDs for targeted filtering:
1. Go to the "Aura Groups" tab
2. Click "+" or select "< Create New Group >"
3. Enter a name for the group
4. Add comma-separated spell IDs
5. Click "Save Group"
6. Use the group in AuraBar filters (Show Only or Exclude)

#### Profiles
Manage multiple configurations:
- Create new profiles
- Switch between profiles
- Copy settings from one profile to another
- Delete unused profiles
- Reset profile to defaults

## Version

Current Version: 1.0.0

## Author

Demonperson a.k.a. 92Garfield

## License

This addon is released as-is. Feel free to modify and distribute.

## Support

For issues, suggestions, or contributions, please use the GitHub issues page.
