--!strict
-- A computer-controlled groundskeeper for when nobody has that role
-- (solo testing in Studio, or a server with only geese). Uses Roblox's
-- PathfindingService so it walks around hedges and houses, like the A*
-- in the web prototype.

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

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
	path: Path?,
	waypoints: { PathWaypoint },
	wpIndex: number,
	repathAt: number,
	raidAt: number,
	stunnedUntil: number,
	alive: boolean,
}, NpcKeeper))

local function buildModel(spawn: Vector3): (Model, Humanoid, BasePart)
	local model = Instance.new("Model")
	model.Name = "Groundskeeper"

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.CanCollide = false
	root.Position = spawn
	root.Parent = model

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2.4, 2.4, 1.2)
	torso.Color = Color3.fromRGB(58, 74, 107)
	torso.Parent = model
	local w = Instance.new("WeldConstraint")
	w.Part0 = root
	w.Part1 = torso
	w.Parent = torso
	torso.CFrame = root.CFrame

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.6, 1.6, 1.6)
	head.Color = Color3.fromRGB(242, 201, 160)
	head.CFrame = root.CFrame * CFrame.new(0, 2, 0)
	head.Parent = model
	local w2 = Instance.new("WeldConstraint")
	w2.Part0 = root
	w2.Part1 = head
	w2.Parent = head

	local hat = Instance.new("Part")
	hat.Name = "Hat"
	hat.Shape = Enum.PartType.Cylinder
	hat.Size = Vector3.new(0.3, 2.6, 2.6)
	hat.Color = Color3.fromRGB(217, 164, 65)
	hat.CFrame = root.CFrame * CFrame.new(0, 2.9, 0) * CFrame.Angles(0, 0, math.rad(90))
	hat.Parent = model
	local w3 = Instance.new("WeldConstraint")
	w3.Part0 = root
	w3.Part1 = hat
	w3.Parent = hat

	for _, p in model:GetChildren() do
		if p:IsA("BasePart") then
			p.Anchored = false
			p.Massless = p ~= root
		end
	end

	local humanoid = Instance.new("Humanoid")
	humanoid.WalkSpeed = Config.KEEPER_WALK_SPEED
	humanoid.HipHeight = 1.4
	humanoid.AutoRotate = true
	humanoid.Parent = model

	local tag = Instance.new("BillboardGui")
	tag.Name = "Mood"
	tag.Size = UDim2.fromOffset(60, 40)
	tag.StudsOffset = Vector3.new(0, 4.2, 0)
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

	model.PrimaryPart = root
	model.Parent = workspace
	return model, humanoid, root
end

function NpcKeeper.new(spawn: Vector3, patrol: { Vector3 }): Npc
	local model, humanoid, root = buildModel(spawn)
	local self = setmetatable({
		model = model,
		humanoid = humanoid,
		root = root,
		patrol = patrol,
		wp = 1,
		mode = "patrol",
		target = nil,
		path = nil,
		waypoints = {},
		wpIndex = 1,
		repathAt = 0,
		raidAt = os.clock() + Config.NPC_KEEPER_RAID_INTERVAL + 5,
		stunnedUntil = 0,
		alive = true,
	}, NpcKeeper)
	return self
end

function NpcKeeper.setMood(self: Npc, text: string)
	local head = self.model:FindFirstChild("Head")
	local label = head and head:FindFirstChild("Mood")
	local t = label and label:FindFirstChild("Text")
	if t and t:IsA("TextLabel") then
		t.Text = text
	end
end

function NpcKeeper.stun(self: Npc, seconds: number)
	self.stunnedUntil = os.clock() + seconds
	self.humanoid.WalkSpeed = 0
	self:setMood("✶✶")
end

-- Walk toward a point, re-planning the path a few times a second
function NpcKeeper.moveTo(self: Npc, target: Vector3, now: number)
	local changed = not self.target or (self.target - target).Magnitude > 3
	if changed or now >= self.repathAt then
		self.target = target
		self.repathAt = now + 0.5
		local path = PathfindingService:CreatePath({ AgentRadius = 2.5, AgentHeight = 5, AgentCanJump = false })
		local ok = pcall(function()
			path:ComputeAsync(self.root.Position, target)
		end)
		if ok and path.Status == Enum.PathStatus.Success then
			self.path = path
			self.waypoints = path:GetWaypoints()
			self.wpIndex = 2
		else
			self.waypoints = {}
		end
	end
	local wps = self.waypoints
	if #wps >= self.wpIndex then
		local wp = wps[self.wpIndex]
		if (Vector3.new(wp.Position.X, 0, wp.Position.Z) - Vector3.new(self.root.Position.X, 0, self.root.Position.Z)).Magnitude < 2.5 then
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

-- One step of the brain. Returns the character it caught, if any.
function NpcKeeper.update(self: Npc, now: number, geese: { Model }, nests: { Part }, bankedCount: number): Model?
	if now < self.stunnedUntil then
		return nil
	end
	self.humanoid.WalkSpeed = Config.KEEPER_WALK_SPEED + Config.KEEPER_SPEED_PER_BANKED_ITEM * bankedCount

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
		local root = nearest:FindFirstChild("HumanoidRootPart") :: BasePart
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
			self:moveTo(best.Position, now)
			if (best.Position - self.root.Position).Magnitude < 6 then
				self.raidAt = now + Config.NPC_KEEPER_RAID_INTERVAL
				return best :: any -- caller treats a Part result as "raid this nest"
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
