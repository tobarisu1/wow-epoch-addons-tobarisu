--[[
	SimpleLogger - Lightweight logging for WoW 3.3.5a addon debugging
	Provides simple error logging and export functionality
--]]

-- Initialize saved variables
SimpleLoggerDB = SimpleLoggerDB or {
	enabled = true,
	logErrors = true,
	logWarnings = true,
	logInfo = false,
	maxLogs = 500,
	lastCleanup = 0
}

-- Main addon object
local SimpleLogger = {
	logs = {},
	startTime = GetTime()
}

--[[
	Logging Functions
--]]

function SimpleLogger:Log(message, level, addon)
	if not self.settings.enabled then return end
	
	-- Check log level
	if level == "ERROR" and not self.settings.logErrors then return end
	if level == "WARNING" and not self.settings.logWarnings then return end
	if level == "INFO" and not self.settings.logInfo then return end
	
	-- Create log entry
	local logEntry = {
		timestamp = GetTime(),
		timeString = date("%H:%M:%S"),
		level = level,
		message = message,
		addon = addon or "Unknown",
		stack = debugstack(2, 2, 0) -- Get call stack
	}
	
	-- Add to logs
	table.insert(self.logs, logEntry)
	
	-- Limit log entries
	if #self.logs > self.settings.maxLogs then
		table.remove(self.logs, 1)
	end
	
	-- Print to chat with colors
	local colors = {
		ERROR = "|cFFFF0000",
		WARNING = "|cFFFFFF00", 
		INFO = "|cFF00FF00"
	}
	
	local color = colors[level] or "|cFFFFFFFF"
	local prefix = color .. "[SimpleLogger]|r "
	if addon then
		prefix = prefix .. "|cFF888888[" .. addon .. "]|r "
	end
	
	print(prefix .. message)
end

function SimpleLogger:LogError(message, addon)
	self:Log(message, "ERROR", addon)
end

function SimpleLogger:LogWarning(message, addon)
	self:Log(message, "WARNING", addon)
end

function SimpleLogger:LogInfo(message, addon)
	self:Log(message, "INFO", addon)
end

--[[
	Global Functions for Other Addons
--]]

function SimpleLogger_LogError(message, addon)
	if SimpleLogger and SimpleLogger.LogError then
		SimpleLogger:LogError(message, addon)
	end
end

function SimpleLogger_LogWarning(message, addon)
	if SimpleLogger and SimpleLogger.LogWarning then
		SimpleLogger:LogWarning(message, addon)
	end
end

function SimpleLogger_LogInfo(message, addon)
	if SimpleLogger and SimpleLogger.LogInfo then
		SimpleLogger:LogInfo(message, addon)
	end
end

--[[
	Initialization
--]]

local function Initialize()
	-- Initialize settings
	SimpleLogger.settings = SimpleLoggerDB
	
	-- Register slash commands
	SLASH_SIMPLELOGGER1 = "/logger"
	SLASH_SIMPLELOGGER2 = "/sl"
	SlashCmdList["SIMPLELOGGER"] = function(msg)
		SimpleLogger:HandleSlashCommand(msg)
	end
	
	-- Log startup
	SimpleLogger:LogInfo("SimpleLogger initialized", "SimpleLogger")
	print("|cFF00FF00SimpleLogger|r loaded. Type /logger for help.")
end

--[[
	Slash Commands
--]]

function SimpleLogger:HandleSlashCommand(input)
	local command = string.lower(input)
	
	if command == 'export' or command == 'e' then
		self:ExportLogs()
	elseif command == 'clear' or command == 'c' then
		self:ClearLogs()
	elseif command == 'stats' or command == 's' then
		self:ShowStats()
	elseif command == 'help' or command == 'h' or command == '' then
		self:ShowHelp()
	elseif command == 'errors' then
		self.settings.logErrors = not self.settings.logErrors
		print("|cFF00FF00SimpleLogger|r: Error logging " .. (self.settings.logErrors and "enabled" or "disabled"))
	elseif command == 'warnings' then
		self.settings.logWarnings = not self.settings.logWarnings
		print("|cFF00FF00SimpleLogger|r: Warning logging " .. (self.settings.logWarnings and "enabled" or "disabled"))
	elseif command == 'info' then
		self.settings.logInfo = not self.settings.logInfo
		print("|cFF00FF00SimpleLogger|r: Info logging " .. (self.settings.logInfo and "enabled" or "disabled"))
	else
		print("|cFF00FF00SimpleLogger|r: Unknown command. Type /logger help for options.")
	end
end

function SimpleLogger:ShowHelp()
	print("|cFF00FF00SimpleLogger Commands:|r")
	print("  /logger export - Export logs to chat")
	print("  /logger clear - Clear current logs")
	print("  /logger stats - Show logging statistics")
	print("  /logger errors - Toggle error logging")
	print("  /logger warnings - Toggle warning logging")
	print("  /logger info - Toggle info logging")
	print("  /logger help - Show this help")
end

function SimpleLogger:ExportLogs()
	if #self.logs == 0 then
		print("|cFF00FF00SimpleLogger|r: No logs to export.")
		return
	end
	
	print("|cFF00FF00SimpleLogger Log Export:|r")
	print("|cFF888888Total entries: " .. #self.logs .. "|r")
	
	for i, log in ipairs(self.logs) do
		if i <= 50 then -- Limit to first 50 entries
			local colors = {
				ERROR = "|cFFFF0000",
				WARNING = "|cFFFFFF00",
				INFO = "|cFF00FF00"
			}
			local color = colors[log.level] or "|cFFFFFFFF"
			print(string.format("%s[%s] %s %s: %s", 
				color, log.timeString, log.level, log.addon, log.message))
		else
			print("|cFF888888... and " .. (#self.logs - 50) .. " more entries|r")
			break
		end
	end
end

function SimpleLogger:ClearLogs()
	self.logs = {}
	print("|cFF00FF00SimpleLogger|r: Logs cleared.")
end

function SimpleLogger:ShowStats()
	local uptime = GetTime() - self.startTime
	local errorCount = 0
	local warningCount = 0
	local infoCount = 0
	
	for _, log in ipairs(self.logs) do
		if log.level == "ERROR" then errorCount = errorCount + 1
		elseif log.level == "WARNING" then warningCount = warningCount + 1
		elseif log.level == "INFO" then infoCount = infoCount + 1
		end
	end
	
	print("|cFF00FF00SimpleLogger Statistics:|r")
	print("  Total logs: " .. #self.logs)
	print("  Errors: " .. errorCount)
	print("  Warnings: " .. warningCount)
	print("  Info: " .. infoCount)
	print("  Uptime: " .. string.format("%.1f", uptime) .. " seconds")
	print("  Error logging: " .. (self.settings.logErrors and "Enabled" or "Disabled"))
	print("  Warning logging: " .. (self.settings.logWarnings and "Enabled" or "Disabled"))
	print("  Info logging: " .. (self.settings.logInfo and "Enabled" or "Disabled"))
end

--[[
	Error Catching
--]]

-- Hook common error sources
local originalCreateFrame = CreateFrame
CreateFrame = function(frameType, name, parent, template)
	local success, frame = pcall(originalCreateFrame, frameType, name, parent, template)
	if not success then
		SimpleLogger:LogError("Frame creation failed: " .. tostring(frame), "UI")
	end
	return frame
end

-- Initialize when addon loads
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		Initialize()
	end
end) 