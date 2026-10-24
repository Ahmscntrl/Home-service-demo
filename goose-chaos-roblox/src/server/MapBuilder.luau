--!strict
-- Builds the village: terrain ground with grass and a water pond, plus
-- houses, hedges, trees and nests made from parts. No assets needed.
-- Keep the folder names (Nests, Items, Obstacles): other scripts look them up.

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
	villagerSpots: { Vector3 },
}

local function part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CastShadow = true
	for k, v in props do
		(p :: any)[k] = v
	end
	return p
end

local function wedge(props: { [string]: any }): WedgePart
	local p = Instance.new("WedgePart")
	p.Anchored = true
	for k, v in props do
		(p :: any)[k] = v
	end
	return p
end

local function house(parent: Instance, x: number, z: number, w: number, d: number, wallColor: Color3, roofColor: Color3)
	local h = 10
	local m = Instance.new("Model")
	m.Name = "House"
	m.Parent = parent
	part({ Name = "Wall", Size = Vector3.new(w, h, d), Position = Vector3.new(x, GROUND_Y + h / 2, z), Color = wallColor, Material = Enum.Material.Brick, Parent = m })
	-- stone base course
	part({ Name = "Base", Size = Vector3.new(w + 0.4, 1.2, d + 0.4), Position = Vector3.new(x, GROUND_Y + 0.6, z), Color = Color3.fromRGB(120, 115, 105), Material = Enum.Material.Cobblestone, Parent = m })
	-- gable roof from two wedges: a WedgePart's tall face is its back (+Z), so each half is turned to put that face at the ridge
	local rh = 5
	wedge({ Name = "RoofL", Size = Vector3.new(d + 2, rh, (w + 2) / 2), CFrame = CFrame.new(x - (w + 2) / 4, GROUND_Y + h + rh / 2, z) * CFrame.Angles(0, math.rad(90), 0), Color = roofColor, Material = Enum.Material.Slate, Parent = m })
	wedge({ Name = "RoofR", Size = Vector3.new(d + 2, rh, (w + 2) / 2), CFrame = CFrame.new(x + (w + 2) / 4, GROUND_Y + h + rh / 2, z) * CFrame.Angles(0, math.rad(-90), 0), Color = roofColor, Material = Enum.Material.Slate, Parent = m })
	-- door, windows, chimney
	part({ Name = "Door", Size = Vector3.new(3.2, 6.4, 0.4), Position = Vector3.new(x, GROUND_Y + 3.2, z + d / 2 + 0.15), Color = Color3.fromRGB(96, 66, 40), Material = Enum.Material.Wood, CanCollide = false, Parent = m })
	part({ Name = "Knob", Shape = Enum.PartType.Ball, Size = Vector3.new(0.4, 0.4, 0.4), Position = Vector3.new(x + 1.1, GROUND_Y + 3.2, z + d / 2 + 0.4), Color = Color3.fromRGB(230, 190, 90), Material = Enum.Material.Metal, CanCollide = false, Parent = m })
	for _, wx in { x - w / 2 + 3.5, x + w / 2 - 3.5 } do
		part({ Name = "Window", Size = Vector3.new(3, 3, 0.3), Position = Vector3.new(wx, GROUND_Y + 6, z + d / 2 + 0.1), Color = Color3.fromRGB(160, 205, 235), Material = Enum.Material.Glass, Transparency = 0.35, CanCollide = false, Parent = m })
		part({ Name = "Sill", Size = Vector3.new(3.6, 0.3, 0.8), Position = Vector3.new(wx, GROUND_Y + 4.4, z + d / 2 + 0.3), Color = Color3.fromRGB(245, 240, 230), CanCollide = false, Parent = m })
	end
	part({ Name = "Chimney", Size = Vector3.new(1.6, 6, 1.6), Position = Vector3.new(x + w / 2 - 5, GROUND_Y + h + rh - 1, z - d / 4), Color = Color3.fromRGB(110, 70, 60), Material = Enum.Material.Brick, CanCollide = false, Parent = m })
end
local function hedge(parent: Instance, x: number, z: number, w: number, d: number)
	part({ Name = "Hedge", Size = Vector3.new(w, 5, d), Position = Vector3.new(x, GROUND_Y + 2.5, z), Color = Color3.fromRGB(58, 128, 54), Material = Enum.Material.LeafyGrass, Parent = parent })
end

local function tree(parent: Instance, x: number, z: number, scale: number?)
	local s = scale or 1
	local m = Instance.new("Model")
	m.Name = "Tree"
	m.Parent = parent
	part({ Name = "Trunk", Size = Vector3.new(1.8 * s, 7 * s, 1.8 * s), Position = Vector3.new(x, GROUND_Y + 3.5 * s, z), Color = Color3.fromRGB(98, 68, 40), Material = Enum.Material.Wood, Parent = m })
	local canopy = { { 0, 10, 0, 10 }, { -3, 8.5, 2, 7 }, { 3, 9, -2, 7.5 }, { 0, 12.5, 1.5, 6.5 } }
	for i, c in canopy do
		part({ Name = "Leaves", Shape = Enum.PartType.Ball, Size = Vector3.new(c[4] * s, c[4] * s, c[4] * s), Position = Vector3.new(x + c[1] * s, GROUND_Y + c[2] * s, z + c[3] * s), Color = if i % 2 == 0 then Color3.fromRGB(70, 140, 60) else Color3.fromRGB(52, 118, 50), Material = Enum.Material.LeafyGrass, CanCollide = false, Parent = m })
	end
end

local function flowerBed(parent: Instance, x: number, z: number, w: number, d: number)
	part({ Name = "Soil", Size = Vector3.new(w, 0.5, d), Position = Vector3.new(x, GROUND_Y + 0.25, z), Color = Color3.fromRGB(80, 55, 35), Material = Enum.Material.Ground, CanCollide = false, Parent = parent })
	local colors = { Color3.fromRGB(240, 90, 110), Color3.fromRGB(250, 200, 70), Color3.fromRGB(240, 240, 240), Color3.fromRGB(200, 110, 220) }
	for i = 1, math.floor(w * d / 6) do
		local fx = x + (math.random() - 0.5) * (w - 1)
		local fz = z + (math.random() - 0.5) * (d - 1)
		part({ Name = "Flower", Shape = Enum.PartType.Ball, Size = Vector3.new(0.7, 0.7, 0.7), Position = Vector3.new(fx, GROUND_Y + 1, fz), Color = colors[(i % #colors) + 1], Material = Enum.Material.SmoothPlastic, CanCollide = false, CastShadow = false, Parent = parent })
	end
end

local function fence(parent: Instance, x1: number, z1: number, x2: number, z2: number)
	local a, b = Vector3.new(x1, 0, z1), Vector3.new(x2, 0, z2)
	local len = (b - a).Magnitude
	local mid = (a + b) / 2
	local cf = CFrame.lookAt(mid, b)
	for _, y in { 1.2, 2.4 } do
		part({ Name = "Rail", Size = Vector3.new(0.3, 0.4, len), CFrame = cf * CFrame.new(0, GROUND_Y + y, 0), Color = Color3.fromRGB(235, 228, 210), Material = Enum.Material.WoodPlanks, CanCollide = false, Parent = parent })
	end
	for i = 0, math.floor(len / 4) do
		part({ Name = "Post", Size = Vector3.new(0.5, 3.2, 0.5), CFrame = cf * CFrame.new(0, GROUND_Y + 1.6, -len / 2 + i * 4), Color = Color3.fromRGB(235, 228, 210), Material = Enum.Material.WoodPlanks, CanCollide = false, Parent = parent })
	end
end

local function nest(parent: Instance, index: number, pos: Vector3): Part
	-- a ring of twigs with a soft centre
	local base = part({ Name = "Nest" .. index, Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.8, 11, 11), CFrame = CFrame.new(pos + Vector3.new(0, 0.4, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(150, 110, 60), Material = Enum.Material.WoodPlanks, Parent = parent })
	base:SetAttribute("Index", index)
	base:SetAttribute("Owner", "")
	part({ Name = "Straw", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 8, 8), CFrame = CFrame.new(pos + Vector3.new(0, 0.85, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(222, 190, 110), Material = Enum.Material.Fabric, CanCollide = false, Parent = base })
	for i = 1, 14 do
		local a = i / 14 * math.pi * 2
		part({ Name = "Twig", Size = Vector3.new(0.4, 0.4, 3.2), CFrame = CFrame.new(pos + Vector3.new(math.cos(a) * 5, 1.1, math.sin(a) * 5)) * CFrame.Angles(0, -a + 0.5, math.rad(12)), Color = Color3.fromRGB(110, 78, 40), Material = Enum.Material.Wood, CanCollide = false, CastShadow = false, Parent = base })
	end
	local label = Instance.new("BillboardGui")
	label.Name = "Label"
	label.Size = UDim2.fromOffset(180, 44)
	label.StudsOffset = Vector3.new(0, 5, 0)
	label.AlwaysOnTop = true
	label.MaxDistance = 120
	label.Parent = base
	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.TextScaled = true
	text.Font = Enum.Font.FredokaOne
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0.2
	text.Text = "Empty nest"
	text.Parent = label
	return base
end

function MapBuilder.build(): Map
	local folder = Instance.new("Folder")
	folder.Name = "Village"
	folder.Parent = workspace

	local obstacles = Instance.new("Folder")
	obstacles.Name = "Obstacles"
	obstacles.Parent = folder
	local decor = Instance.new("Folder")
	decor.Name = "Decor"
	decor.Parent = folder

	-- Terrain ground (grass with blades) and a water pond
	local terrain = workspace.Terrain
	terrain:Clear()
	-- Terrain.Decoration (grass blades) is not scriptable; it is set in default.project.json
	terrain.WaterColor = Color3.fromRGB(60, 140, 180)
	terrain.WaterTransparency = 0.6
	terrain.WaterWaveSize = 0.1
	terrain.WaterWaveSpeed = 8
	terrain:FillBlock(CFrame.new(0, GROUND_Y - 4, 0), Vector3.new(MAP_HALF * 2 + 40, 8, MAP_HALF * 2 + 40), Enum.Material.Grass)
	local pondCenter = Vector3.new(48, GROUND_Y, -42)
	local pondRadius = 18
	terrain:FillCylinder(CFrame.new(pondCenter + Vector3.new(0, -1.6, 0)), 4, pondRadius + 3, Enum.Material.Air)
	terrain:FillCylinder(CFrame.new(pondCenter + Vector3.new(0, -2.4, 0)), 2.4, pondRadius + 1, Enum.Material.Water)
	terrain:FillCylinder(CFrame.new(pondCenter + Vector3.new(0, -4, 0)), 1, pondRadius + 3, Enum.Material.Sand)
	-- the pond part is invisible; scripts use its position and radius
	local pond = part({ Name = "Pond", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.2, pondRadius * 2, pondRadius * 2), CFrame = CFrame.new(pondCenter + Vector3.new(0, -1, 0)) * CFrame.Angles(0, 0, math.rad(90)), Transparency = 1, CanCollide = false, Parent = folder })
	pond:SetAttribute("Radius", pondRadius)

	-- Invisible walls around the edge
	for _, side in { { MAP_HALF + 2, 0, 4, MAP_HALF * 2 + 8 }, { -MAP_HALF - 2, 0, 4, MAP_HALF * 2 + 8 }, { 0, MAP_HALF + 2, MAP_HALF * 2 + 8, 4 }, { 0, -MAP_HALF - 2, MAP_HALF * 2 + 8, 4 } } do
		part({ Name = "Border", Size = Vector3.new(side[3], 40, side[4]), Position = Vector3.new(side[1], GROUND_Y + 20, side[2]), Transparency = 1, Parent = folder })
	end
	-- white picket fence just inside the border
	fence(decor, -MAP_HALF, -MAP_HALF, MAP_HALF, -MAP_HALF)
	fence(decor, MAP_HALF, -MAP_HALF, MAP_HALF, MAP_HALF)
	fence(decor, -MAP_HALF, -MAP_HALF, -MAP_HALF, MAP_HALF)

	-- Cobbled paths
	for _, seg in { { -60, 60, 20, 16 }, { 20, 16, 0, -10 }, { 0, -10, 40, -40 }, { 0, -10, -40, -50 }, { -40, -50, -58, -50 } } do
		local a = Vector3.new(seg[1], GROUND_Y + 0.08, seg[2])
		local b = Vector3.new(seg[3], GROUND_Y + 0.08, seg[4])
		local len = (b - a).Magnitude
		part({ Name = "Path", Size = Vector3.new(6, 0.16, len + 6), CFrame = CFrame.lookAt((a + b) / 2, b), Color = Color3.fromRGB(190, 176, 140), Material = Enum.Material.Cobblestone, CanCollide = false, Parent = decor })
	end

	-- Buildings and hedges (obstacles both sides must path around)
	house(obstacles, -58, -60, 24, 16, Color3.fromRGB(226, 214, 190), Color3.fromRGB(176, 72, 52))
	house(obstacles, 62, 50, 24, 16, Color3.fromRGB(214, 200, 176), Color3.fromRGB(120, 78, 58))
	house(obstacles, -6, -66, 16, 10, Color3.fromRGB(150, 150, 120), Color3.fromRGB(96, 110, 70)) -- the shed
	hedge(obstacles, -20, -6, 30, 2)
	hedge(obstacles, -34, 6, 2, 24)
	hedge(obstacles, 18, 24, 2, 28)
	hedge(obstacles, 0, 44, 30, 2)
	hedge(obstacles, 34, -22, 2, 18)
	-- bench
	local bench = Instance.new("Model")
	bench.Name = "Bench"
	bench.Parent = obstacles
	part({ Name = "Seat", Size = Vector3.new(6, 0.4, 2), Position = Vector3.new(4, GROUND_Y + 1.6, -24), Color = Color3.fromRGB(150, 100, 60), Material = Enum.Material.WoodPlanks, Parent = bench })
	part({ Name = "Back", Size = Vector3.new(6, 1.6, 0.3), Position = Vector3.new(4, GROUND_Y + 2.8, -24.9), Color = Color3.fromRGB(150, 100, 60), Material = Enum.Material.WoodPlanks, Parent = bench })
	for _, lx in { 1.5, 6.5 } do
		part({ Name = "Leg", Size = Vector3.new(0.4, 1.6, 2), Position = Vector3.new(lx, GROUND_Y + 0.8, -24), Color = Color3.fromRGB(60, 60, 65), Material = Enum.Material.Metal, Parent = bench })
	end
	for _, t in { { -30, -40, 1 }, { 70, -70, 1.2 }, { 24, -2, 0.9 }, { -56, 18, 1.1 }, { 76, 10, 1 }, { -8, 22, 0.8 }, { -78, -10, 1.2 }, { 30, 62, 1 }, { -40, 62, 0.9 }, { 70, 76, 1.1 }, { -80, 80, 1 }, { 84, -30, 1.1 } } do
		tree(obstacles, t[1], t[2], t[3])
	end
	flowerBed(decor, -42, -60, 8, 4)
	flowerBed(decor, 46, 50, 8, 4)
	flowerBed(decor, -14, 36, 10, 3)

	-- Nests: six along the south edge, one per goose
	local nests = Instance.new("Folder")
	nests.Name = "Nests"
	nests.Parent = folder
	local nestSpots = {}
	for i = 1, 6 do
		local x = -70 + (i - 1) * 28
		local pos = Vector3.new(x, GROUND_Y, 76)
		table.insert(nestSpots, pos)
		nest(nests, i, pos)
	end

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

	-- where the villagers hang out: the bench, the pond, the big house, the far green
	local villagerSpots = {
		Vector3.new(10, GROUND_Y, -30),
		Vector3.new(30, GROUND_Y, -46),
		Vector3.new(50, GROUND_Y, 30),
		Vector3.new(-50, GROUND_Y, 40),
	}

	return {
		folder = folder,
		nestSpots = nestSpots,
		patrol = patrol,
		pondCenter = pondCenter,
		pondRadius = pondRadius,
		keeperSpawn = keeperSpawn,
		villagerSpots = villagerSpots,
	}
end

return MapBuilder
