--!strict
-- Builds animated R15 NPC bodies from a HumanoidDescription, with the
-- default idle/run animations, so villagers and the groundskeeper all
-- look like real characters without any uploaded assets.

local Players = game:GetService("Players")

local Rig = {}

local RUN_ANIM = "rbxassetid://507767714" -- Roblox's default R15 run
local IDLE_ANIM = "rbxassetid://507766666" -- Roblox's default R15 idle

export type Body = {
	model: Model,
	humanoid: Humanoid,
	root: BasePart,
	runTrack: AnimationTrack?,
	idleTrack: AnimationTrack?,
	label: TextLabel?,
}

local function fallbackRig(): Model
	local model = Instance.new("Model")
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.Parent = model
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.6, 1.6, 1.6)
	head.Color = Color3.fromRGB(242, 201, 160)
	head.CFrame = root.CFrame * CFrame.new(0, 2, 0)
	head.Massless = true
	head.Parent = model
	local w = Instance.new("WeldConstraint")
	w.Part0 = root
	w.Part1 = head
	w.Parent = head
	local h = Instance.new("Humanoid")
	h.HipHeight = 1.4
	h.Parent = model
	model.PrimaryPart = root
	return model
end

function Rig.build(name: string, description: HumanoidDescription, spawn: Vector3, walkSpeed: number): Body
	local model: Model? = nil
	pcall(function()
		model = Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
	end)
	local m = model or fallbackRig()
	m.Name = name
	local humanoid = m:FindFirstChildOfClass("Humanoid") :: Humanoid
	humanoid.DisplayName = name
	humanoid.WalkSpeed = walkSpeed
	humanoid.UseJumpPower = true
	humanoid.JumpPower = 0
	humanoid.AutoRotate = true
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.NameDisplayDistance = 0
	m:PivotTo(CFrame.new(spawn + Vector3.new(0, 3.5, 0)))
	m.Parent = workspace

	local body: Body = { model = m, humanoid = humanoid, root = m:FindFirstChild("HumanoidRootPart") :: BasePart, runTrack = nil, idleTrack = nil, label = nil }

	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	pcall(function()
		local run = Instance.new("Animation")
		run.AnimationId = RUN_ANIM
		local idle = Instance.new("Animation")
		idle.AnimationId = IDLE_ANIM
		local rt = animator:LoadAnimation(run)
		rt.Looped = true
		local it = animator:LoadAnimation(idle)
		it.Looped = true
		it:Play()
		body.runTrack = rt
		body.idleTrack = it
	end)

	-- speech / mood tag above the head
	local head = m:FindFirstChild("Head")
	if head then
		local tag = Instance.new("BillboardGui")
		tag.Name = "Say"
		tag.Size = UDim2.fromOffset(160, 50)
		tag.StudsOffset = Vector3.new(0, 3.4, 0)
		tag.AlwaysOnTop = true
		tag.MaxDistance = 90
		tag.Parent = head
		local txt = Instance.new("TextLabel")
		txt.Name = "Text"
		txt.Size = UDim2.fromScale(1, 1)
		txt.BackgroundTransparency = 1
		txt.TextScaled = true
		txt.Font = Enum.Font.FredokaOne
		txt.TextColor3 = Color3.fromRGB(255, 255, 255)
		txt.TextStrokeTransparency = 0.15
		txt.Text = ""
		txt.Parent = tag
		body.label = txt
	end
	return body
end

-- Swap idle/run based on whether the humanoid is moving
function Rig.animate(body: Body)
	local moving = body.humanoid.MoveDirection.Magnitude > 0.1 and body.humanoid.WalkSpeed > 0
	local run, idle = body.runTrack, body.idleTrack
	if moving then
		if run and not run.IsPlaying then
			run:Play(0.15)
		end
		if idle and idle.IsPlaying then
			idle:Stop(0.15)
		end
		if run then
			run:AdjustSpeed(body.humanoid.WalkSpeed / 16)
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

function Rig.say(body: Body, text: string, color: Color3?)
	if body.label then
		body.label.Text = text
		body.label.TextColor3 = color or Color3.new(1, 1, 1)
	end
end

return Rig
