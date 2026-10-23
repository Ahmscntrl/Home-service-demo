--!strict
-- Goose Chaos: round loop, roles, honking, catching, scoring.
--
-- Phases: intermission -> round -> results -> (repeat)
-- Roles:  one Groundskeeper (a player, or an NPC when nobody is free),
--         everyone else is a Goose with a nest.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local MapBuilder = require(script.Parent.MapBuilder)
local Items = require(script.Parent.Items)
local NpcKeeper = require(script.Parent.NpcKeeper)

local map = MapBuilder.build()
Items.init(map.folder)
local nestParts: { Part } = {}
local nestFolder = map.folder:FindFirstChild("Nests") :: Folder
for i = 1, #map.nestSpots do
	table.insert(nestParts, nestFolder:FindFirstChild("Nest" .. i) :: Part)
end

-- ---------- Sounds ----------
local honkSound = Instance.new("Sound")
honkSound.Name = "Honk"
honkSound.SoundId = "rbxassetid://9114898499" -- replace with your own honk
honkSound.Volume = 1.5
honkSound.RollOffMaxDistance = 80

-- ---------- State ----------
type GooseData = {
	player: Player,
	nest: Part,
	stamina: number,
	sprinting: boolean,
	honkReadyAt: number,
	safeUntil: number,
	honksLanded: number,
	stealReadyAt: number,
}
type Phase = "intermission" | "round" | "results"

local phase: Phase = "intermission"
local phaseEndsAt = os.clock() + Config.INTERMISSION_SECONDS
local geese: { [Player]: GooseData } = {}
local keeperPlayer: Player? = nil
local npc: NpcKeeper.Npc? = nil
local keeperScore = { catches = 0, returned = 0 }
local keeperHistory: { [Player]: number } = {} -- how many times each player has been keeper

local function toast(player: Player?, text: string)
	if player then
		Remotes.Toast:FireClient(player, text)
	else
		Remotes.Toast:FireAllClients(text)
	end
end

local function characterOf(player: Player): Model?
	local c = player.Character
	if c and c.Parent and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChildOfClass("Humanoid") then
		return c
	end
	return nil
end

local function keeperCharacter(): Model?
	if npc then
		return npc.model
	end
	if keeperPlayer then
		return characterOf(keeperPlayer)
	end
	return nil
end

local function gooseScore(data: GooseData): number
	return Items.nestValue(data.nest) + data.honksLanded * Config.POINTS_PER_HONK_LANDED
end

local function updateNestLabels()
	for _, nest in nestParts do
		local label = nest:FindFirstChild("Label")
		local text = label and label:FindFirstChild("Text") :: TextLabel?
		local owner = nest:GetAttribute("Owner") :: string
		local value = Items.nestValue(nest)
		nest:SetAttribute("Value", value)
		if not text then
			continue
		end
		if owner == "" then
			text.Text = "Empty nest"
		else
			text.Text = owner .. "'s nest  •  " .. value
		end
	end
end

-- ---------- Broadcasting ----------
local function broadcast()
	local scores: { { name: string, role: string, score: number } } = {}
	for player, data in geese do
		table.insert(scores, { name = player.DisplayName, role = "goose", score = gooseScore(data) })
	end
	local keeperName = if npc then "Groundskeeper (NPC)" elseif keeperPlayer then keeperPlayer.DisplayName else "—"
	table.insert(scores, { name = keeperName, role = "keeper", score = keeperScore.catches * Config.POINTS_PER_CATCH + keeperScore.returned * Config.POINTS_PER_ITEM_RETURNED })
	table.sort(scores, function(a, b)
		return a.score > b.score
	end)
	local roles = {}
	for player in geese do
		roles[player.Name] = "goose"
	end
	if keeperPlayer then
		roles[keeperPlayer.Name] = "keeper"
	end
	Remotes.GameState:FireAllClients({
		phase = phase,
		timeLeft = math.max(0, phaseEndsAt - os.clock()),
		roles = roles,
		scores = scores,
	})
end

-- ---------- Roles ----------
local function setSpeed(player: Player, speed: number)
	local c = characterOf(player)
	local h = c and c:FindFirstChildOfClass("Humanoid")
	if h then
		h.WalkSpeed = speed
	end
end

local function teleport(player: Player, position: Vector3)
	local c = characterOf(player)
	if c then
		c:PivotTo(CFrame.new(position + Vector3.new(0, 4, 0)))
	end
end

local function assignRoles()
	geese = {}
	keeperPlayer = nil
	if npc then
		npc:destroy()
		npc = nil
	end
	keeperScore = { catches = 0, returned = 0 }
	for _, nest in nestParts do
		nest:SetAttribute("Owner", "")
	end

	local players = Players:GetPlayers()
	-- Keeper: the player who has been keeper the fewest times (random among ties).
	-- With one player, they're a goose and the NPC keeps the grounds.
	if #players >= 2 then
		local fewest = math.huge
		local candidates = {}
		for _, p in players do
			local n = keeperHistory[p] or 0
			if n < fewest then
				fewest = n
				candidates = { p }
			elseif n == fewest then
				table.insert(candidates, p)
			end
		end
		keeperPlayer = candidates[math.random(#candidates)]
		keeperHistory[keeperPlayer :: Player] = fewest + 1
	end

	local nestIndex = 1
	for _, p in players do
		if p == keeperPlayer then
			p:SetAttribute("Role", "keeper")
			setSpeed(p, Config.KEEPER_WALK_SPEED)
			teleport(p, map.keeperSpawn)
			toast(p, "You're the GROUNDSKEEPER. Catch the geese and take your things back!")
		elseif nestIndex <= #nestParts then
			local nest = nestParts[nestIndex]
			nestIndex += 1
			nest:SetAttribute("Owner", p.DisplayName)
			geese[p] = { player = p, nest = nest, stamina = 1, sprinting = false, honkReadyAt = 0, safeUntil = 0, honksLanded = 0, stealReadyAt = 0 }
			p:SetAttribute("Role", "goose")
			setSpeed(p, Config.GOOSE_WALK_SPEED)
			teleport(p, nest.Position)
			toast(p, "You're a GOOSE. Steal things and bring them to your nest. HONK to stun him.")
		else
			p:SetAttribute("Role", "spectator")
			toast(p, "Nests are full this round. You'll play next round.")
		end
	end

	if not keeperPlayer then
		npc = NpcKeeper.new(map.keeperSpawn, map.patrol)
		toast(nil, "Nobody's the groundskeeper, so the computer keeps the grounds this round.")
	end
	updateNestLabels()
end

-- ---------- Catching ----------
local function setSafe(player: Player, seconds: number)
	local data = geese[player]
	local c = characterOf(player)
	if not data or not c then
		return
	end
	data.safeUntil = os.clock() + seconds
	c:SetAttribute("Safe", true)
	local ff = Instance.new("ForceField")
	ff.Name = "SafeField"
	ff.Parent = c
	task.delay(seconds, function()
		if ff.Parent then
			ff:Destroy()
		end
		if c.Parent then
			c:SetAttribute("Safe", false)
		end
	end)
end

local function catchGoose(player: Player)
	local data = geese[player]
	local c = characterOf(player)
	if not data or not c then
		return
	end
	keeperScore.catches += 1
	local item = Items.carriedBy(c)
	if item then
		Items.returnHome(item)
		keeperScore.returned += 1
		toast(player, "Caught! He took the " .. item.def.name:lower() .. " back.")
	else
		toast(player, "Shooed away!")
	end
	if keeperPlayer then
		toast(keeperPlayer, "You caught " .. player.DisplayName .. "!")
	end
	teleport(player, data.nest.Position)
	setSafe(player, Config.SAFE_SECONDS_AFTER_CATCH)
end

local function raidNest(nest: Part)
	local item = Items.mostValuableInNest(nest)
	if not item then
		return
	end
	Items.returnHome(item)
	keeperScore.returned += 1
	local owner = nest:GetAttribute("Owner")
	toast(nil, "The groundskeeper took the " .. item.def.name:lower() .. " back from " .. tostring(owner) .. "'s nest!")
	updateNestLabels()
end

-- ---------- Honk ----------
Remotes.Honk.OnServerEvent:Connect(function(player)
	if phase ~= "round" then
		return
	end
	local data = geese[player]
	local c = characterOf(player)
	if not data or not c then
		return
	end
	local now = os.clock()
	if now < data.honkReadyAt then
		return
	end
	data.honkReadyAt = now + Config.HONK_COOLDOWN

	local root = c:FindFirstChild("HumanoidRootPart") :: BasePart
	local s = honkSound:Clone()
	s.Parent = root
	s:Play()
	task.delay(2, function()
		s:Destroy()
	end)

	local kc = keeperCharacter()
	local kroot = kc and kc:FindFirstChild("HumanoidRootPart") :: BasePart?
	if kroot and (kroot.Position - root.Position).Magnitude <= Config.HONK_RANGE then
		data.honksLanded += 1
		if npc then
			npc:stun(Config.HONK_STUN_SECONDS)
		elseif keeperPlayer then
			local h = kc and kc:FindFirstChildOfClass("Humanoid")
			if h then
				h.WalkSpeed = 0
				h.JumpPower = 0
				toast(keeperPlayer, "HONK! You're stunned.")
				task.delay(Config.HONK_STUN_SECONDS, function()
					if h.Parent and keeperPlayer and h.Parent == characterOf(keeperPlayer) then
						h.WalkSpeed = Config.KEEPER_WALK_SPEED
						h.JumpPower = 35
					end
				end)
			end
		end
		toast(player, "HONK! He hates that.")
	end
end)

-- ---------- Sprint ----------
Remotes.Sprint.OnServerEvent:Connect(function(player, held)
	local data = geese[player]
	if data then
		data.sprinting = held == true
	end
end)

-- ---------- Grab / drop / steal (via ProximityPrompts on items) ----------
Items.onGrab = function(player, item)
	if phase ~= "round" then
		return
	end
	local c = characterOf(player)
	if not c then
		return
	end
	local role = player:GetAttribute("Role")
	if role == "keeper" then
		-- the groundskeeper tidies: any item he touches goes home
		if item.state ~= "carried" then
			Items.returnHome(item)
			keeperScore.returned += 1
			toast(player, "Put the " .. item.def.name:lower() .. " back.")
			updateNestLabels()
		end
		return
	end
	local data = geese[player]
	if not data then
		return
	end
	if Items.carriedBy(c) then
		toast(player, "You're already carrying something. Drop it first (E).")
		return
	end
	if item.state == "banked" then
		if item.nest == data.nest then
			toast(player, "That's already in your nest.")
			return
		end
		local now = os.clock()
		if now < data.stealReadyAt then
			return
		end
		data.stealReadyAt = now + Config.STEAL_FROM_NEST_COOLDOWN
		local victim = item.nest and item.nest:GetAttribute("Owner")
		toast(nil, player.DisplayName .. " stole the " .. item.def.name:lower() .. " from " .. tostring(victim) .. "'s nest!")
	end
	Items.pickUp(item, c)
	updateNestLabels()
end

-- Drop what you're carrying (E with nothing nearby, or the Drop button)
Remotes.Grab.OnServerEvent:Connect(function(player)
	if phase ~= "round" then
		return
	end
	local c = characterOf(player)
	local item = c and Items.carriedBy(c)
	if item then
		local inPond = Items.drop(item, map.pondCenter, map.pondRadius)
		if inPond then
			toast(nil, player.DisplayName .. " dropped the " .. item.def.name:lower() .. " in the pond!")
			local data = geese[player]
			if data then
				data.honksLanded += 2 -- a prank is worth a couple of honks
			end
		end
	end
end)

-- ---------- Round loop ----------
local function startRound()
	phase = "round"
	phaseEndsAt = os.clock() + Config.ROUND_SECONDS
	Items.resetAll()
	assignRoles()
	toast(nil, "Round start! " .. Config.ROUND_SECONDS // 60 .. " minutes. Fill your nest.")
	broadcast()
end

local function endRound()
	phase = "results"
	phaseEndsAt = os.clock() + Config.RESULTS_SECONDS
	local bestPlayer: Player? = nil
	local best = -1
	for player, data in geese do
		local s = gooseScore(data)
		if s > best then
			best = s
			bestPlayer = player
		end
	end
	local keeperPts = keeperScore.catches * Config.POINTS_PER_CATCH + keeperScore.returned * Config.POINTS_PER_ITEM_RETURNED
	if bestPlayer and best >= keeperPts then
		toast(nil, "Time's up! Top goose: " .. bestPlayer.DisplayName .. " with " .. best .. " points. HONK.")
	else
		toast(nil, "Time's up! The groundskeeper wins with " .. keeperPts .. " points.")
	end
	for player in geese do
		setSpeed(player, Config.GOOSE_WALK_SPEED)
	end
	broadcast()
end

local function startIntermission()
	phase = "intermission"
	phaseEndsAt = os.clock() + Config.INTERMISSION_SECONDS
	if npc then
		npc:destroy()
		npc = nil
	end
	broadcast()
end

local lastBroadcast = 0
RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()

	if phase == "round" then
		Items.update(now)

		-- goose stamina and sprint
		for player, data in geese do
			local c = characterOf(player)
			local h = c and c:FindFirstChildOfClass("Humanoid")
			if h then
				local moving = h.MoveDirection.Magnitude > 0
				if data.sprinting and moving and data.stamina > 0.02 then
					data.stamina = math.max(0, data.stamina - Config.STAMINA_DRAIN_PER_SEC * dt)
					h.WalkSpeed = Config.GOOSE_SPRINT_SPEED
				else
					data.stamina = math.min(1, data.stamina + Config.STAMINA_REGEN_PER_SEC * dt)
					h.WalkSpeed = Config.GOOSE_WALK_SPEED
				end
				if Items.carriedBy(c :: Model) then
					h.WalkSpeed *= Config.GOOSE_CARRY_MULT
				end
				-- banking: standing on your own nest while carrying
				local item = Items.carriedBy(c :: Model)
				local root = (c :: Model):FindFirstChild("HumanoidRootPart") :: BasePart
				if item and (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(data.nest.Position.X, 0, data.nest.Position.Z)).Magnitude < 5 then
					Items.bank(item, data.nest)
					toast(player, "+" .. item.def.value .. "  " .. item.def.name)
					updateNestLabels()
				end
			end
		end

		-- the groundskeeper
		local gooseModels = {}
		for player in geese do
			local c = characterOf(player)
			if c then
				table.insert(gooseModels, c)
			end
		end
		local bankedCount = 0
		for _, item in Items.list do
			if item.state == "banked" then
				bankedCount += 1
			end
		end
		if npc then
			local result = npc:update(now, gooseModels, nestParts, bankedCount)
			if result then
				if result:IsA("Model") then
					local p = Players:GetPlayerFromCharacter(result)
					if p then
						catchGoose(p)
					end
				elseif result:IsA("Part") then
					raidNest(result)
				end
			end
		elseif keeperPlayer then
			local kc = characterOf(keeperPlayer)
			local kroot = kc and kc:FindFirstChild("HumanoidRootPart") :: BasePart?
			local kh = kc and kc:FindFirstChildOfClass("Humanoid")
			if kroot and kh then
				if kh.WalkSpeed > 0 then
					kh.WalkSpeed = Config.KEEPER_WALK_SPEED + Config.KEEPER_SPEED_PER_BANKED_ITEM * bankedCount
				end
				for player, data in geese do
					local c = characterOf(player)
					local root = c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
					if root and now >= data.safeUntil and (root.Position - kroot.Position).Magnitude < Config.CATCH_DISTANCE then
						catchGoose(player)
					end
				end
				-- a human keeper raids by walking onto a nest
				for _, nest in nestParts do
					if (Vector3.new(nest.Position.X, 0, nest.Position.Z) - Vector3.new(kroot.Position.X, 0, kroot.Position.Z)).Magnitude < 5 then
						local lastRaid = nest:GetAttribute("LastRaid") :: number? or 0
						if now - lastRaid > 6 and Items.mostValuableInNest(nest) then
							nest:SetAttribute("LastRaid", now)
							raidNest(nest)
						end
					end
				end
			end
		end

		-- stamina to each goose, 10x a second
		if now - lastBroadcast > 0.1 then
			for player, data in geese do
				Remotes.Stamina:FireClient(player, data.stamina)
			end
		end
	end

	if now - lastBroadcast > 0.5 then
		lastBroadcast = now
		broadcast()
	end

	if now >= phaseEndsAt then
		if phase == "intermission" then
			if #Players:GetPlayers() >= Config.MIN_PLAYERS then
				startRound()
			else
				phaseEndsAt = now + 5
			end
		elseif phase == "round" then
			endRound()
		else
			startIntermission()
		end
	end
end)

-- ---------- Players joining / leaving ----------
Players.PlayerAdded:Connect(function(player: Player)
	player:SetAttribute("Role", "spectator")
	player.CharacterAdded:Connect(function(c: Model)
		c:SetAttribute("Safe", false)
		-- respawn mid-round goes to your nest
		task.wait(0.2)
		local data = geese[player]
		if data then
			c:PivotTo(CFrame.new(data.nest.Position + Vector3.new(0, 4, 0)))
		elseif player == keeperPlayer then
			c:PivotTo(CFrame.new(map.keeperSpawn))
		end
	end)
	toast(player, "Welcome to Goose Chaos. The next round starts soon.")
end)

Players.PlayerRemoving:Connect(function(player: Player)
	local data = geese[player]
	if data then
		data.nest:SetAttribute("Owner", "")
		for _, item in Items.inNest(data.nest) do
			Items.returnHome(item)
		end
		geese[player] = nil
		updateNestLabels()
	end
	if player == keeperPlayer then
		keeperPlayer = nil
		if phase == "round" then
			npc = NpcKeeper.new(map.keeperSpawn, map.patrol)
			toast(nil, "The groundskeeper left. The computer takes over.")
		end
	end
end)
