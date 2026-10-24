--!strict
-- Dresses characters for their role so you can tell a goose from the
-- groundskeeper at a glance, and shows the stun effect. Works on any
-- R15 character (players and the NPC) with no uploaded assets.

local Players = game:GetService("Players")

local Costumes = {}

local WHITE = Color3.fromRGB(250, 250, 245)
local ORANGE = Color3.fromRGB(240, 138, 36)
local SKIN = Color3.fromRGB(242, 201, 160)
local OVERALLS = Color3.fromRGB(58, 74, 107)
local SHIRT = Color3.fromRGB(200, 85, 61)
local STRAW = Color3.fromRGB(217, 164, 65)

local function weldTo(part: BasePart, to: BasePart, offset: CFrame)
	part.Anchored = false
	part.CanCollide = false
	part.Massless = true
	part.CFrame = to.CFrame * offset
	local w = Instance.new("WeldConstraint")
	w.Part0 = to
	w.Part1 = part
	w.Parent = part
	part.Parent = to.Parent
end

local function removeExtras(character: Model)
	for _, c in character:GetChildren() do
		if c:IsA("Accessory") or c:IsA("Shirt") or c:IsA("Pants") or c:IsA("ShirtGraphic") or c.Name == "Costume" then
			c:Destroy()
		end
	end
	local head = character:FindFirstChild("Head")
	local face = head and head:FindFirstChildOfClass("Decal")
	if face then
		face.Transparency = 1
	end
end

local function costumePart(name: string, size: Vector3, color: Color3, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = "Costume"
	p.Size = size
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Shape = shape or Enum.PartType.Block
	p:SetAttribute("Piece", name)
	return p
end

function Costumes.gooseDescription(): HumanoidDescription
	local d = Instance.new("HumanoidDescription")
	d.HeadColor = WHITE
	d.TorsoColor = WHITE
	d.LeftArmColor = WHITE
	d.RightArmColor = WHITE
	d.LeftLegColor = ORANGE
	d.RightLegColor = ORANGE
	d.HeightScale = 0.65
	d.WidthScale = 0.9
	d.DepthScale = 1.1
	d.HeadScale = 0.9
	d.BodyTypeScale = 0
	d.ProportionScale = 0
	return d
end

function Costumes.keeperDescription(): HumanoidDescription
	local d = Instance.new("HumanoidDescription")
	d.HeadColor = SKIN
	d.TorsoColor = OVERALLS
	d.LeftArmColor = SHIRT
	d.RightArmColor = SHIRT
	d.LeftLegColor = OVERALLS
	d.RightLegColor = OVERALLS
	d.HeightScale = 1.08
	d.WidthScale = 1.1
	d.DepthScale = 1
	d.HeadScale = 1
	d.BodyTypeScale = 0.2
	d.ProportionScale = 0.3
	return d
end

-- Beak, eyes and tail feathers on an R15 character
function Costumes.dressGoose(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	removeExtras(character)
	pcall(function()
		humanoid:ApplyDescriptionAsync(Costumes.gooseDescription())
	end)
	task.wait() -- let the scale settle before welding pieces
	local head = character:FindFirstChild("Head") :: BasePart?
	local torso = character:FindFirstChild("UpperTorso") :: BasePart? or character:FindFirstChild("Torso") :: BasePart?
	if head then
		local beak = costumePart("Beak", Vector3.new(0.9, 0.45, 1.2), ORANGE)
		weldTo(beak, head, CFrame.new(0, -0.1, -0.95))
		for _, side in { -0.35, 0.35 } do
			local eye = costumePart("Eye", Vector3.new(0.22, 0.22, 0.22), Color3.fromRGB(30, 25, 20), Enum.PartType.Ball)
			weldTo(eye, head, CFrame.new(side, 0.2, -0.55))
		end
	end
	if torso then
		local tail = costumePart("Tail", Vector3.new(1.4, 0.4, 1.1), WHITE)
		weldTo(tail, torso, CFrame.new(0, -0.3, 0.9) * CFrame.Angles(math.rad(25), 0, 0))
	end
end

-- Straw hat and a moustache on an R15 character
function Costumes.dressKeeper(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	removeExtras(character)
	pcall(function()
		humanoid:ApplyDescriptionAsync(Costumes.keeperDescription())
	end)
	task.wait()
	local head = character:FindFirstChild("Head") :: BasePart?
	if head then
		local brim = costumePart("HatBrim", Vector3.new(0.25, 2.6, 2.6), STRAW, Enum.PartType.Cylinder)
		weldTo(brim, head, CFrame.new(0, 0.55, 0) * CFrame.Angles(0, 0, math.rad(90)))
		local top = costumePart("HatTop", Vector3.new(0.9, 1.5, 1.5), STRAW, Enum.PartType.Cylinder)
		weldTo(top, head, CFrame.new(0, 1.05, 0) * CFrame.Angles(0, 0, math.rad(90)))
		local band = costumePart("HatBand", Vector3.new(0.3, 1.55, 1.55), Color3.fromRGB(120, 40, 30), Enum.PartType.Cylinder)
		weldTo(band, head, CFrame.new(0, 0.75, 0) * CFrame.Angles(0, 0, math.rad(90)))
		local stache = costumePart("Moustache", Vector3.new(0.8, 0.18, 0.2), Color3.fromRGB(110, 75, 40))
		weldTo(stache, head, CFrame.new(0, -0.2, -0.6))
	end
end

-- Back to the player's own avatar between rounds
function Costumes.undress(player: Player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not humanoid then
		return
	end
	for _, c in character:GetChildren() do
		if c.Name == "Costume" then
			c:Destroy()
		end
	end
	local ok, desc = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(player.UserId)
	end)
	if not ok or not desc then
		desc = Instance.new("HumanoidDescription")
	end
	pcall(function()
		humanoid:ApplyDescriptionAsync(desc)
	end)
end

-- Stun: a yellow glow, stars overhead and a dizzy wobble
function Costumes.showStun(character: Model, seconds: number)
	local old = character:FindFirstChild("StunGlow")
	if old then
		old:Destroy()
	end
	local glow = Instance.new("Highlight")
	glow.Name = "StunGlow"
	glow.FillColor = Color3.fromRGB(255, 220, 60)
	glow.FillTransparency = 0.35
	glow.OutlineColor = Color3.fromRGB(255, 240, 150)
	glow.OutlineTransparency = 0
	glow.Parent = character

	local head = character:FindFirstChild("Head")
	local stars: BillboardGui? = nil
	if head then
		stars = Instance.new("BillboardGui")
		local s = stars :: BillboardGui
		s.Name = "StunStars"
		s.Size = UDim2.fromOffset(120, 50)
		s.StudsOffset = Vector3.new(0, 2.6, 0)
		s.AlwaysOnTop = true
		s.Parent = head
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.TextScaled = true
		t.Font = Enum.Font.FredokaOne
		t.TextColor3 = Color3.fromRGB(255, 220, 60)
		t.TextStrokeTransparency = 0
		t.Text = "✶ STUNNED ✶"
		t.Parent = s
	end
	task.delay(seconds, function()
		if glow.Parent then
			glow:Destroy()
		end
		if stars and stars.Parent then
			stars:Destroy()
		end
	end)
end

local TweenService = game:GetService("TweenService")

-- Neck stretch when honking: the head shoots forward and up, then settles
function Costumes.honkAnim(character: Model)
	local head = character:FindFirstChild("Head")
	local neck = head and head:FindFirstChild("Neck") :: Motor6D?
	if not neck then
		return
	end
	local base = neck:GetAttribute("BaseC0") :: CFrame?
	if not base then
		base = neck.C0
		neck:SetAttribute("BaseC0", base)
	end
	local b = base :: CFrame
	neck.C0 = b * CFrame.new(0, 0.5, -0.7) * CFrame.Angles(math.rad(25), 0, 0)
	TweenService:Create(neck, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { C0 = b }):Play()
end

-- Waddle: rock the hips side to side while walking. Call every frame.
function Costumes.waddle(character: Model, t: number, moving: boolean)
	local lower = character:FindFirstChild("LowerTorso")
	local root = lower and lower:FindFirstChild("Root") :: Motor6D?
	if not root then
		return
	end
	local base = root:GetAttribute("BaseC0") :: CFrame?
	if not base then
		base = root.C0
		root:SetAttribute("BaseC0", base)
	end
	local b = base :: CFrame
	if moving then
		root.C0 = b * CFrame.Angles(0, 0, math.sin(t * 11) * 0.16) * CFrame.new(0, math.abs(math.sin(t * 11)) * 0.08, 0)
	elseif root.C0 ~= b then
		root.C0 = b
	end
end

-- Feathers trail off the goose while sprinting
function Costumes.setSprintFeathers(character: Model, on: boolean)
	local torso = character:FindFirstChild("UpperTorso") :: BasePart?
	if not torso then
		return
	end
	local existing = torso:FindFirstChild("SprintFeathers")
	if on and not existing then
		local em = Instance.new("ParticleEmitter")
		em.Name = "SprintFeathers"
		em.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		em.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		em.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
		em.Transparency = NumberSequence.new(0.2, 1)
		em.Lifetime = NumberRange.new(0.4, 0.8)
		em.Speed = NumberRange.new(2, 4)
		em.SpreadAngle = Vector2.new(40, 40)
		em.Rate = 14
		em.Acceleration = Vector3.new(0, -6, 0)
		em.EmissionDirection = Enum.NormalId.Back
		em.Parent = torso
	elseif not on and existing then
		existing:Destroy()
	end
end

-- A burst of feathers and a sound ring when a goose honks
function Costumes.honkBurst(root: BasePart)
	local e = Instance.new("ParticleEmitter")
	e.Name = "HonkFeathers"
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(240, 138, 36))
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
	e.Lifetime = NumberRange.new(0.5, 0.9)
	e.Speed = NumberRange.new(10, 16)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Rate = 0
	e.LightEmission = 0.4
	e.Parent = root
	e:Emit(24)
	task.delay(1.5, function()
		e:Destroy()
	end)
end

return Costumes
