local L = LibStub('AceLocale-3.0'):NewLocale('JunkBot', 'enUS', true)
if not L then return end

-- General
L['AddonName'] = 'JunkBot'
L['AddonLoaded'] = 'JunkBot loaded. Type /junkbot for help.'

-- Commands
L['CmdToggle'] = 'Toggle auto-sell'
L['CmdSell'] = 'Sell junk now'
L['CmdList'] = 'List junk items'
L['CmdHelp'] = 'Show help'

-- Messages
L['MsgAutoSellEnabled'] = 'Auto-sell enabled'
L['MsgAutoSellDisabled'] = 'Auto-sell disabled'
L['MsgSellingJunk'] = 'Selling junk items...'
L['MsgSoldItems'] = 'Sold %d junk items for %s'
L['MsgNoJunkFound'] = 'No junk items found'
L['MsgNotAtVendor'] = 'You must be at a vendor to sell items'

-- Settings
L['Setting_AutoSell'] = 'Auto-sell junk'
L['Setting_ConfirmSell'] = 'Confirm before selling'
L['Setting_ShowMessages'] = 'Show sell messages'
L['Setting_IgnoreBound'] = 'Ignore soulbound items'

-- Help
L['Help_Toggle'] = 'Toggle auto-sell on/off'
L['Help_Sell'] = 'Sell junk items now'
L['Help_List'] = 'List all junk items in bags'
L['Help_Help'] = 'Show this help' 