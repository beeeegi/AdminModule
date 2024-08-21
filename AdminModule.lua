--[[
    Written by Begi.
    AdminModule - Roblox Admin Commands System Based On New BanAPI.
--]]

local AdminModule = {}

-- Services
local players = game:GetService("Players")
local httpService = game:GetService("HttpService")

-- Configuration Settings
AdminModule.Config = {}

-- Remote Events
AdminModule.Config.Remotes = {
	CommandFeedbackEvent = script.Parent:WaitForChild("CommandFeedbackEvent"),
	CommandsFromUI = script.Parent:WaitForChild("ExecuteCommandFromUI"),
	BanFromUI = script.Parent:WaitForChild("BanFromUI")
}

-- General Settings
AdminModule.Config.CommandPrefix = "/"
AdminModule.Config.AdminUserIds = {1234, 4321, 265075019} -- Add admin UserIds here
AdminModule.Config.ToggleKey = Enum.KeyCode.F4	-- Only change the key. Do not touch Enum.KeyCode.

-- Webhook Settings
AdminModule.Config.WebhookURL = "your_webhook_here"

-- Ban Settings
AdminModule.Config.BanApplyToUniverse = true
AdminModule.Config.BanExcludeAltAccounts = true

-- Unban Settings
AdminModule.Config.UnbanExcludeAltAccounts = true

-- History Settings
AdminModule.Config.SendTxt = true
AdminModule.Config.TxtDividerCharacter = "#"

-- Embeds Configuration
AdminModule.Config.Embeds = {
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
AdminModule.Config.ReasonPlaceholders = {
	NoReason = "No reason specified",
	ReasonTemplate = ". For more details or ban appeal please contact us." -- DO NOT USE SPECIAL CHARACTERS
}

-- Messages Configuration
AdminModule.Config.Messages = {
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

-- Helper function to send a message to a Discord webhook
local function sendDiscordMessage(embed)    
	local data = httpService:JSONEncode({ embeds = { embed } })
	local headers = { ["Content-Type"] = "application/json" }

	local success, error = pcall(function()
		local v1 = httpService:PostAsync(AdminModule.Config.WebhookURL, data, Enum.HttpContentType.ApplicationJson)
	end)
	if not success then
		warn("Failed to send message to Discord: " .. tostring(error))
	end
end

-- Helper function to get a player's profile link
local function getProfileLink(id)
	return "https://www.roblox.com/users/" .. tostring(id) .. "/profile"
end

-- Helper function to parse duration strings
function AdminModule.parseDuration(durationStr)
	if not durationStr then
		return nil
	end

	local duration = tonumber(durationStr:match("(%d+)"))
	local unit = durationStr:match("(%a+)")

	if not duration or not unit then
		return nil
	end

	if unit == "s" then
		return duration
	elseif unit == "m" then
		return duration * 60
	elseif unit == "h" then
		return duration * 60 * 60
	elseif unit == "d" then
		return duration * 60 * 60 * 24
	else
		return nil
	end
end

-- Function to ban a player
function AdminModule.BanPlayer(id, durationStr, reason, adminPlayer)
	local duration = AdminModule.parseDuration(durationStr)
	local displayDuration = "N/A"

	if not duration then
		duration = -1
		displayDuration = "Permanent"
	else
		displayDuration = durationStr
	end

	if not reason or reason == "" then
		reason = AdminModule.Config.ReasonPlaceholders.NoReason
	end

	local embed = AdminModule.Config.Embeds.Ban
	embed.description = "[Target's Roblox Profile]("..getProfileLink(id)..")"
	embed.fields[1].value = tostring(id)
	embed.fields[2].value = displayDuration
	embed.fields[3].value = reason
	embed.fields[4].value = adminPlayer.Name
	embed.footer = { text = os.date("%X | %d.%m.%Y") }

	local displayReason = reason..AdminModule.Config.ReasonPlaceholders.ReasonTemplate

	local config = {
		UserIds = { id },
		Duration = duration,
		DisplayReason = "Reason: " .. displayReason,
		PrivateReason = os.date("%X | %d.%m.%Y"),
		ApplyToUniverse = AdminModule.Config.BanApplyToUniverse,
		ExcludeAltAccounts = AdminModule.Config.BanExcludeAltAccounts
	}

	local success, error = pcall(function()
		players:BanAsync(config)
	end)
	if success then
		sendDiscordMessage(embed)
		AdminModule.Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, AdminModule.Config.Messages.Ban.Success)
	else
		AdminModule.Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, AdminModule.Config.Messages.Ban.Failure:gsub("{Error}", tostring(error)))
	end
end

-- Function to unban a player
function AdminModule.UnbanPlayer(id: IntValue, adminPlayer: Player)
	local success, error = pcall(function()
		local config = {
			UserIds = { id },
			ApplyToUniverse = AdminModule.Config.UnbanExcludeAltAccounts
		}
		players:UnbanAsync(config)
	end)

	if success then
		local embed = AdminModule.Config.Embeds.Unban
		embed.description = "[Target's Roblox Profile]("..getProfileLink(id)..")"
		embed.fields[1].value = tostring(id)
		embed.fields[2].value = adminPlayer.Name
		embed.footer = { text = os.date("%X | %d.%m.%Y") }

		sendDiscordMessage(embed)
		AdminModule.Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, AdminModule.Config.Messages.Unban.Success)
	else
		AdminModule.Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, AdminModule.Config.Messages.Unban.Failure:gsub("{Error}", tostring(error)))
	end
end

-- Function to check player history (does not work in the studio)
function AdminModule.CheckPlayerHistory(id, adminPlayer)
	local success, banHistory = pcall(function()
		return players:GetBanHistoryAsync(id)
	end)

	if success then
		local results = {}
		local page = banHistory:GetCurrentPage()

		for _, tableEntry in ipairs(page) do
			if tableEntry.Ban then
				local result = {
					DisplayReason = tableEntry.DisplayReason,
					PrivateReason = tableEntry.PrivateReason,
					Duration = tableEntry.Duration
				}
				table.insert(results, result)
			end
		end

		if AdminModule.Config.SendTxt then
			local logContent = ""
			for index, result in ipairs(results) do
				logContent = logContent .. "##############################################\n"
				logContent = logContent .. "Ban Case " .. index .. "\n"
				logContent = logContent .. result.DisplayReason .. "\n"
				logContent = logContent .. "Date: " .. result.PrivateReason .. "\n"
				logContent = logContent .. "Duration: " .. tostring(result.Duration) .. " seconds\n\n"
				logContent = logContent .. "##############################################\n\n"
			end

			local boundary = "------------------------" .. string.gsub(httpService:GenerateGUID(false), "-", "")
			local body = ""
			body = body .. "--" .. boundary .. "\r\n"
			body = body .. 'Content-Disposition: form-data; name="file"; filename="logs.txt"\r\n'
			body = body .. "Content-Type: text/plain\r\n\r\n"
			body = body .. logContent .. "\r\n"
			body = body .. "--" .. boundary .. "--"

			local headers = {
				["Content-Type"] = "multipart/form-data; boundary=" .. boundary
			}

			local request = {
				Url = AdminModule.Config.WebhookURL,
				Method = "POST",
				Headers = headers,
				Body = body
			}

			local embed = AdminModule.Config.Embeds.CheckHistory
			embed.description = "[Target's Roblox Profile]("..getProfileLink(id)..")"
			embed.fields[1].value = adminPlayer.Name
			embed.footer = { text = os.date("%X | %d.%m.%Y") }

			sendDiscordMessage(embed)
			local response = httpService:RequestAsync(request)

			if response.Success then
				AdminModule.Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, AdminModule.Config.Messages.CheckHistory.Success)
			else
				AdminModule.Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, AdminModule.Config.Messages.CheckHistory.Failure:gsub("{Error}", tostring(response.StatusMessage)))
			end
		else
			local embed = AdminModule.Config.Embeds.CheckHistory
			embed.description = "[Target's Roblox Profile]("..getProfileLink(id)..")"
			embed.fields[1].value = adminPlayer.Name
			embed.footer = { text = os.date("%X | %d.%m.%Y") }

			sendDiscordMessage(embed)
		end


	else
		AdminModule.Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, AdminModule.Config.Messages.CheckHistory.Failure:gsub("{Error}", tostring(banHistory)))
	end
end

-- Function to get player ID from username
function AdminModule.GetPlayerID(username, adminPlayer)
	local success, playerId = pcall(function()
		return players:GetUserIdFromNameAsync(username)
	end)

	if success then
		local embed = AdminModule.Config.Embeds.GetID
		embed.description = "[Target's Roblox Profile]("..getProfileLink(playerId)..")"
		embed.fields[1].value = username
		embed.fields[2].value = tostring(playerId)
		embed.fields[3].value = adminPlayer.Name
		embed.footer = { text = os.date("%X | %d.%m.%Y") }

		sendDiscordMessage(embed)
		AdminModule.Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, AdminModule.Config.Messages.GetID.Success:gsub("{UserID}", tostring(playerId)))
	else
		AdminModule.Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, AdminModule.Config.Messages.GetID.Failure:gsub("{Error}", tostring(error)))
	end
end

return AdminModule
