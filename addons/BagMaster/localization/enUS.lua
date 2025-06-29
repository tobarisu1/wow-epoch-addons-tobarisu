local L = LibStub('AceLocale-3.0'):NewLocale('BagMaster', 'enUS', true)
if not L then return end

-- General
L['ToggleBags'] = 'Toggle BagMaster'
L['ToggleBank'] = 'Toggle Bank'
L['ToggleKeys'] = 'Toggle Keyring'

-- Categories
L['Category_Consumables'] = 'Consumables'
L['Category_Equipment'] = 'Equipment'
L['Category_TradeGoods'] = 'Trade Goods'
L['Category_Quest'] = 'Quest Items'
L['Category_Junk'] = 'Junk'
L['Category_Currency'] = 'Currency'
L['Category_Other'] = 'Other'

-- Views
L['View_Bags'] = 'Bags'
L['View_Bank'] = 'Bank'
L['View_Keyring'] = 'Keyring'
L['View_Switched'] = 'Switched to %s view'

-- Tooltips
L['TipShowInventory'] = 'Left Click: Show Inventory'
L['TipShowBank'] = 'Shift+Left Click: Show Bank'
L['TipShowKeyring'] = 'Alt+Left Click: Show Keyring'
L['TipShowOptions'] = 'Right Click: Show Options'

-- Slash Commands
L['CmdSort'] = 'Sort inventory'
L['CmdOrganize'] = 'Organize inventory'
L['CmdToggle'] = 'Toggle BagMaster window'
L['CmdBags'] = 'Switch to bags view'
L['CmdBank'] = 'Switch to bank view'
L['CmdKeyring'] = 'Switch to keyring view'
L['CmdView'] = 'Cycle through views'
L['CmdHelp'] = 'Show this help'

-- Settings
L['Setting_AutoSort'] = 'Auto-sort on open'
L['Setting_AutoOrganize'] = 'Auto-organize on open'
L['Setting_ShowCategories'] = 'Show category headers'
L['Setting_CategoryOrder'] = 'Category order'
L['Setting_ShowBank'] = 'Show bank integration'
L['Setting_ShowKeyring'] = 'Show keyring integration'
L['Setting_DefaultView'] = 'Default view' 