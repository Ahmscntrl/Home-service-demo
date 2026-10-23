--!strict
-- Goose controls. Keyboard: Shift = sprint, Space = honk, Q = drop.
-- (E on an item is handled by the item's ProximityPrompt.)
-- Jumping is off for everyone (set by the server), so Space is free for honking.
-- On touch screens ContextActionService adds on-screen buttons for these.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer

local function isGoose(): boolean
	return player:GetAttribute("Role") == "goose"
end

local function honk(_name: string, state: Enum.UserInputState)
	if state == Enum.UserInputState.Begin and isGoose() then
		Remotes.Honk:FireServer()
	end
	return Enum.ContextActionResult.Sink
end

local function drop(_name: string, state: Enum.UserInputState)
	if state == Enum.UserInputState.Begin and isGoose() then
		Remotes.Grab:FireServer()
	end
	return Enum.ContextActionResult.Pass
end

local function sprint(_name: string, state: Enum.UserInputState)
	if state == Enum.UserInputState.Begin then
		Remotes.Sprint:FireServer(true)
	elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
		Remotes.Sprint:FireServer(false)
	end
	return Enum.ContextActionResult.Pass
end

local touch = UserInputService.TouchEnabled

ContextActionService:BindAction("GooseHonk", honk, touch, Enum.KeyCode.Space, Enum.KeyCode.ButtonX)
ContextActionService:BindAction("GooseDrop", drop, touch, Enum.KeyCode.Q, Enum.KeyCode.ButtonB)
ContextActionService:BindAction("GooseSprint", sprint, touch, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL2)

if touch then
	ContextActionService:SetTitle("GooseHonk", "HONK")
	ContextActionService:SetPosition("GooseHonk", UDim2.new(0.72, 0, 0.2, 0))
	ContextActionService:SetTitle("GooseDrop", "DROP")
	ContextActionService:SetPosition("GooseDrop", UDim2.new(0.5, 0, 0.35, 0))
	ContextActionService:SetTitle("GooseSprint", "RUN")
	ContextActionService:SetPosition("GooseSprint", UDim2.new(0.72, 0, 0.5, 0))
end
