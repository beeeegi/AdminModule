--[[
	Written by Begi.
	Listens for commands, checks permissions, and executes the appropriate functions from AdminModule.
--]]

local AdminModule = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminModule"))
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminModule"):WaitForChild("Config"))

-- Services
local Players = game:GetService("Players")

-- Function to check if a player is an admin
local function isAdmin(player)
	return table.find(Config.AdminUserIds, player.UserId) ~= nil
end

-- Function to process commands
local function processCommand(player, message)
	-- Split the message into command and arguments
	local args = message:split(" ")
	local command = table.remove(args, 1):lower()

	if command == Config.CommandPrefix .. "ban" then
		if isAdmin(player) then
			local targetID = tonumber(args[1])
			local duration = args[2]

			local durationParsed = AdminModule.parseDuration(duration)
			local reason
			if durationParsed then
				reason = table.concat(args, " ", 3)
			else
				duration = "-1"
				reason = table.concat(args, " ", 2)
			end

			print(targetID, duration, reason)

			if targetID then
				AdminModule.BanPlayer(targetID, duration, reason, player)
			else
				Config.Remotes.CommandFeedbackEvent:FireClient(player, "Player not found.")
			end
		else
			Config.Remotes.CommandFeedbackEvent:FireClient(player, "You do not have permission to use this command.")
		end

	elseif command == Config.CommandPrefix .. "unban" then
		if isAdmin(player) then
			local targetID = tonumber(args[1])
			
			if targetID then
				AdminModule.UnbanPlayer(targetID, player)
			else
				Config.Remotes.CommandFeedbackEvent:FireClient(player, "Player not found.")
			end
		else
			Config.Remotes.CommandFeedbackEvent:FireClient(player, "You do not have permission to use this command.")
		end

	elseif command == Config.CommandPrefix .. "checkhistory" then
		if isAdmin(player) then
			local targetID = tonumber(args[1])

			if targetID then
				AdminModule.CheckPlayerHistory(targetID, player)
			else
				Config.Remotes.CommandFeedbackEvent:FireClient(player, "Player not found.")
			end
		else
			Config.Remotes.CommandFeedbackEvent:FireClient(player, "You do not have permission to use this command.")
		end

	elseif command == Config.CommandPrefix .. "getid" then
		if isAdmin(player) then
			local targetUsername = args[1]
			AdminModule.GetPlayerID(targetUsername, player)
		else
			Config.Remotes.CommandFeedbackEvent:FireClient(player, "You do not have permission to use this command.")
		end
	else
		Config.Remotes.CommandFeedbackEvent:FireClient(player, "Unknown command.")
	end
end

-- Listen for player chats
Players.PlayerAdded:Connect(function(player)
	if isAdmin(player) then
		Config.Remotes.CommandFeedbackEvent:FireClient(player, "AdminModule is activated for you.")
	end
	
	player.Chatted:Connect(function(message)	
		if message:sub(1, #Config.CommandPrefix) == Config.CommandPrefix then
			processCommand(player, message)
		end
	end)
end)

