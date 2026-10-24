--!strict
-- All the numbers that tune the game live here.
-- Tuned from playtests: the first Studio round was "a little too easy", so
-- the groundskeeper is quicker, sees further and raids more often than the
-- web prototype's numbers.

local Config = {
	-- Round flow
	MIN_PLAYERS = 1, -- 1 so you can test alone (the groundskeeper becomes an NPC)
	INTERMISSION_SECONDS = 12,
	ROUND_SECONDS = 180,
	RESULTS_SECONDS = 10,

	-- Geese
	GOOSE_WALK_SPEED = 18,
	GOOSE_SPRINT_SPEED = 26,
	GOOSE_CARRY_MULT = 0.85, -- speed multiplier while carrying an item
	STAMINA_DRAIN_PER_SEC = 0.5,
	STAMINA_REGEN_PER_SEC = 0.22,
	HONK_COOLDOWN = 2,
	HONK_RANGE = 18, -- studs
	HONK_STUN_SECONDS = 1.4,
	SAFE_SECONDS_AFTER_CATCH = 3,

	-- Groundskeeper
	KEEPER_WALK_SPEED = 22,
	KEEPER_SPEED_PER_BANKED_ITEM = 0.8, -- he gets faster the more loot is banked
	CATCH_DISTANCE = 5, -- studs between root parts
	NPC_KEEPER_SIGHT = 70, -- studs; only used when nobody is the groundskeeper
	NPC_KEEPER_RAID_INTERVAL = 20,
	KEEPER_IGNORE_AFTER_CATCH = 6, -- seconds the NPC leaves a goose alone after catching it
	NEST_SAFE_RADIUS = 8, -- standing this close to your own nest, you can't be caught

	-- Dog (let out partway through the round)
	DOG_RELEASE_AT = 90, -- seconds into the round
	DOG_SPEED = 27,
	DOG_SIGHT = 55,
	DOG_STUN_SECONDS = 2,

	-- Villagers
	VILLAGER_SCARE_POINTS = 5,

	-- Items and nests
	GRAB_DISTANCE = 8,
	ITEM_RETURN_SECONDS = 20, -- a dropped item goes home by itself after this long
	STEAL_FROM_NEST_COOLDOWN = 4,

	-- Scoring
	POINTS_PER_HONK_LANDED = 10,
	POINTS_PER_CATCH = 25,
	POINTS_PER_ITEM_RETURNED = 15,
	POINTS_PER_DOG_CATCH = 10,
	ALL_TASKS_BONUS = 150,
}

return Config
