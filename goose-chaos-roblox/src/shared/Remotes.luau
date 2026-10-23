--!strict
-- One place that creates (on the server) or finds (on the client) every
-- RemoteEvent the game uses, so names never drift between the two sides.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NAMES = {
	"Honk", -- client -> server: I want to honk
	"Grab", -- client -> server: grab / drop (also fired by ProximityPrompts)
	"Sprint", -- client -> server: boolean, sprint held
	"GameState", -- server -> client: phase, time left, roles, scores
	"Toast", -- server -> client: short message to show
	"Stamina", -- server -> client: 0..1
	"Tasks", -- server -> client: this goose's prank list with done flags
	"Shake", -- server -> client: camera shake strength
	"Pop", -- server -> client: floating score text at a position
}

local folder: Folder
if RunService:IsServer() then
	folder = Instance.new("Folder")
	folder.Name = "Remotes"
	folder.Parent = ReplicatedStorage
	for _, name in NAMES do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
else
	folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
end

local Remotes = {}
for _, name in NAMES do
	Remotes[name] = folder:WaitForChild(name) :: RemoteEvent
end

return Remotes
