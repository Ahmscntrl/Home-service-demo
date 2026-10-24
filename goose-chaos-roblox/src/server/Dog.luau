--!strict
-- The groundskeeper's dog. Let out halfway through the round. Fast,
-- chases the nearest goose it can see, and knocks the item out of its
-- beak. A honk stuns it for a couple of seconds.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Nav = require(script.Parent.Nav)
local Costumes = require(script.Parent.Costumes)

local Dog = {}
Dog.__index = Dog

export type Dog = typeof(setmetatable({} :: {
	model: Model,
	humanoid: Humanoid,
	root: BasePart,
	nav: Nav.Nav,
	stunnedUntil: number,
	sniff: Vector3?,
	sniffT: number,
	home: Vector3,
	legs: { BasePart },
	t: number,
	label: TextLabel?,
}, Dog))

local BROWN = Color3.fromRGB(150, 100, 55)
local DARK = Color3.fromRGB(95, 60, 32)

local function p(model: Model, name: string, size: Vector3, color: Color3, shape: Enum.PartType?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Shape = shape or Enum.PartType.Block
	part.CanCollide = false
	part.Massless = true
	part.Parent = model
	return part
end

local function weld(a: BasePart, b: BasePart, offset: CFrame)
	b.CFrame = a.CFrame * offset
	local w = Instance.new("WeldConstraint")
	w.Part0 = a
	w.Part1 = b
	w.Parent = b
end

local function build(spawn: Vector3): (Model, Humanoid, BasePart, { BasePart }, TextLabel)
	local model = Instance.new("Model")
	model.Name = "Dog"
	local root = p(model, "HumanoidRootPart", Vector3.new(2, 1.6, 3.4), BROWN)
	root.Transparency = 1
	root.CFrame = CFrame.new(spawn + Vector3.new(0, 2, 0))

	local body = p(model, "Body", Vector3.new(1.8, 1.5, 3.2), BROWN)
	weld(root, body, CFrame.new(0, 0, 0))
	local head = p(model, "Head", Vector3.new(1.5, 1.3, 1.5), BROWN)
	weld(root, head, CFrame.new(0, 0.9, -1.9))
	local snout = p(model, "Snout", Vector3.new(0.8, 0.6, 0.9), DARK)
	weld(root, snout, CFrame.new(0, 0.6, -2.8))
	local nose = p(model, "Nose", Vector3.new(0.35, 0.35, 0.35), Color3.fromRGB(30, 25, 20), Enum.PartType.Ball)
	weld(root, nose, CFrame.new(0, 0.7, -3.25))
	for _, side in { -0.45, 0.45 } do
		local eye = p(model, "Eye", Vector3.new(0.25, 0.25, 0.25), Color3.fromRGB(20, 20, 20), Enum.PartType.Ball)
		weld(root, eye, CFrame.new(side, 1.1, -2.5))
		local ear = p(model, "Ear", Vector3.new(0.4, 1.0, 0.7), DARK)
		weld(root, ear, CFrame.new(side * 1.8, 1.0, -1.7) * CFrame.Angles(0, 0, side * 0.5))
	end
	local tail = p(model, "Tail", Vector3.new(0.35, 0.35, 1.4), DARK)
	weld(root, tail, CFrame.new(0, 0.7, 1.9) * CFrame.Angles(math.rad(-40), 0, 0))
	local legs: { BasePart } = {}
	for _, lz in { -1.1, 1.1 } do
		for _, lx in { -0.6, 0.6 } do
			local leg = p(model, "Leg", Vector3.new(0.5, 1.3, 0.5), DARK)
			weld(root, leg, CFrame.new(lx, -1.1, lz))
			table.insert(legs, leg)
		end
	end
	local collar = p(model, "Collar", Vector3.new(0.3, 1.7, 1.7), Color3.fromRGB(200, 40, 40), Enum.PartType.Cylinder)
	weld(root, collar, CFrame.new(0, 0.6, -1.1) * CFrame.Angles(0, math.rad(90), 0))

	local humanoid = Instance.new("Humanoid")
	humanoid.HipHeight = 1.3
	humanoid.WalkSpeed = Config.DOG_SPEED
	humanoid.UseJumpPower = true
	humanoid.JumpPower = 0
	humanoid.AutoRotate = true
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.DisplayName = "Biscuit"
	humanoid.Parent = model

	local tag = Instance.new("BillboardGui")
	tag.Name = "Say"
	tag.Size = UDim2.fromOffset(100, 40)
	tag.StudsOffset = Vector3.new(0, 2.4, 0)
	tag.AlwaysOnTop = true
	tag.Parent = head
	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.fromScale(1, 1)
	txt.BackgroundTransparency = 1
	txt.TextScaled = true
	txt.Font = Enum.Font.FredokaOne
	txt.TextColor3 = Color3.fromRGB(255, 255, 255)
	txt.TextStrokeTransparency = 0.15
	txt.Text = ""
	txt.Parent = tag

	model.PrimaryPart = root
	model.Parent = workspace
	return model, humanoid, root, legs, txt
end

function Dog.new(spawn: Vector3): Dog
	local model, humanoid, root, legs, label = build(spawn)
	return setmetatable({
		model = model,
		humanoid = humanoid,
		root = root,
		nav = Nav.new(humanoid, root, 1.5),
		stunnedUntil = 0,
		sniff = nil,
		sniffT = 0,
		home = spawn,
		legs = legs,
		t = 0,
		label = label,
	}, Dog)
end

function Dog.stun(self: Dog, seconds: number)
	self.stunnedUntil = os.clock() + seconds
	self.humanoid.WalkSpeed = 0
	self.humanoid:MoveTo(self.root.Position)
	if self.label then
		self.label.Text = "yipe!"
	end
	Costumes.showStun(self.model, seconds)
end

-- Returns the goose it caught, if any. `anchor` is where it sniffs around
-- when nobody is in sight (the groundskeeper's position).
function Dog.update(self: Dog, now: number, dt: number, geese: { Model }, anchor: Vector3): Model?
	if now < self.stunnedUntil then
		return nil
	end
	self.humanoid.WalkSpeed = Config.DOG_SPEED
	-- trot: swing the legs while moving
	if self.humanoid.MoveDirection.Magnitude > 0.1 then
		self.t += dt * 14
		for i, leg in self.legs do
			local phase = if i % 2 == 0 then self.t else self.t + math.pi
			local w = leg:FindFirstChildOfClass("WeldConstraint")
			if w then
				w.Enabled = false
				leg.CFrame = self.root.CFrame * CFrame.new(if i <= 2 then (if i == 1 then -0.6 else 0.6) else (if i == 3 then -0.6 else 0.6), -1.1, if i <= 2 then -1.1 else 1.1) * CFrame.Angles(math.sin(phase) * 0.6, 0, 0)
				w.Enabled = true
			end
		end
	end

	local nearest: Model? = nil
	local nearestD = Config.DOG_SIGHT
	for _, g in geese do
		local root = g:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root and g:GetAttribute("Safe") ~= true and g:GetAttribute("Home") ~= true then
			local d = (root.Position - self.root.Position).Magnitude
			if d < nearestD then
				nearest = g
				nearestD = d
			end
		end
	end
	if nearest then
		if self.label then
			self.label.Text = "WOOF!"
		end
		local root = (nearest :: Model):FindFirstChild("HumanoidRootPart") :: BasePart
		self.nav:moveTo(root.Position, now)
		if nearestD < Config.CATCH_DISTANCE then
			return nearest
		end
		return nil
	end
	if self.label then
		self.label.Text = ""
	end
	self.sniffT -= dt
	if not self.sniff or self.sniffT <= 0 or self.nav:reached(self.sniff :: Vector3, 3) then
		self.sniff = anchor + Vector3.new((math.random() - 0.5) * 60, 0, (math.random() - 0.5) * 60)
		self.sniffT = 3
	end
	self.humanoid.WalkSpeed = Config.DOG_SPEED * 0.5
	self.nav:moveTo(self.sniff :: Vector3, now)
	return nil
end

function Dog.destroy(self: Dog)
	self.model:Destroy()
end

return Dog
