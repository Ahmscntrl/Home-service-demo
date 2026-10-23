--!strict
-- The prank to-do list every goose gets. Finish it all for a big bonus.
-- Shared so the client can show names; the server does the checking.

export type TaskDef = {
	id: string,
	text: string,
	points: number,
}

local Tasks: { TaskDef } = {
	{ id = "hat", text = "Steal the gardener's hat", points = 40 },
	{ id = "scare", text = "Scare 3 villagers", points = 40 },
	{ id = "keys", text = "Drop the keys in the pond", points = 50 },
	{ id = "honk", text = "Honk at him 3 times", points = 40 },
	{ id = "nest", text = "Have 4 things in your nest", points = 60 },
}

return Tasks
