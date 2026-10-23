--!strict
-- Builds the village out of plain parts so the game runs with no assets.
-- Replace pieces with real models later; keep the names (Nests, Items,
-- Obstacles) because the other scripts look them up.

local MapBuilder = {}

local GROUND_Y = 0
local MAP_HALF = 90 -- the map is 180 x 180 studs

export type Map = {
	folder: Folder,
	nestSpots: { Vector3 },
	patrol: { Vector3 },
	pondCenter: Vector3,
	pondRadius: number,
	keeperSpawn: Vector3,
}

local function part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do
		(p :: any)[k] = v
	end
	return p
end

local function house(parent: Instance, x: number, z: number, w: number, d: number, roofColor: Color3)
	local h = 10
	part({ Name = "HouseWall", Size = Vector3.new(w, h, d), Position = Vector3.new(x, GROUND_Y + h / 2, z), Color = Color3.fromRGB(232, 220, 196), Material = Enum.Material.Concrete, Parent = parent })
	part({ Name = "HouseRoof", Shape = Enum.PartType.Block, Size = Vector3.new(w + 2, 5, d + 2), Position = Vector3.new(x, GROUND_Y + h + 2.5, z), Color = roofColor, Material = Enum.Material.Slate, Parent = parent })
	part({ Name = "Door", Size = Vector3.new(3, 6, 0.4), Position = Vector3.new(x, GROUND_Y + 3, z + d / 2 + 0.1), Color = Color3.fromRGB(106, 76, 46), Material = Enum.Material.Wood, CanCollide = false, Parent = parent })
end

local function hedge(parent: Instance, x: number, z: number, w: number, d: number)
	part({ Name = "Hedge", Size = Vector3.new(w, 4, d), Position = Vector3.new(x, GROUND_Y + 2, z), Color = Color3.fromRGB(63, 138, 58), Material = Enum.Material.Grass, Parent = parent })
end

local function tree(parent: Instance, x: number, z: number)
	part({ Name = "Trunk", Size = Vector3.new(1.6, 6, 1.6), Position = Vector3.new(x, GROUND_Y + 3, z), Color = Color3.fromRGB(107, 74, 43), Material = Enum.Material.Wood, Parent = parent })
	part({ Name = "Leaves", Shape = Enum.PartType.Ball, Size = Vector3.new(9, 9, 9), Position = Vector3.new(x, GROUND_Y + 9, z), Color = Color3.fromRGB(47, 122, 53), Material = Enum.Material.Grass, CanCollide = false, Parent = parent })
end

function MapBuilder.build(): Map
	local folder = Instance.new("Folder")
	folder.Name = "Village"
	folder.Parent = workspace

	local obstacles = Instance.new("Folder")
	obstacles.Name = "Obstacles"
	obstacles.Parent = folder

	-- Ground
	part({ Name = "Grass", Size = Vector3.new(MAP_HALF * 2, 2, MAP_HALF * 2), Position = Vector3.new(0, GROUND_Y - 1, 0), Color = Color3.fromRGB(95, 154, 68), Material = Enum.Material.Grass, Parent = folder })
	-- Invisible walls around the edge
	for _, side in { { MAP_HALF + 2, 0, 4, MAP_HALF * 2 + 8 }, { -MAP_HALF - 2, 0, 4, MAP_HALF * 2 + 8 }, { 0, MAP_HALF + 2, MAP_HALF * 2 + 8, 4 }, { 0, -MAP_HALF - 2, MAP_HALF * 2 + 8, 4 } } do
		part({ Name = "Border", Size = Vector3.new(side[3], 30, side[4]), Position = Vector3.new(side[1], GROUND_Y + 15, side[2]), Transparency = 1, Parent = folder })
	end

	-- Paths (decorative, walkable)
	for _, seg in { { -60, 60, 20, 16 }, { 20, 16, 0, -10 }, { 0, -10, 40, -40 }, { 0, -10, -40, -50 } } do
		local a = Vector3.new(seg[1], GROUND_Y + 0.05, seg[2])
		local b = Vector3.new(seg[3], GROUND_Y + 0.05, seg[4])
		local len = (b - a).Magnitude
		part({ Name = "Path", Size = Vector3.new(6, 0.1, len), CFrame = CFrame.lookAt((a + b) / 2, b), Color = Color3.fromRGB(201, 183, 132), Material = Enum.Material.Sand, CanCollide = false, Parent = folder })
	end

	-- Pond: a shallow blue disc you can wade through; dropping the keys in it is a prank
	local pondCenter = Vector3.new(48, GROUND_Y, -42)
	local pondRadius = 18
	local pond = part({ Name = "Pond", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, pondRadius * 2, pondRadius * 2), CFrame = CFrame.new(pondCenter + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(79, 147, 184), Material = Enum.Material.Glass, Transparency = 0.3, CanCollide = false, Parent = folder })
	pond:SetAttribute("Radius", pondRadius)

	-- Buildings and hedges (obstacles that both sides must path around)
	house(obstacles, -58, -60, 24, 16, Color3.fromRGB(200, 85, 61))
	house(obstacles, 62, 50, 24, 16, Color3.fromRGB(138, 90, 68))
	house(obstacles, -6, -66, 16, 10, Color3.fromRGB(111, 127, 79)) -- the shed
	hedge(obstacles, -20, -6, 30, 2)
	hedge(obstacles, -34, 6, 2, 24)
	hedge(obstacles, 18, 24, 2, 28)
	hedge(obstacles, 0, 44, 30, 2)
	hedge(obstacles, 34, -22, 2, 18)
	-- bench
	part({ Name = "Bench", Size = Vector3.new(6, 1.6, 2), Position = Vector3.new(4, GROUND_Y + 0.8, -24), Color = Color3.fromRGB(138, 90, 59), Material = Enum.Material.Wood, Parent = obstacles })
	for _, t in { { -30, -40 }, { 70, -70 }, { 24, -2 }, { -56, 18 }, { 76, 10 }, { -8, 22 }, { -78, -10 }, { 30, 62 }, { -40, 62 }, { 70, 76 } } do
		tree(obstacles, t[1], t[2])
	end

	-- Nests: a ring of six along the south edge, one per goose
	local nests = Instance.new("Folder")
	nests.Name = "Nests"
	nests.Parent = folder
	local nestSpots = {}
	for i = 1, 6 do
		local x = -70 + (i - 1) * 28
		local pos = Vector3.new(x, GROUND_Y, 76)
		table.insert(nestSpots, pos)
		local n = part({ Name = "Nest" .. i, Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.6, 10, 10), CFrame = CFrame.new(pos + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(160, 120, 60), Material = Enum.Material.WoodPlanks, Parent = nests })
		n:SetAttribute("Index", i)
		n:SetAttribute("Owner", "") -- player name, set each round
		local label = Instance.new("BillboardGui")
		label.Name = "Label"
		label.Size = UDim2.fromOffset(160, 40)
		label.StudsOffset = Vector3.new(0, 4, 0)
		label.AlwaysOnTop = true
		label.Parent = n
		local text = Instance.new("TextLabel")
		text.Name = "Text"
		text.Size = UDim2.fromScale(1, 1)
		text.BackgroundTransparency = 1
		text.TextScaled = true
		text.Font = Enum.Font.FredokaOne
		text.TextColor3 = Color3.new(1, 1, 1)
		text.TextStrokeTransparency = 0.3
		text.Text = "Empty nest"
		text.Parent = label
	end

	-- Groundskeeper's shed spawn, geese spawn at their nests
	local keeperSpawn = Vector3.new(-6, GROUND_Y + 3, -52)

	local patrol = {
		Vector3.new(0, GROUND_Y, -10),
		Vector3.new(40, GROUND_Y, -10),
		Vector3.new(44, GROUND_Y, 30),
		Vector3.new(0, GROUND_Y, 30),
		Vector3.new(-50, GROUND_Y, 30),
		Vector3.new(-50, GROUND_Y, -30),
		Vector3.new(-10, GROUND_Y, -40),
	}

	return {
		folder = folder,
		nestSpots = nestSpots,
		patrol = patrol,
		pondCenter = pondCenter,
		pondRadius = pondRadius,
		keeperSpawn = keeperSpawn,
	}
end

return MapBuilder
