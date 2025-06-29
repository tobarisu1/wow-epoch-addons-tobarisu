# World of Warcraft 3.3.5a Addon Collection

```
████████╗ ██████╗ ██████╗  █████╗ ██████╗ ██╗███████╗██╗   ██╗
╚══██╔══╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗██║██╔════╝██║   ██║
   ██║   ██║   ██║██████╔╝███████║██████╔╝██║███████╗██║   ██║
   ██║   ██║   ██║██╔══██╗██╔══██║██╔══██╗██║╚════██║██║   ██║
   ██║   ╚██████╔╝██████╔╝██║  ██║██║  ██║██║███████║╚██████╔╝
   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝ ╚═════╝ 
```

**Project**: wow-epoch-addons-tobarisu  
**Version**: 1.0.0  
**Date**: June 2025  
**Author**: TOBARISU  
**WoW Version**: 3.3.5a (WotLK)  
**Interface**: 30300  

This repository contains a collection of custom Lua addons for World of Warcraft 3.3.5a (WotLK), developed for personal use and learning. Each addon is designed to enhance gameplay and provide useful functionality for WoW 3.3.5a servers.

## Project Structure

```
wow-epoch-addons-tobarisu/
├── addons/                    # Collection of individual addon directories
│   ├── AddonName1/           # Individual addon structure
│   │   ├── AddonName1.toc    # Addon manifest file (Interface: 30300)
│   │   ├── core.lua          # Main addon logic
│   │   └── README.md         # Addon-specific documentation
│   ├── AddonName2/           # Another addon
│   └── ...                   # More addons
├── templates/                 # Reusable addon templates
├── docs/                     # Development documentation
├── tools/                    # Development utilities
│   ├── deploy_addons.sh      # Personal deployment script (not pushed)
│   └── deploy_addons_public.sh # Public-friendly deployment script
└── README.txt               # This file
```

## Addon Collection

This repository contains multiple addons, each designed for specific purposes:

- **AddonName1**: Brief description of what this addon does
- **AddonName2**: Brief description of what this addon does
- **AddonName3**: Brief description of what this addon does

Each addon can be deployed individually or all at once using the deployment tools.

## Development Setup

### Prerequisites
- World of Warcraft 3.3.5a installed
- Text editor with Lua support (VS Code with Lua extension recommended)
- Git for version control

### WoW 3.3.5a Addon Directory Locations
- **Windows**: `C:\Program Files (x86)\World of Warcraft\Interface\AddOns\`
- **macOS**: `/Applications/World of Warcraft/Interface/AddOns/`
- **Linux**: `~/.wine/drive_c/Program Files (x86)/World of Warcraft/Interface/AddOns/`

### Development Workflow
1. Create addon in `addons/` directory
2. Use deployment script to copy to WoW AddOns directory for testing
3. Use `/reload` in-game to test changes
4. Use `/dump` and `/print` for debugging

## Deployment

### For Personal Use
Use the personal deployment script (not included in this repository):
```bash
./tools/deploy_addons.sh [addon_name]
```

### For Public Use
Use the public deployment script and configure your paths:
```bash
# First, edit the script to set your WoW directory
nano tools/deploy_addons_public.sh

# Then run it
./tools/deploy_addons_public.sh [addon_name]
```

## Addon Development Guidelines

### TOC File Structure (WoW 3.3.5a)
```lua
## Interface: 30300  # WoW 3.3.5a (WotLK)
## Title: My Addon Name
## Notes: Brief description
## Author: Your Name
## Version: 1.0.0

core.lua
```

### Best Practices
- Use descriptive variable and function names
- Comment your code thoroughly, especially for WoW API calls
- Follow WoW API naming conventions
- Test thoroughly in-game
- Use proper error handling with pcall() when appropriate
- Keep addons lightweight and efficient
- Use local variables over globals for performance

### Common WoW 3.3.5a API Patterns
```lua
-- Event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    -- Handle event
end)

-- Slash commands
SLASH_MYADDON1 = "/myaddon"
SlashCmdList["MYADDON"] = function(msg)
    -- Handle slash command
end

-- Saved variables
MyAddonDB = MyAddonDB or {}
```

## Getting Started

1. Create a new addon directory in `addons/`
2. Create a `.toc` file with proper metadata (Interface: 30300)
3. Create your main Lua file
4. Use deployment script to copy to WoW AddOns directory
5. Enable in-game and test with `/reload`

## Resources

- [WoW 3.3.5a API Documentation](https://wowpedia.fandom.com/wiki/World_of_Warcraft_API)
- [Lua Programming Language](https://www.lua.org/manual/5.1/)
- [WoW Addon Development Guide](https://wowpedia.fandom.com/wiki/AddOn_development)
- [WoW 3.3.5a Specific APIs](https://wowpedia.fandom.com/wiki/World_of_Warcraft_API:3.3.5)

## License

This project is for personal use and learning purposes. Feel free to use and modify these addons for your own WoW 3.3.5a server.
