--[[
	Written by Begi.
	Configuration for AdminModule.
--]]

local Config = {}

-- Remote Events
Config.Remotes = {
	CommandFeedbackEvent = script.Parent:WaitForChild("CommandFeedbackEvent")
}

-- General Settings
Config.CommandPrefix = "/"
Config.AdminUserIds = {1234, 4321} -- Add admin UserIds here

-- Webhook Settings
Config.WebhookURL = "your_webhook"

-- Ban Settings
Config.BanApplyToUniverse = true
Config.BanExcludeAltAccounts = true

-- Unban Settings
Config.UnbanExcludeAltAccounts = true

-- History Settings
Config.SendTxt = true
Config.TxtDividerCharacter = "#"

-- Embeds Configuration
Config.Embeds = {
	Ban = {
		title = "Player Banned",
		color = 0xff0000,
		fields = {
			{ name = "Target ID", value = "{TargetID}", inline = true },
			{ name = "Duration", value = "{Duration}", inline = false },
			{ name = "Reason", value = "{Reason}", inline = true },
			{ name = "Admin", value = "{Admin}", inline = false }
		}
	},
	Unban = {
		title = "Player Unbanned",
		color = 0x00ff00,
		fields = {
			{ name = "Target ID", value = "{TargetID}", inline = true },
			{ name = "Admin", value = "{Admin}", inline = false }
		}
	},
	CheckHistory = {
		title = "Ban History",
		color = 0xffff00,
		description = "Ban history for player with ID: {TargetID}",
		fields = {
			{ name = "Admin", value = "{Admin}", inline = false },
		}
	},
	GetID = {
		title = "Get Player ID",
		color = 0x0000ff,
		fields = {
			{ name = "Target", value = "{Target}", inline = true },
			{ name = "TargetID", value = "{TargetID}", inline = true },
			{ name = "Admin", value = "{Admin}", inline = false },	
		}
	}
}

-- Reason Placeholders
Config.ReasonPlaceholders = {
	NoReason = "No reason specified.",
	ReasonTemplate = "\nFor more details or ban appeal contact us on Discord."	-- use "\n" to create a new line
}

-- Messages Configuration
Config.Messages = {
	Ban = {
		Success = "Player banned successfully.",
		Failure = "Failed to ban player. {Error}"
	},
	Unban = {
		Success = "Player unbanned successfully.",
		Failure = "Failed to unban player. {Error}"
	},
	CheckHistory = {
		Success = "Ban history retrieved successfully.",
		Failure = "Failed to retrieve ban history. {Error}"
	},
	GetID = {
		Success = "User ID is: {UserID}",
		Failure = "Failed to retrieve user ID. {Error}"
	}
}

return Config
