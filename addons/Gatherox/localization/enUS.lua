local L = LibStub('AceLocale-3.0'):NewLocale('Gatherox', 'enUS', true)
if not L then return end

-- General
L['AddonName'] = 'Gatherox'
L['AddonLoaded'] = 'Gatherox loaded. Type /gatherox for help.'

-- Categories
L['Category_Herbs'] = 'Herbs'
L['Category_Ore'] = 'Ore'
L['Category_Fish'] = 'Fish'
L['Category_Leather'] = 'Leather'

-- Commands
L['CmdToggle'] = 'Toggle Gatherox window'
L['CmdClear'] = 'Clear all data'
L['CmdExport'] = 'Export data'
L['CmdHelp'] = 'Show help'

-- Messages
L['MsgNodeRecorded'] = 'Node recorded: %s'
L['MsgDataCleared'] = 'All node data cleared'
L['MsgNoData'] = 'No node data found'
L['MsgExportComplete'] = 'Data exported to chat'

-- Settings
L['Setting_AutoRecord'] = 'Auto-record nodes'
L['Setting_ShowMinimap'] = 'Show on minimap'
L['Setting_ShowWorldMap'] = 'Show on world map'
L['Setting_MinimapSize'] = 'Minimap icon size'

-- Help
L['Help_Toggle'] = 'Toggle Gatherox window'
L['Help_Clear'] = 'Clear all recorded data'
L['Help_Export'] = 'Export data to chat'
L['Help_Help'] = 'Show this help' 