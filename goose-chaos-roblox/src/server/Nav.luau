--!strict
-- Shared walking brain for NPCs: move a Humanoid toward a point, re-planning
-- with PathfindingService a couple of times a second so it goes around
-- hedges and houses instead of walking into them.

local PathfindingService = game:GetService("PathfindingService")

local Nav = {}
Nav.__index = Nav

export type Nav = typeof(setmetatable({} :: {
	humanoid: Humanoid,
	root: BasePart,
	radius: number,
	target: Vector3?,
	waypoints: { PathWaypoint },
	wpIndex: number,
	repathAt: number,
}, Nav))

function Nav.new(humanoid: Humanoid, root: BasePart, agentRadius: number?): Nav
	return setmetatable({
		humanoid = humanoid,
		root = root,
		radius = agentRadius or 2.5,
		target = nil,
		waypoints = {},
		wpIndex = 1,
		repathAt = 0,
	}, Nav)
end

local function flatDist(a: Vector3, b: Vector3): number
	return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
end

function Nav.moveTo(self: Nav, target: Vector3, now: number)
	local changed = not self.target or ((self.target :: Vector3) - target).Magnitude > 3
	if changed or now >= self.repathAt then
		self.target = target
		self.repathAt = now + 0.5
		local path = PathfindingService:CreatePath({ AgentRadius = self.radius, AgentHeight = 6, AgentCanJump = false })
		local ok = pcall(function()
			path:ComputeAsync(self.root.Position, target)
		end)
		if ok and path.Status == Enum.PathStatus.Success then
			self.waypoints = path:GetWaypoints()
			self.wpIndex = 2
		else
			self.waypoints = {}
		end
	end
	local wps = self.waypoints
	if #wps >= self.wpIndex then
		local wp = wps[self.wpIndex]
		if flatDist(wp.Position, self.root.Position) < 2.5 then
			self.wpIndex += 1
			wp = wps[self.wpIndex]
		end
		if wp then
			self.humanoid:MoveTo(wp.Position)
			return
		end
	end
	self.humanoid:MoveTo(target)
end

function Nav.reached(self: Nav, target: Vector3, within: number): boolean
	return flatDist(target, self.root.Position) < within
end

Nav.flatDist = flatDist

return Nav
