--!strict
-- A computer-controlled groundskeeper for when nobody has that role
-- (solo testing in Studio, or a server with only geese). A real R15
-- avatar in overalls and a straw hat that walks with the default run
-- animation, and uses PathfindingService so it goes around hedges.

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Costumes = require(script.Parent.Costumes)

local RUN_ANIM = "rbxassetid://507767714" -- Roblox's default R15 run
local IDLE_ANIM = "rbxassetid://507766666" -- Roblox's default R15 idle

local NpcKeeper = {}
NpcKeeper.__index = NpcKeeper

export type Npc = typeof(setmetatable({} :: {
	model: Model,
	humanoid: Humanoid,
	root: BasePart,
	patrol: { Vector3 },
	wp: number,
	mode: string,
	target: Vector3?,
	waypoints: { PathWaypoint },
	wpIndex: number,
	repathAt: number,
	raidAt: number,
	stunnedUntil: number,
	alive: boolean,
	runTrack: AnimationTrack?,
	idleTrack: AnimationTrack?,
	moodText: TextLabel?,
}, NpcKeeper))

local function fallbackRig(spawn: Vector3): Model
	-- Only used if Studio can't build an avatar (shouldn't happen, but never crash the round)
	local model = Instance.new("Model")
	model.Name = "Groundskeeper"
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.Position = spawn
	root.Parent = model
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.6, 1.6, 1.6)
	head.Color = Color3.fromRGB(242, 201, 160)
	head.CFrame = root.CFrame * CFrame.new(0, 2, 0)
	head.Parent = model
	local w = Instance.new("WeldConstraint")
	w.Part0 = root
	w.Part1 = head
	w.Parent = head
	head.Massless = true
	local h = Instance.new("Humanoid")
	h.HipHeight = 1.4
	h.Parent = model
	model.PrimaryPart = root
	return model
end

local function buildModel(spawn: Vector3): Model
	local model: Model? = nil
	pcall(function()
		model = Players:CreateHumanoidModelFromDescription(Costumes.keeperDescription(), Enum.HumanoidRigType.R15)
	end)
	local m = model or fallbackRig(spawn)
	m.Name = "Groundskeeper"
	local humanoid = m:FindFirstChildOfClass("Humanoid") :: Humanoid
	humanoid.DisplayName = "Groundskeeper"
	humanoid.WalkSpeed = Config.KEEPER_WALK_SPEED
	humanoid.UseJumpPower = true
	humanoid.JumpPower = 0
	humanoid.AutoRotate = true
	m:PivotTo(CFrame.new(spawn + Vector3.new(0, 3, 0)))
	m.Parent = workspace
	if model then
		Costumes.dressKeeper(m)
	end
	return m
end

function NpcKeeper.new(spawn: Vector3, patrol: { Vector3 }): Npc
	local model = buildModel(spawn)
	local humanoid = model:FindFirstChildOfClass("Humanoid") :: Humanoid
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart

	local self = setmetatable({
		model = model,
		humanoid = humanoid,
		root = root,
		patrol = patrol,
		wp = 1,
		mode = "patrol",
		target = nil,
		waypoints = {},
		wpIndex = 1,
		repathAt = 0,
		raidAt = os.clock() + Config.NPC_KEEPER_RAID_INTERVAL + 5,
		stunnedUntil = 0,
		alive = true,
		runTrack = nil :: AnimationTrack?,
		idleTrack = nil :: AnimationTrack?,
		moodText = nil :: TextLabel?,
	}, NpcKeeper)

	-- animations
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	pcall(function()
		local run = Instance.new("Animation")
		run.AnimationId = RUN_ANIM
		local idle = Instance.new("Animation")
		idle.AnimationId = IDLE_ANIM
		self.runTrack = animator:LoadAnimation(run)
		self.idleTrack = animator:LoadAnimation(idle)
		if self.idleTrack then
			self.idleTrack.Looped = true
			self.idleTrack:Play()
		end
		if self.runTrack then
			self.runTrack.Looped = true
		end
	end)

	-- mood tag ( ! chasing, !! raiding )
	local head = model:FindFirstChild("Head")
	if head then
		local tag = Instance.new("BillboardGui")
		tag.Name = "Mood"
		tag.Size = UDim2.fromOffset(80, 50)
		tag.StudsOffset = Vector3.new(0, 3.6, 0)
		tag.AlwaysOnTop = true
		tag.Parent = head
		local txt = Instance.new("TextLabel")
		txt.Name = "Text"
		txt.Size = UDim2.fromScale(1, 1)
		txt.BackgroundTransparency = 1
		txt.TextScaled = true
		txt.Font = Enum.Font.FredokaOne
		txt.TextColor3 = Color3.fromRGB(211, 65, 43)
		txt.TextStrokeTransparency = 0.2
		txt.Text = ""
		txt.Parent = tag
		self.moodText = txt
	end
	return self
end

function NpcKeeper.setMood(self: Npc, text: string)
	if self.moodText then
		self.moodText.Text = text
	end
end

function NpcKeeper.stun(self: Npc, seconds: number)
	self.stunnedUntil = os.clock() + seconds
	self.humanoid.WalkSpeed = 0
	self.humanoid:MoveTo(self.root.Position)
	Costumes.showStun(self.model, seconds)
end

local function setRunning(self: Npc, running: boolean)
	local run, idle = self.runTrack, self.idleTrack
	if running then
		if run and not run.IsPlaying then
			run:Play(0.15)
		end
		if idle and idle.IsPlaying then
			idle:Stop(0.15)
		end
	else
		if run and run.IsPlaying then
			run:Stop(0.15)
		end
		if idle and not idle.IsPlaying then
			idle:Play(0.15)
		end
	end
end

-- Walk toward a point, re-planning the path a few times a second
function NpcKeeper.moveTo(self: Npc, target: Vector3, now: number)
	local changed = not self.target or ((self.target :: Vector3) - target).Magnitude > 3
	if changed or now >= self.repathAt then
		self.target = target
		self.repathAt = now + 0.5
		local path = PathfindingService:CreatePath({ AgentRadius = 2.5, AgentHeight = 6, AgentCanJump = false })
		local ok = pcall(function()
			path:ComputeAsync(self.root.Position, target)
		end)
		if ok and path.Status == Enum.PathStatus.Success then
			self.waypoints = path:GetWaypoints()
			self.wpIndex = 2
		else
			self.waypoints = {}
		end
	end
	local wps = self.waypoints
	if #wps >= self.wpIndex then
		local wp = wps[self.wpIndex]
		local flat = Vector3.new(wp.Position.X, 0, wp.Position.Z) - Vector3.new(self.root.Position.X, 0, self.root.Position.Z)
		if flat.Magnitude < 2.5 then
			self.wpIndex += 1
			wp = wps[self.wpIndex]
		end
		if wp then
			self.humanoid:MoveTo(wp.Position)
			return
		end
	end
	self.humanoid:MoveTo(target)
end

-- One step of the brain. Returns the goose it caught (a Model) or the nest
-- it reached on a raid (a Part), or nil.
function NpcKeeper.update(self: Npc, now: number, geese: { Model }, nests: { Part }, bankedCount: number): Instance?
	if now < self.stunnedUntil then
		setRunning(self, false)
		return nil
	end
	self.humanoid.WalkSpeed = Config.KEEPER_WALK_SPEED + Config.KEEPER_SPEED_PER_BANKED_ITEM * bankedCount
	setRunning(self, self.humanoid.MoveDirection.Magnitude > 0.1)

	-- nearest visible goose (that isn't in its safety window)
	local nearest: Model? = nil
	local nearestD = Config.NPC_KEEPER_SIGHT
	for _, g in geese do
		local root = g:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root and g:GetAttribute("Safe") ~= true then
			local d = (root.Position - self.root.Position).Magnitude
			if d < nearestD then
				nearest = g
				nearestD = d
			end
		end
	end

	if nearest then
		self.mode = "chase"
		self:setMood("!")
		local root = (nearest :: Model):FindFirstChild("HumanoidRootPart") :: BasePart
		self:moveTo(root.Position, now)
		if nearestD < Config.CATCH_DISTANCE then
			return nearest
		end
		return nil
	end

	-- raid the fullest nest every so often
	if now >= self.raidAt then
		local best: Part? = nil
		local bestN = 0
		for _, n in nests do
			local v = n:GetAttribute("Value") :: number? or 0 -- Main keeps this up to date
			if v > bestN then
				best = n
				bestN = v
			end
		end
		if best then
			self.mode = "raid"
			self:setMood("!!")
			self:moveTo((best :: Part).Position, now)
			if ((best :: Part).Position - self.root.Position).Magnitude < 7 then
				self.raidAt = now + Config.NPC_KEEPER_RAID_INTERVAL
				return best
			end
			return nil
		end
		self.raidAt = now + 5
	end

	self.mode = "patrol"
	self:setMood("")
	local wp = self.patrol[self.wp]
	self:moveTo(wp, now)
	if (Vector3.new(wp.X, 0, wp.Z) - Vector3.new(self.root.Position.X, 0, self.root.Position.Z)).Magnitude < 4 then
		self.wp = self.wp % #self.patrol + 1
	end
	return nil
end

function NpcKeeper.destroy(self: Npc)
	self.alive = false
	self.model:Destroy()
end

return NpcKeeper
