--!strict
-- Villagers wander the green minding their own business. Some carry
-- items. Honk near one and they panic, scream and drop what they hold.
-- Scaring them is a prank worth points.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Nav = require(script.Parent.Nav)
local Rig = require(script.Parent.Rig)
local Items = require(script.Parent.Items)
local Sfx = require(script.Parent.Sfx)

local Villagers = {}

export type Villager = {
	body: Rig.Body,
	nav: Nav.Nav,
	home: Vector3,
	wander: Vector3?,
	wanderT: number,
	panicUntil: number,
	fleeFrom: Vector3?,
	scaredAt: number,
	name: string,
}

Villagers.list = {} :: { Villager }

local LOOKS = {
	{ name = "Mrs. Pennywhistle", top = Color3.fromRGB(190, 70, 120), bottom = Color3.fromRGB(60, 50, 80), skin = Color3.fromRGB(230, 180, 140), carry = "sandwich" },
	{ name = "Old Bert", top = Color3.fromRGB(90, 110, 80), bottom = Color3.fromRGB(80, 70, 60), skin = Color3.fromRGB(200, 150, 110), carry = "radio" },
	{ name = "Tilly", top = Color3.fromRGB(250, 200, 70), bottom = Color3.fromRGB(70, 110, 180), skin = Color3.fromRGB(160, 110, 80), carry = "teacup" },
	{ name = "The Postman", top = Color3.fromRGB(200, 40, 40), bottom = Color3.fromRGB(40, 40, 50), skin = Color3.fromRGB(245, 215, 185), carry = "keys" },
}

local SCREAMS = { "AAAH!", "A GOOSE!", "SHOO!", "NOT AGAIN!", "MY THINGS!", "HELP!" }

local function description(look): HumanoidDescription
	local d = Instance.new("HumanoidDescription")
	d.HeadColor = look.skin
	d.LeftArmColor = look.skin
	d.RightArmColor = look.skin
	d.TorsoColor = look.top
	d.LeftLegColor = look.bottom
	d.RightLegColor = look.bottom
	d.HeightScale = 0.95 + math.random() * 0.15
	d.WidthScale = 0.9 + math.random() * 0.3
	d.BodyTypeScale = math.random() * 0.3
	return d
end

function Villagers.spawn(spots: { Vector3 })
	Villagers.clear()
	for i, look in LOOKS do
		local spot = spots[((i - 1) % #spots) + 1]
		local body = Rig.build(look.name, description(look), spot, 9)
		local v: Villager = {
			body = body,
			nav = Nav.new(body.humanoid, body.root, 2),
			home = spot,
			wander = nil,
			wanderT = 0,
			panicUntil = 0,
			fleeFrom = nil,
			scaredAt = 0,
			name = look.name,
		}
		table.insert(Villagers.list, v)
		-- hand them their item
		local item = Items.byId[look.carry]
		if item and item.state == "ground" then
			Items.pickUp(item, body.model)
		end
	end
end

function Villagers.clear()
	for _, v in Villagers.list do
		local carried = Items.carriedBy(v.body.model)
		if carried then
			Items.returnHome(carried)
		end
		v.body.model:Destroy()
	end
	Villagers.list = {}
end

-- A goose honked at `from`. Returns how many villagers were scared.
function Villagers.scare(from: Vector3, now: number): number
	local n = 0
	for _, v in Villagers.list do
		if (v.body.root.Position - from).Magnitude <= Config.HONK_RANGE and now >= v.panicUntil then
			v.panicUntil = now + 4
			v.fleeFrom = from
			v.scaredAt = now
			v.body.humanoid.WalkSpeed = 20
			Rig.say(v.body, SCREAMS[math.random(#SCREAMS)], Color3.fromRGB(255, 120, 100))
			Sfx.at("scream", v.body.root)
			local carried = Items.carriedBy(v.body.model)
			if carried then
				Items.drop(carried, nil, nil)
			end
			n += 1
		end
	end
	return n
end

function Villagers.update(now: number)
	for _, v in Villagers.list do
		local b = v.body
		if not b.model.Parent then
			continue
		end
		Rig.animate(b)
		if now < v.panicUntil and v.fleeFrom then
			-- run away from the honk, arms flailing (well, running)
			local away = (b.root.Position - (v.fleeFrom :: Vector3))
			away = Vector3.new(away.X, 0, away.Z)
			if away.Magnitude < 1 then
				away = Vector3.new(1, 0, 0)
			end
			v.nav:moveTo(b.root.Position + away.Unit * 25, now)
			continue
		end
		if v.panicUntil > 0 and now >= v.panicUntil and b.humanoid.WalkSpeed > 9 then
			b.humanoid.WalkSpeed = 9
			Rig.say(b, "")
			v.panicUntil = 0
		end
		-- pick an item back up if one is lying right next to them
		if not Items.carriedBy(b.model) and now - v.scaredAt > 8 then
			for _, item in Items.list do
				if item.state == "ground" and (item.part.Position - b.root.Position).Magnitude < 4 then
					Items.pickUp(item, b.model)
					Rig.say(b, "There you are.")
					task.delay(2, function()
						if b.label and b.label.Text == "There you are." then
							Rig.say(b, "")
						end
					end)
					break
				end
			end
		end
		-- wander near home
		v.wanderT -= 1 / 60
		if not v.wander or v.wanderT <= 0 or v.nav:reached(v.wander :: Vector3, 3) then
			v.wander = v.home + Vector3.new((math.random() - 0.5) * 50, 0, (math.random() - 0.5) * 50)
			v.wanderT = 4 + math.random() * 4
		end
		v.nav:moveTo(v.wander :: Vector3, now)
	end
end

return Villagers
