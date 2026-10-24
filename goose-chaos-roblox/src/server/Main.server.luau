--!strict
-- Goose Chaos: round loop, roles, honking, catching, pranks, scoring.
--
-- Phases: intermission -> round -> results -> (repeat)
-- Roles:  one Groundskeeper (a player, or an NPC when nobody is free),
--         everyone else is a Goose with a nest and a prank to-do list.
-- Also on the green: villagers to scare, and the dog that comes out
-- partway through the round.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local TaskDefs = require(ReplicatedStorage.Shared.Tasks)
local MapBuilder = require(script.Parent.MapBuilder)
local Items = require(script.Parent.Items)
local NpcKeeper = require(script.Parent.NpcKeeper)
local Costumes = require(script.Parent.Costumes)
local Villagers = require(script.Parent.Villagers)
local Dog = require(script.Parent.Dog)

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
	scared: number,
	keysInPond: boolean,
	stealReadyAt: number,
	tasksDone: { [string]: boolean },
	allTasksDone: boolean,
	bonus: number,
	caught: number,
}
type Phase = "intermission" | "round" | "results"

local phase: Phase = "intermission"
local phaseEndsAt = os.clock() + Config.INTERMISSION_SECONDS
local roundStartedAt = 0
local geese: { [Player]: GooseData } = {}
local keeperPlayer: Player? = nil
local npc: NpcKeeper.Npc? = nil
local dog: Dog.Dog? = nil
local keeperScore = { catches = 0, returned = 0, dogCatches = 0 }
local keeperHistory: { [Player]: number } = {} -- how many times each player has been keeper

local function toast(player: Player?, text: string)
	if player then
		Remotes.Toast:FireClient(player, text)
	else
		Remotes.Toast:FireAllClients(text)
	end
end

local function pop(position: Vector3, text: string, color: Color3?)
	Remotes.Pop:FireAllClients(position, text, color)
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

local function keeperPosition(): Vector3
	local kc = keeperCharacter()
	local root = kc and kc:FindFirstChild("HumanoidRootPart") :: BasePart?
	return if root then root.Position else map.keeperSpawn
end

local function gooseScore(data: GooseData): number
	return Items.nestValue(data.nest) + data.honksLanded * Config.POINTS_PER_HONK_LANDED + data.scared * Config.VILLAGER_SCARE_POINTS + data.bonus
end

local function keeperPoints(): number
	return keeperScore.catches * Config.POINTS_PER_CATCH + keeperScore.returned * Config.POINTS_PER_ITEM_RETURNED + keeperScore.dogCatches * Config.POINTS_PER_DOG_CATCH
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

-- ---------- Tasks ----------
local function sendTasks(player: Player, data: GooseData)
	local list = {}
	for _, def in TaskDefs do
		table.insert(list, { id = def.id, text = def.text, done = data.tasksDone[def.id] == true })
	end
	Remotes.Tasks:FireClient(player, list)
end

local function taskSatisfied(id: string, data: GooseData): boolean
	if id == "hat" then
		local hat = Items.byId.hat
		return hat ~= nil and hat.state == "banked" and hat.nest == data.nest
	elseif id == "scare" then
		return data.scared >= 3
	elseif id == "keys" then
		return data.keysInPond
	elseif id == "honk" then
		return data.honksLanded >= 3
	elseif id == "nest" then
		return #Items.inNest(data.nest) >= 4
	end
	return false
end

local function checkTasks(player: Player, data: GooseData)
	local changed = false
	local all = true
	for _, def in TaskDefs do
		if not data.tasksDone[def.id] and taskSatisfied(def.id, data) then
			data.tasksDone[def.id] = true
			data.bonus += def.points
			changed = true
			toast(player, "✔ " .. def.text .. "  (+" .. def.points .. ")")
			local c = characterOf(player)
			local root = c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
			if root then
				pop(root.Position + Vector3.new(0, 4, 0), "+" .. def.points, Color3.fromRGB(120, 230, 120))
			end
		end
		if not data.tasksDone[def.id] then
			all = false
		end
	end
	if all and not data.allTasksDone then
		data.allTasksDone = true
		data.bonus += Config.ALL_TASKS_BONUS
		toast(nil, player.DisplayName .. " finished the whole prank list! +" .. Config.ALL_TASKS_BONUS .. " HONK!")
		changed = true
	end
	if changed then
		sendTasks(player, data)
	end
end

-- ---------- Broadcasting ----------
local function broadcast()
	local scores: { { name: string, role: string, score: number } } = {}
	for player, data in geese do
		table.insert(scores, { name = player.DisplayName, role = "goose", score = gooseScore(data) })
	end
	local keeperName = if npc then "Groundskeeper (NPC)" elseif keeperPlayer then keeperPlayer.DisplayName else "—"
	table.insert(scores, { name = keeperName, role = "keeper", score = keeperPoints() })
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
	keeperScore = { catches = 0, returned = 0, dogCatches = 0 }
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
			local kc = characterOf(p)
			if kc then
				task.spawn(Costumes.dressKeeper, kc)
			end
			toast(p, "You're the GROUNDSKEEPER. Catch the geese and take your things back!")
		elseif nestIndex <= #nestParts then
			local nest = nestParts[nestIndex]
			nestIndex += 1
			nest:SetAttribute("Owner", p.DisplayName)
			local data: GooseData = {
				player = p,
				nest = nest,
				stamina = 1,
				sprinting = false,
				honkReadyAt = 0,
				safeUntil = 0,
				honksLanded = 0,
				scared = 0,
				keysInPond = false,
				stealReadyAt = 0,
				tasksDone = {},
				allTasksDone = false,
				bonus = 0,
				caught = 0,
			}
			geese[p] = data
			p:SetAttribute("Role", "goose")
			setSpeed(p, Config.GOOSE_WALK_SPEED)
			teleport(p, nest.Position)
			local gc = characterOf(p)
			if gc then
				task.spawn(Costumes.dressGoose, gc)
			end
			sendTasks(p, data)
			toast(p, "You're a GOOSE. Work through your prank list. HONK to scare people.")
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

-- anything the goose is carrying goes home. Check both the item records
-- and the character itself so nothing can ride along.
local function stripCarried(c: Model): number
	local n = 0
	local item = Items.carriedBy(c)
	if item then
		Items.returnHome(item)
		n += 1
	end
	for _, child in c:GetChildren() do
		local id = child:GetAttribute("ItemId")
		if typeof(id) == "string" and Items.byId[id] then
			Items.returnHome(Items.byId[id])
			n += 1
		end
	end
	return n
end

local function catchGoose(player: Player)
	local data = geese[player]
	local c = characterOf(player)
	if not data or not c then
		return
	end
	keeperScore.catches += 1
	data.caught += 1
	local root = c:FindFirstChild("HumanoidRootPart") :: BasePart
	local carried = Items.carriedBy(c)
	local returned = stripCarried(c)
	if returned > 0 then
		keeperScore.returned += returned
		toast(player, "Caught! He took the " .. (if carried then carried.def.name:lower() else "loot") .. " back.")
	else
		toast(player, "Shooed away!")
	end
	pop(root.Position + Vector3.new(0, 4, 0), "CAUGHT!", Color3.fromRGB(255, 90, 70))
	Remotes.Shake:FireClient(player, 1)
	if keeperPlayer then
		toast(keeperPlayer, "You caught " .. player.DisplayName .. "!")
	end
	teleport(player, data.nest.Position)
	setSafe(player, Config.SAFE_SECONDS_AFTER_CATCH)
	updateNestLabels()
end

-- The dog doesn't send you home; it knocks the item out of your beak
local function dogCatch(player: Player)
	local data = geese[player]
	local c = characterOf(player)
	if not data or not c then
		return
	end
	local root = c:FindFirstChild("HumanoidRootPart") :: BasePart
	local item = Items.carriedBy(c)
	if item then
		Items.drop(item, map.pondCenter, map.pondRadius)
		toast(player, "The dog knocked the " .. item.def.name:lower() .. " out of your beak!")
	else
		toast(player, "The dog got you!")
	end
	keeperScore.dogCatches += 1
	data.caught += 1
	pop(root.Position + Vector3.new(0, 4, 0), "WOOF!", Color3.fromRGB(255, 160, 60))
	Remotes.Shake:FireClient(player, 0.6)
	local h = c:FindFirstChildOfClass("Humanoid")
	if h then
		h.WalkSpeed = 0
		task.delay(0.8, function()
			if h.Parent and geese[player] then
				h.WalkSpeed = Config.GOOSE_WALK_SPEED
			end
		end)
	end
	setSafe(player, 2)
	if dog then
		dog.stunnedUntil = os.clock() + 1.5
		dog.humanoid.WalkSpeed = 0
	end
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
	pop(nest.Position + Vector3.new(0, 5, 0), "-" .. item.def.value, Color3.fromRGB(255, 90, 70))
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
	s.PlaybackSpeed = 0.9 + math.random() * 0.25
	s.Parent = root
	s:Play()
	task.delay(2, function()
		s:Destroy()
	end)
	Costumes.honkBurst(root)

	-- villagers
	local scared = Villagers.scare(root.Position, now)
	if scared > 0 then
		data.scared += scared
		pop(root.Position + Vector3.new(0, 5, 0), "+" .. scared * Config.VILLAGER_SCARE_POINTS .. " scared!", Color3.fromRGB(255, 220, 90))
	end

	-- the dog
	if dog and (dog.root.Position - root.Position).Magnitude <= Config.HONK_RANGE then
		dog:stun(Config.DOG_STUN_SECONDS)
	end

	-- the groundskeeper
	local kc = keeperCharacter()
	local kroot = kc and kc:FindFirstChild("HumanoidRootPart") :: BasePart?
	if kroot and (kroot.Position - root.Position).Magnitude <= Config.HONK_RANGE then
		data.honksLanded += 1
		pop(kroot.Position + Vector3.new(0, 5, 0), "STUNNED +" .. Config.POINTS_PER_HONK_LANDED, Color3.fromRGB(255, 220, 60))
		if npc then
			npc:stun(Config.HONK_STUN_SECONDS)
		elseif keeperPlayer then
			local h = kc and kc:FindFirstChildOfClass("Humanoid")
			if h and kc then
				h.WalkSpeed = 0
				Costumes.showStun(kc, Config.HONK_STUN_SECONDS)
				toast(keeperPlayer, "HONK! You're stunned.")
				Remotes.Shake:FireClient(keeperPlayer, 0.5)
				task.delay(Config.HONK_STUN_SECONDS, function()
					if h.Parent and keeperPlayer and h.Parent == characterOf(keeperPlayer) then
						h.WalkSpeed = Config.KEEPER_WALK_SPEED
					end
				end)
			end
		end
	end
	checkTasks(player, data)
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
			pop(item.part.Position + Vector3.new(0, 3, 0), "+" .. Config.POINTS_PER_ITEM_RETURNED, Color3.fromRGB(120, 200, 255))
			updateNestLabels()
		end
		return
	end
	local data = geese[player]
	if not data then
		return
	end
	if Items.carriedBy(c) then
		toast(player, "You're already carrying something. Drop it first (Q).")
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

-- Drop what you're carrying (Q / the Drop button)
Remotes.Grab.OnServerEvent:Connect(function(player)
	if phase ~= "round" then
		return
	end
	local c = characterOf(player)
	local item = c and Items.carriedBy(c)
	local data = geese[player]
	if item and data then
		local inPond = Items.drop(item, map.pondCenter, map.pondRadius)
		if inPond then
			toast(nil, player.DisplayName .. " dropped the " .. item.def.name:lower() .. " in the pond!")
			pop(item.part.Position + Vector3.new(0, 3, 0), "SPLASH!", Color3.fromRGB(120, 200, 255))
			if item.def.id == "keys" then
				data.keysInPond = true
			end
			checkTasks(player, data)
		end
	end
end)

-- ---------- Round loop ----------
local function startRound()
	phase = "round"
	roundStartedAt = os.clock()
	phaseEndsAt = roundStartedAt + Config.ROUND_SECONDS
	if dog then
		dog:destroy()
		dog = nil
	end
	Items.resetAll()
	Villagers.spawn(map.villagerSpots)
	assignRoles()
	toast(nil, "Round start! " .. Config.ROUND_SECONDS // 60 .. " minutes. Cause chaos.")
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
	local kp = keeperPoints()
	local geeseWin = bestPlayer ~= nil and best >= kp
	local keeperName = if npc then "The groundskeeper" elseif keeperPlayer then keeperPlayer.DisplayName else "The groundskeeper"
	local winner = if geeseWin then (bestPlayer :: Player).DisplayName else keeperName

	-- full breakdown to every player; the HUD shows it for the results phase
	local rows: { { [string]: any } } = {}
	for player, data in geese do
		local pranks = 0
		for _ in data.tasksDone do
			pranks += 1
		end
		table.insert(rows, { name = player.DisplayName, role = "goose", score = gooseScore(data), loot = Items.nestValue(data.nest), pranks = pranks, scares = data.scared, honks = data.honksLanded, caught = data.caught })
	end
	table.insert(rows, { name = keeperName, role = "keeper", score = kp, catches = keeperScore.catches + keeperScore.dogCatches, returned = keeperScore.returned })
	table.sort(rows, function(a, b)
		return (a.score :: number) > (b.score :: number)
	end)
	Remotes.Results:FireAllClients({ winner = winner, geeseWin = geeseWin, rows = rows, seconds = Config.RESULTS_SECONDS, totalPranks = #TaskDefs })
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
	if dog then
		dog:destroy()
		dog = nil
	end
	Villagers.clear()
	for _, p in Players:GetPlayers() do
		p:SetAttribute("Role", "spectator")
		task.spawn(Costumes.undress, p)
	end
	broadcast()
end

local lastBroadcast = 0
local lastStamina = 0
RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()

	if phase == "round" then
		Items.update(now)
		Villagers.update(now)

		-- geese: stamina, sprint, banking
		local gooseModels = {}
		for player, data in geese do
			local c = characterOf(player)
			local h = c and c:FindFirstChildOfClass("Humanoid")
			if c and h then
				table.insert(gooseModels, c)
				local moving = h.MoveDirection.Magnitude > 0
				if h.WalkSpeed > 0 then
					if data.sprinting and moving and data.stamina > 0.02 then
						data.stamina = math.max(0, data.stamina - Config.STAMINA_DRAIN_PER_SEC * dt)
						h.WalkSpeed = Config.GOOSE_SPRINT_SPEED
					else
						data.stamina = math.min(1, data.stamina + Config.STAMINA_REGEN_PER_SEC * dt)
						h.WalkSpeed = Config.GOOSE_WALK_SPEED
					end
					if Items.carriedBy(c) then
						h.WalkSpeed *= Config.GOOSE_CARRY_MULT
					end
				end
				-- your own nest is home base: no catches there (raids still happen)
				local root = c:FindFirstChild("HumanoidRootPart") :: BasePart
				local nestDist = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(data.nest.Position.X, 0, data.nest.Position.Z)).Magnitude
				local home = nestDist < Config.NEST_SAFE_RADIUS
				if c:GetAttribute("Home") ~= home then
					c:SetAttribute("Home", home)
				end
				-- banking: standing on your own nest while carrying
				local item = Items.carriedBy(c)
				if item and nestDist < 5.5 then
					Items.bank(item, data.nest)
					toast(player, "+" .. item.def.value .. "  " .. item.def.name)
					pop(data.nest.Position + Vector3.new(0, 5, 0), "+" .. item.def.value, Color3.fromRGB(120, 230, 120))
					updateNestLabels()
					checkTasks(player, data)
				end
			end
		end

		local bankedCount = 0
		for _, item in Items.list do
			if item.state == "banked" then
				bankedCount += 1
			end
		end

		-- the groundskeeper
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
					if root and c and now >= data.safeUntil and c:GetAttribute("Home") ~= true and (root.Position - kroot.Position).Magnitude < Config.CATCH_DISTANCE then
						catchGoose(player)
					end
				end
				-- a human keeper raids by walking onto a nest
				for _, nest in nestParts do
					if (Vector3.new(nest.Position.X, 0, nest.Position.Z) - Vector3.new(kroot.Position.X, 0, kroot.Position.Z)).Magnitude < 5.5 then
						local lastRaid = nest:GetAttribute("LastRaid") :: number? or 0
						if now - lastRaid > 6 and Items.mostValuableInNest(nest) then
							nest:SetAttribute("LastRaid", now)
							raidNest(nest)
						end
					end
				end
			end
		end

		-- the dog
		if not dog and now - roundStartedAt >= Config.DOG_RELEASE_AT then
			dog = Dog.new(map.keeperSpawn)
			toast(nil, "Uh oh. He let the dog out! 🐕  Honk to scare it off.")
		end
		if dog then
			local caught = dog:update(now, dt, gooseModels, keeperPosition())
			if caught then
				local p = Players:GetPlayerFromCharacter(caught)
				if p then
					dogCatch(p)
				end
			end
		end

		-- tasks that depend on state changing elsewhere (raids etc.)
		if now - lastStamina > 0.1 then
			lastStamina = now
			for player, data in geese do
				Remotes.Stamina:FireClient(player, data.stamina)
				checkTasks(player, data)
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
		-- no jumping: geese waddle, and nobody hops the hedges
		local h = c:WaitForChild("Humanoid", 5) :: Humanoid?
		if h then
			h.UseJumpPower = true
			h.JumpPower = 0
			h:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		end
		-- respawn mid-round goes to your nest, in costume
		task.wait(0.2)
		local data = geese[player]
		if data then
			c:PivotTo(CFrame.new(data.nest.Position + Vector3.new(0, 4, 0)))
			if phase == "round" then
				task.spawn(Costumes.dressGoose, c)
			end
		elseif player == keeperPlayer then
			c:PivotTo(CFrame.new(map.keeperSpawn))
			if phase == "round" then
				task.spawn(Costumes.dressKeeper, c)
			end
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
