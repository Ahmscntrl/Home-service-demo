--!strict
-- Item lifecycle: on the ground, carried by a character, banked in a nest.
-- The web prototype's rules carried over: one item at a time, dropping it in
-- the pond counts as a prank, dropped items go home by themselves.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local ItemDefs = require(ReplicatedStorage.Shared.ItemDefs)

export type ItemState = "ground" | "carried" | "banked" | "pond"

export type Item = {
	def: typeof(ItemDefs[1]),
	part: Part,
	prompt: ProximityPrompt,
	state: ItemState,
	carrier: Model?, -- character carrying it
	nest: Part?, -- nest it is banked in
	droppedAt: number?,
}

local Items = {}
Items.byId = {} :: { [string]: Item }
Items.list = {} :: { Item }
Items.onGrab = nil :: ((player: Player, item: Item) -> ())?

local itemFolder: Folder

local function setPrompt(item: Item, enabled: boolean, text: string?)
	item.prompt.Enabled = enabled
	if text then
		item.prompt.ActionText = text
	end
end

local function placeOnGround(item: Item, position: Vector3)
	local p = item.part
	-- leave the character first, then anchor and move, so no leftover
	-- assembly velocity or weld can drag it along
	p.Parent = itemFolder
	p.Anchored = true
	p.CanCollide = false
	p.AssemblyLinearVelocity = Vector3.zero
	p.AssemblyAngularVelocity = Vector3.zero
	p.CFrame = CFrame.new(position + Vector3.new(0, p.Size.Y / 2 + 0.2, 0))
end

function Items.init(parentFolder: Folder)
	itemFolder = Instance.new("Folder")
	itemFolder.Name = "Items"
	itemFolder.Parent = parentFolder

	for _, def in ItemDefs do
		local part = Instance.new("Part")
		part.Name = def.id
		part.Size = def.size
		part.Color = def.color
		part.Material = Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = false
		part:SetAttribute("ItemId", def.id)

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Grab"
		prompt.ObjectText = def.name .. "  (+" .. def.value .. ")"
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = Config.GRAB_DISTANCE
		prompt.RequiresLineOfSight = false
		prompt.Parent = part

		local item: Item = { def = def, part = part, prompt = prompt, state = "ground", carrier = nil, nest = nil, droppedAt = nil }
		Items.byId[def.id] = item
		table.insert(Items.list, item)
		placeOnGround(item, def.position)

		prompt.Triggered:Connect(function(player)
			if Items.onGrab then
				Items.onGrab(player, item)
			end
		end)
	end
end

-- Attach the item above the character's head
function Items.pickUp(item: Item, character: Model)
	local head = character:FindFirstChild("Head") :: BasePart?
	if not head then
		return
	end
	item.state = "carried"
	item.carrier = character
	item.nest = nil
	item.droppedAt = nil
	setPrompt(item, false)

	local p = item.part
	p.Anchored = false
	p.CanCollide = false
	p.Massless = true
	p.CFrame = head.CFrame * CFrame.new(0, 2.2, 0)
	local weld = Instance.new("WeldConstraint")
	weld.Name = "CarryWeld"
	weld.Part0 = head
	weld.Part1 = p
	weld.Parent = p
	p.Parent = character
end

local function detach(item: Item): Vector3
	local p = item.part
	for _, c in p:GetChildren() do
		if c:IsA("WeldConstraint") or c:IsA("Weld") then
			c:Destroy()
		end
	end
	local pos = p.Position
	item.carrier = nil
	return pos
end

-- Put the item back on the ground where the carrier is standing
function Items.drop(item: Item, pondCenter: Vector3?, pondRadius: number?): boolean
	local pos = detach(item)
	local groundPos = Vector3.new(pos.X, 0, pos.Z)
	local inPond = false
	if pondCenter and pondRadius then
		local flat = Vector3.new(pos.X - pondCenter.X, 0, pos.Z - pondCenter.Z)
		inPond = flat.Magnitude < pondRadius
	end
	if inPond then
		item.state = "pond"
		item.part.Transparency = 0.6
		setPrompt(item, false)
		placeOnGround(item, Vector3.new(pos.X, -0.6, pos.Z))
	else
		item.state = "ground"
		item.droppedAt = os.clock()
		setPrompt(item, true, "Grab")
		placeOnGround(item, groundPos)
	end
	return inPond
end

-- Display the item on a nest. Items on a nest can be stolen by other geese
-- or taken back by the groundskeeper.
function Items.bank(item: Item, nest: Part)
	detach(item)
	item.state = "banked"
	item.nest = nest
	item.droppedAt = nil
	setPrompt(item, true, "Steal")

	-- lay banked items in a ring on the nest
	local count = 0
	for _, other in Items.list do
		if other.nest == nest and other ~= item then
			count += 1
		end
	end
	local angle = count * (math.pi * 2 / 8)
	local offset = Vector3.new(math.cos(angle) * 3, 0, math.sin(angle) * 3)
	placeOnGround(item, nest.Position + offset + Vector3.new(0, 0.4, 0))
end

-- Send the item home (groundskeeper returned it, or it timed out on the ground)
function Items.returnHome(item: Item)
	detach(item)
	item.state = "ground"
	item.nest = nil
	item.droppedAt = nil
	item.part.Transparency = 0
	setPrompt(item, true, "Grab")
	placeOnGround(item, item.def.position)
end

function Items.carriedBy(character: Model): Item?
	for _, item in Items.list do
		if item.carrier == character then
			return item
		end
	end
	return nil
end

function Items.inNest(nest: Part): { Item }
	local out = {}
	for _, item in Items.list do
		if item.state == "banked" and item.nest == nest then
			table.insert(out, item)
		end
	end
	return out
end

function Items.nestValue(nest: Part): number
	local total = 0
	for _, item in Items.inNest(nest) do
		total += item.def.value
	end
	return total
end

function Items.mostValuableInNest(nest: Part): Item?
	local best: Item? = nil
	for _, item in Items.inNest(nest) do
		if not best or item.def.value > best.def.value then
			best = item
		end
	end
	return best
end

function Items.resetAll()
	for _, item in Items.list do
		Items.returnHome(item)
	end
end

-- Called every frame by the game loop
function Items.update(now: number)
	for _, item in Items.list do
		if item.state == "ground" and item.droppedAt and now - item.droppedAt > Config.ITEM_RETURN_SECONDS then
			Items.returnHome(item)
		end
		-- the carrier died or left
		if item.state == "carried" then
			local c = item.carrier
			if not c or not c.Parent or not c:FindFirstChild("Head") then
				Items.returnHome(item)
			end
		end
	end
end

function Items.playerFromCharacter(character: Model): Player?
	return Players:GetPlayerFromCharacter(character)
end

return Items
