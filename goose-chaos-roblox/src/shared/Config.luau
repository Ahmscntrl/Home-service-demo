--!strict
-- All the numbers that tune the game live here.
-- Tuned from the web prototype: a 3-minute round, a groundskeeper a bit faster
-- than a walking goose, raids that punish a full nest, a safety window after a catch.

local Config = {
	-- Round flow
	MIN_PLAYERS = 1, -- 1 so you can test alone (the groundskeeper becomes an NPC)
	INTERMISSION_SECONDS = 12,
	ROUND_SECONDS = 180,
	RESULTS_SECONDS = 10,

	-- Geese
	GOOSE_WALK_SPEED = 16,
	GOOSE_SPRINT_SPEED = 24,
	GOOSE_CARRY_MULT = 0.85, -- speed multiplier while carrying an item
	STAMINA_DRAIN_PER_SEC = 0.45,
	STAMINA_REGEN_PER_SEC = 0.25,
	HONK_COOLDOWN = 2,
	HONK_RANGE = 18, -- studs
	HONK_STUN_SECONDS = 1.2,
	SAFE_SECONDS_AFTER_CATCH = 3,

	-- Groundskeeper
	KEEPER_WALK_SPEED = 19,
	KEEPER_SPEED_PER_BANKED_ITEM = 0.5, -- he gets faster the more loot is banked
	CATCH_DISTANCE = 4.5, -- studs between root parts
	NPC_KEEPER_SIGHT = 55, -- studs; only used when nobody is the groundskeeper
	NPC_KEEPER_RAID_INTERVAL = 25,

	-- Items and nests
	GRAB_DISTANCE = 8,
	ITEM_RETURN_SECONDS = 20, -- a dropped item goes home by itself after this long
	STEAL_FROM_NEST_COOLDOWN = 4,

	-- Scoring
	POINTS_PER_HONK_LANDED = 10,
	POINTS_PER_CATCH = 25,
	POINTS_PER_ITEM_RETURNED = 15,
}

return Config
