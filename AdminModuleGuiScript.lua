--[[
	Written by Begi.
	Handles GUI for AdminModule.
--]]

local uis = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local AdminModule = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminModule"))
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminModule"):WaitForChild("Config"))

local ToggleKey = Config.ToggleKey
local AdminGui = script.Parent.AdminGui

local buttonsFrame = AdminGui.Buttons
local banFrame = AdminGui.BanFrame
local TargetInput = AdminGui.TargetInputFrame

local banBtn = buttonsFrame.ban
local unbanBtn = buttonsFrame.unban
local idBtn = buttonsFrame.id
local historyBtn = buttonsFrame.history

local id
local duration
local reason

-- Function to check the player's permission
local function isAdmin()
	return table.find(Config.AdminUserIds, player.UserId) ~= nil
end

-- Handle GUI toggle
uis.InputBegan:Connect(function(input, gpe)
	if not gpe and isAdmin() and input.KeyCode == ToggleKey then
		AdminGui.Visible = not AdminGui.Visible
	end
end)

-- Handle command button clicks
banBtn.MouseButton1Click:Connect(function()
	buttonsFrame.Visible = false
	banFrame.Visible = true
end)
unbanBtn.MouseButton1Click:Connect(function()
	buttonsFrame.Visible = false
	TargetInput.Visible = true
	
	TargetInput.TextBox.PlaceholderText = "UserID"
	TargetInput.SubmitUnban.Visible = true
	TargetInput.SubmitGetID.Visible = false
	TargetInput.SubmitHistory.Visible = false
end)
idBtn.MouseButton1Click:Connect(function()
	buttonsFrame.Visible = false
	TargetInput.Visible = true
	
	TargetInput.TextBox.PlaceholderText = "Username"
	TargetInput.SubmitGetID.Visible = true
	TargetInput.SubmitUnban.Visible = false
	TargetInput.SubmitHistory.Visible = false
end)
historyBtn.MouseButton1Click:Connect(function()
	buttonsFrame.Visible = false
	TargetInput.Visible = true
	
	TargetInput.TextBox.PlaceholderText = "UserID"
	TargetInput.SubmitHistory.Visible = true
	TargetInput.SubmitUnban.Visible = false
	TargetInput.SubmitGetID.Visible = false
end)

-- Handle GetId command
TargetInput.SubmitGetID.MouseButton1Click:Connect(function()
	local username = tostring(TargetInput.TextBox.Text)
	Config.Remotes.CommandsFromUI:FireServer("GetID", username)
	TargetInput.Visible = false
	buttonsFrame.Visible = true
	TargetInput.TextBox.Text = ""
end)

-- Handle Unban command
TargetInput.SubmitUnban.MouseButton1Click:Connect(function()
	local id = tonumber(TargetInput.TextBox.Text)
	Config.Remotes.CommandsFromUI:FireServer("Unban", id)
	TargetInput.Visible = false
	buttonsFrame.Visible = true
	TargetInput.TextBox.Text = ""
end)

-- Handle CheckHistory command
TargetInput.SubmitHistory.MouseButton1Click:Connect(function()
	local id = tonumber(TargetInput.TextBox.Text)
	Config.Remotes.CommandsFromUI:FireServer("CheckHistory", id)
	TargetInput.Visible = false
	buttonsFrame.Visible = true
	TargetInput.TextBox.Text = ""
end)

-- Handle Ban command
banFrame.Submit.MouseButton1Click:Connect(function()
	local id = tonumber(banFrame.IdInput.Text)
	if not id then return end
	local duration = tostring(banFrame.DurationInput.Text)
	if not duration then
		duration = " "
	end
	local reason = tostring(banFrame.ReasonInput.Text)
	if not reason then
		reason = " "
	end
	Config.Remotes.BanFromUI:FireServer(id, duration, reason)
	banFrame.Visible = false
	buttonsFrame.Visible = true
	banFrame.IdInput.Text = ""
	banFrame.DurationInput.Text = ""
	banFrame.ReasonInput.Text = ""
end)


