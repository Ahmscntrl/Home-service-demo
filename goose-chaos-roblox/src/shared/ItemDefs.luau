--!strict
-- Things the geese can steal. Positions are in studs on the village map
-- (see server/MapBuilder). Higher value = further from the nests or closer to
-- the groundskeeper's patrol.

export type ItemDef = {
	id: string,
	name: string,
	value: number,
	color: Color3,
	size: Vector3,
	position: Vector3,
}

local ItemDefs: { ItemDef } = {
	{ id = "hat", name = "Gardener's hat", value = 60, color = Color3.fromRGB(217, 164, 65), size = Vector3.new(2, 0.6, 2), position = Vector3.new(10, 0, -18) },
	{ id = "sandwich", name = "Sandwich", value = 25, color = Color3.fromRGB(227, 192, 123), size = Vector3.new(1.6, 0.8, 1.6), position = Vector3.new(-2, 0, -18) },
	{ id = "keys", name = "Keys", value = 40, color = Color3.fromRGB(184, 192, 200), size = Vector3.new(1.2, 0.4, 1.2), position = Vector3.new(52, 0, 44) },
	{ id = "gnome", name = "Garden gnome", value = 50, color = Color3.fromRGB(196, 61, 47), size = Vector3.new(1.4, 2.4, 1.4), position = Vector3.new(-54, 0, -32) },
	{ id = "radio", name = "Radio", value = 45, color = Color3.fromRGB(75, 90, 122), size = Vector3.new(2, 1.2, 1), position = Vector3.new(-12, 0, -46) },
	{ id = "teacup", name = "Teacup", value = 20, color = Color3.fromRGB(243, 240, 234), size = Vector3.new(1, 0.9, 1), position = Vector3.new(-24, 0, 4) },
	{ id = "boot", name = "Wellie boot", value = 30, color = Color3.fromRGB(62, 125, 74), size = Vector3.new(1, 1.8, 1.8), position = Vector3.new(30, 0, 26) },
	{ id = "rake", name = "Rake", value = 35, color = Color3.fromRGB(156, 107, 60), size = Vector3.new(0.5, 0.5, 5), position = Vector3.new(60, 0, 0) },
	{ id = "marrow", name = "Prize marrow", value = 80, color = Color3.fromRGB(111, 174, 58), size = Vector3.new(1.4, 1.2, 3), position = Vector3.new(6, 0, -58) },
}

return ItemDefs
