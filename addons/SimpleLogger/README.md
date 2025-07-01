# SimpleLogger

A lightweight logging system for debugging WoW 3.3.5a addons.

## Features

- **Error Logging**: Captures errors with timestamps and stack traces
- **Log Export**: Export logs to chat for easy debugging
- **Configurable Levels**: Toggle ERROR, WARNING, and INFO logging
- **Addon Integration**: Global functions for other addons to use
- **Statistics**: Track log counts and uptime
- **Lightweight**: Minimal performance impact

## Commands

- `/logger` or `/sl` - Show help
- `/logger export` - Export logs to chat
- `/logger clear` - Clear current logs
- `/logger stats` - Show logging statistics
- `/logger errors` - Toggle error logging
- `/logger warnings` - Toggle warning logging
- `/logger info` - Toggle info logging

## Integration

Other addons can use SimpleLogger by calling these global functions:

```lua
SimpleLogger_LogError(message, addon)
SimpleLogger_LogWarning(message, addon)
SimpleLogger_LogInfo(message, addon)
```

Example:
```lua
if SimpleLogger_LogError then
    SimpleLogger_LogError("Something went wrong", "MyAddon")
end
```

## Settings

- **Enabled**: Toggle the entire addon
- **Log Errors**: Capture error messages
- **Log Warnings**: Capture warning messages
- **Log Info**: Capture info messages
- **Max Logs**: Maximum number of logs to keep (default: 500)

## Compatibility

- WoW 3.3.5a (WotLK)
- Interface: 30300
- No dependencies required
- Works with other addons 