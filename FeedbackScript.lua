--[[
	Written by Begi.
	Handles FeedbackGUI.
--]]

local rs = game:GetService("ReplicatedStorage")
local feedbackFrame = script.Parent.Feedback

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminModule"):WaitForChild("Config"))
local feedbackTxt = feedbackFrame.TextBox

Config.Remotes.CommandFeedbackEvent.OnClientEvent:Connect(function(text)
	feedbackFrame.Visible = true
	
	feedbackTxt.Text = text
end)
