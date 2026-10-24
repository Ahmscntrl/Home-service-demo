--!strict
-- Tiny sound helper. Sounds are defined in Config.SOUNDS; play one at a
-- part (3D) or to everyone (2D through SoundService).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage.Shared.Config)

local Sfx = {}

local function make(name: string): Sound?
	local def = (Config.SOUNDS :: { [string]: { id: string, volume: number, speed: number } })[name]
	if not def then
		return nil
	end
	local s = Instance.new("Sound")
	s.Name = "Sfx_" .. name
	s.SoundId = def.id
	s.Volume = def.volume
	s.PlaybackSpeed = def.speed * (0.95 + math.random() * 0.1)
	s.RollOffMaxDistance = 90
	s.RollOffMinDistance = 8
	return s
end

-- 3D: heard near `at`
function Sfx.at(name: string, at: Instance)
	local s = make(name)
	if not s then
		return
	end
	s.Parent = at
	s:Play()
	s.Ended:Once(function()
		s:Destroy()
	end)
	task.delay(6, function()
		if s.Parent then
			s:Destroy()
		end
	end)
end

-- 2D: everyone hears it at full volume
function Sfx.all(name: string)
	local s = make(name)
	if not s then
		return
	end
	s.Parent = SoundService
	s:Play()
	s.Ended:Once(function()
		s:Destroy()
	end)
	task.delay(6, function()
		if s.Parent then
			s:Destroy()
		end
	end)
end

return Sfx
