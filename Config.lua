--[[
	Written by Begi.
	Configuration for AdminModule.
--]]

local Config = {}

-- Remote Events
Config.Remotes = {
	CommandFeedbackEvent = script.Parent:WaitForChild("CommandFeedbackEvent"),
	CommandsFromUI = script.Parent:WaitForChild("ExecuteCommandFromUI"),
	BanFromUI = script.Parent:WaitForChild("BanFromUI")
}

-- General Settings
Config.CommandPrefix = "/"
Config.AdminUserIds = {1234, 4321} -- Add admin UserIds here
Config.ToggleKey = Enum.KeyCode.F4	-- Only change the key. Do not touch Enum.KeyCode.

-- Webhook Settings
Config.WebhookURL = "your_webhook_here"

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
	NoReason = "No reason specified",
	ReasonTemplate = ". For more details or ban appeal please contact us." -- DO NOT USE SPECIAL CHARACTERS
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
