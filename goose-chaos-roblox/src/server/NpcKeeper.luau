--!strict
-- A computer-controlled groundskeeper for when nobody has that role
-- (solo testing in Studio, or a server with only geese). A real R15
-- avatar in overalls and a straw hat; walks around hedges with Nav.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Costumes = require(script.Parent.Costumes)
local Nav = require(script.Parent.Nav)
local Rig = require(script.Parent.Rig)

local NpcKeeper = {}
NpcKeeper.__index = NpcKeeper

export type Npc = typeof(setmetatable({} :: {
	body: Rig.Body,
	model: Model,
	humanoid: Humanoid,
	root: BasePart,
	nav: Nav.Nav,
	patrol: { Vector3 },
	wp: number,
	mode: string,
	raidAt: number,
	stunnedUntil: number,
	alive: boolean,
}, NpcKeeper))

function NpcKeeper.new(spawn: Vector3, patrol: { Vector3 }): Npc
	local body = Rig.build("Groundskeeper", Costumes.keeperDescription(), spawn, Config.KEEPER_WALK_SPEED)
	task.spawn(Costumes.dressKeeper, body.model)
	return setmetatable({
		body = body,
		model = body.model,
		humanoid = body.humanoid,
		root = body.root,
		nav = Nav.new(body.humanoid, body.root, 2.5),
		patrol = patrol,
		wp = 1,
		mode = "patrol",
		raidAt = os.clock() + Config.NPC_KEEPER_RAID_INTERVAL + 5,
		stunnedUntil = 0,
		alive = true,
	}, NpcKeeper)
end

function NpcKeeper.setMood(self: Npc, text: string)
	Rig.say(self.body, text, Color3.fromRGB(211, 65, 43))
end

function NpcKeeper.stun(self: Npc, seconds: number)
	self.stunnedUntil = os.clock() + seconds
	self.humanoid.WalkSpeed = 0
	self.humanoid:MoveTo(self.root.Position)
	Costumes.showStun(self.model, seconds)
end

-- One step of the brain. Returns the goose it caught (a Model) or the nest
-- it reached on a raid (a Part), or nil.
function NpcKeeper.update(self: Npc, now: number, geese: { Model }, nests: { Part }, bankedCount: number): Instance?
	Rig.animate(self.body)
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
		local root = (nearest :: Model):FindFirstChild("HumanoidRootPart") :: BasePart
		self.nav:moveTo(root.Position, now)
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
			self.nav:moveTo((best :: Part).Position, now)
			if self.nav:reached((best :: Part).Position, 7) then
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
	self.nav:moveTo(wp, now)
	if self.nav:reached(wp, 4) then
		self.wp = self.wp % #self.patrol + 1
	end
	return nil
end

function NpcKeeper.destroy(self: Npc)
	self.alive = false
	self.model:Destroy()
end

return NpcKeeper
