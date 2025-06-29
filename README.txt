# World of Warcraft Lua Addon Development

This repository contains custom Lua addons for World of Warcraft, developed for personal use and learning.

## Project Structure

```
wow_addon_dev/
├── addons/                    # Individual addon directories
│   ├── MyFirstAddon/         # Example addon structure
│   │   ├── MyFirstAddon.toc   # Addon manifest file
│   │   ├── core.lua          # Main addon logic
│   │   └── README.md         # Addon-specific documentation
│   └── ...
├── templates/                 # Reusable addon templates
├── docs/                     # Development documentation
├── tools/                    # Development utilities
└── README.txt               # This file
```

## Development Setup

### Prerequisites
- World of Warcraft installed
- Text editor with Lua support (VS Code with Lua extension recommended)
- Git for version control

### WoW Addon Directory Location
- **Windows**: `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\`
- **macOS**: `/Applications/World of Warcraft/_retail_/Interface/AddOns/`
- **Linux**: `~/.wine/drive_c/Program Files (x86)/World of Warcraft/_retail_/Interface/AddOns/`

### Development Workflow
1. Create addon in `addons/` directory
2. Copy to WoW AddOns directory for testing
3. Use `/reload` in-game to test changes
4. Use `/dump` and `/print` for debugging

## Addon Development Guidelines

### TOC File Structure
```lua
## Interface: 100200  # WoW version (10.2.0)
## Title: My Addon Name
## Notes: Brief description
## Author: Your Name
## Version: 1.0.0

core.lua
```

### Best Practices
- Use descriptive variable and function names
- Comment your code thoroughly
- Follow WoW API naming conventions
- Test thoroughly in-game
- Use proper error handling
- Keep addons lightweight and efficient

### Common WoW API Patterns
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
```

## Getting Started

1. Create a new addon directory in `addons/`
2. Create a `.toc` file with proper metadata
3. Create your main Lua file
4. Copy to WoW AddOns directory
5. Enable in-game and test

## Resources

- [WoW API Documentation](https://wowpedia.fandom.com/wiki/World_of_Warcraft_API)
- [Lua Programming Language](https://www.lua.org/manual/5.1/)
- [WoW Addon Development Guide](https://wowpedia.fandom.com/wiki/AddOn_development)

## License

This project is for personal use and learning purposes.
