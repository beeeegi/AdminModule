--[[
	Written by Begi.
	AdminModule: Roblox Admin Commands System Based On New BanAPI.
--]]

local AdminModule = {}
local Config = require(script.Config)

-- Services
local players = game:GetService("Players")
local httpService = game:GetService("HttpService")

-- Helper function to send a message to a Discord webhook
local function sendDiscordMessage(embed)    
	local data = httpService:JSONEncode({ embeds = { embed } })
	local headers = { ["Content-Type"] = "application/json" }

	local success, error = pcall(function()
		local v1 = httpService:PostAsync(Config.WebhookURL, data, Enum.HttpContentType.ApplicationJson)
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
		reason = Config.ReasonPlaceholders.NoReason
	end

	local embed = Config.Embeds.Ban
	embed.fields[1].value = tostring(id)
	embed.fields[2].value = displayDuration
	embed.fields[3].value = reason -- #reason >= 1900 and string.sub(reason,1, 1900) or reason
	embed.fields[4].value = adminPlayer.Name
	embed.footer = { text = os.date("%X | %d.%m.%Y") }
	
	local displayReason = reason..Config.ReasonPlaceholders.ReasonTemplate
	
	local config = {
		UserIds = { id },
		Duration = duration,
		DisplayReason = "\nReason: " .. displayReason,
		PrivateReason = os.date("%X | %d.%m.%Y"),
		ApplyToUniverse = Config.BanApplyToUniverse,
		ExcludeAltAccounts = Config.BanExcludeAltAccounts
	}

	local success, error = pcall(function()
		players:BanAsync(config)
	end)
	if success then
		sendDiscordMessage(embed)
		Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, Config.Messages.Ban.Success)
	else
		Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, Config.Messages.Ban.Failure:gsub("{Error}", tostring(error)))
	end
end

-- Function to unban a player
function AdminModule.UnbanPlayer(id: IntValue, adminPlayer: Player)
	local success, error = pcall(function()
		local config = {
			UserIds = { id },
			ApplyToUniverse = Config.UnbanExcludeAltAccounts
		}
		players:UnbanAsync(config)
	end)

	if success then
		local embed = Config.Embeds.Unban
		embed.fields[1].value = tostring(id)
		embed.fields[2].value = adminPlayer.Name
		embed.footer = { text = os.date("%X | %d.%m.%Y") }

		sendDiscordMessage(embed)
		Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, Config.Messages.Unban.Success)
	else
		Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, Config.Messages.Unban.Failure:gsub("{Error}", tostring(error)))
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
		
		if Config.SendTxt then
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
				Url = Config.WebhookURL,
				Method = "POST",
				Headers = headers,
				Body = body
			}

			local embed = Config.Embeds.CheckHistory
			embed.description = embed.description:gsub("{TargetID}", tostring(id))
			embed.fields[1].value = adminPlayer.Name
			embed.footer = { text = os.date("%X | %d.%m.%Y") }

			sendDiscordMessage(embed)
			local response = httpService:RequestAsync(request)
			
			if response.Success then
				Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, Config.Messages.CheckHistory.Success)
			else
				Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, Config.Messages.CheckHistory.Failure:gsub("{Error}", tostring(response.StatusMessage)))
			end
		else
			local embed = Config.Embeds.CheckHistory
			embed.description = embed.description:gsub("{TargetID}", tostring(id))
			embed.fields[1].value = adminPlayer.Name
			embed.footer = { text = os.date("%X | %d.%m.%Y") }

			sendDiscordMessage(embed)
		end

		
	else
		Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, Config.Messages.CheckHistory.Failure:gsub("{Error}", tostring(banHistory)))
	end
end


-- Function to get player ID from username
function AdminModule.GetPlayerID(username, adminPlayer)
	local success, playerId = pcall(function()
		return players:GetUserIdFromNameAsync(username)
	end)

	if success then
		local embed = Config.Embeds.GetID
		embed.fields[1].value = username
		embed.fields[2].value = tostring(playerId)
		embed.fields[3].value = adminPlayer.Name
		embed.footer = { text = os.date("%X | %d.%m.%Y") }

		sendDiscordMessage(embed)
		Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, Config.Messages.GetID.Success:gsub("{UserID}", tostring(playerId)))
	else
		Config.Remotes.CommandFeedbackEvent:FireClient(adminPlayer, Config.Messages.GetID.Failure:gsub("{Error}", tostring(error)))
	end
end

return AdminModule
