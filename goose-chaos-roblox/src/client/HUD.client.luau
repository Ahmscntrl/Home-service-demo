--!strict
-- On-screen info: phase + timer, your role, stamina, prank list,
-- scoreboard, toasts, floating score pops and camera shake.
-- Built from code so the project has no asset dependencies.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "GooseHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local CREAM = Color3.fromRGB(255, 250, 235)
local INK = Color3.fromRGB(43, 36, 22)
local MUTED = Color3.fromRGB(122, 111, 90)
local ORANGE = Color3.fromRGB(240, 138, 36)
local GREEN = Color3.fromRGB(63, 154, 74)
local RED = Color3.fromRGB(211, 65, 43)

local function round(f: GuiObject, r: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = f
end

local function pill(name: string, pos: UDim2, size: UDim2): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.Position = pos
	f.Size = size
	f.BackgroundColor3 = CREAM
	f.BorderSizePixel = 0
	f.Parent = gui
	round(f, 22)
	return f
end

local function label(parent: Instance, name: string, text: string, size: UDim2, pos: UDim2, color: Color3?, font: Enum.Font?): TextLabel
	local t = Instance.new("TextLabel")
	t.Name = name
	t.Text = text
	t.Size = size
	t.Position = pos
	t.BackgroundTransparency = 1
	t.TextColor3 = color or INK
	t.Font = font or Enum.Font.FredokaOne
	t.TextScaled = true
	t.Parent = parent
	return t
end

-- Timer (top centre)
local timerPill = pill("Timer", UDim2.new(0.5, -90, 0, 12), UDim2.fromOffset(180, 44))
local phaseText = label(timerPill, "Phase", "WAITING", UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 10, 0, 0), MUTED, Enum.Font.GothamBold)
phaseText.TextXAlignment = Enum.TextXAlignment.Left
local timeText = label(timerPill, "Time", "0:00", UDim2.new(0.45, 0, 1, 0), UDim2.new(0.5, 0, 0, 0))

-- Role + stamina (top left)
local rolePill = pill("Role", UDim2.new(0, 12, 0, 12), UDim2.fromOffset(240, 44))
local roleText = label(rolePill, "Text", "Spectator", UDim2.new(0.55, 0, 1, 0), UDim2.new(0, 12, 0, 0))
roleText.TextXAlignment = Enum.TextXAlignment.Left
local stamBg = Instance.new("Frame")
stamBg.Name = "StaminaBg"
stamBg.Position = UDim2.new(0.6, 0, 0.5, -5)
stamBg.Size = UDim2.new(0.35, 0, 0, 10)
stamBg.BackgroundColor3 = Color3.fromRGB(216, 207, 184)
stamBg.BorderSizePixel = 0
stamBg.Parent = rolePill
local stamBar = Instance.new("Frame")
stamBar.Name = "Stamina"
stamBar.Size = UDim2.fromScale(1, 1)
stamBar.BackgroundColor3 = GREEN
stamBar.BorderSizePixel = 0
stamBar.Parent = stamBg
round(stamBg, 5)
round(stamBar, 5)

-- Prank list (left, under the role pill), tilted like a paper note
local note = Instance.new("Frame")
note.Name = "Pranks"
note.Position = UDim2.new(0, 14, 0, 68)
note.Size = UDim2.fromOffset(240, 40)
note.BackgroundColor3 = CREAM
note.BorderSizePixel = 0
note.Rotation = -1.5
note.Visible = false
note.Parent = gui
round(note, 10)
local noteList = Instance.new("UIListLayout")
noteList.SortOrder = Enum.SortOrder.LayoutOrder
noteList.Padding = UDim.new(0, 3)
noteList.Parent = note
local notePad = Instance.new("UIPadding")
notePad.PaddingTop = UDim.new(0, 8)
notePad.PaddingBottom = UDim.new(0, 10)
notePad.PaddingLeft = UDim.new(0, 12)
notePad.PaddingRight = UDim.new(0, 12)
notePad.Parent = note
local noteTitle = label(note, "Title", "To-do list", UDim2.new(1, 0, 0, 22), UDim2.new())
noteTitle.TextXAlignment = Enum.TextXAlignment.Left
noteTitle.LayoutOrder = 0
local taskRows: { [string]: TextLabel } = {}

Remotes.Tasks.OnClientEvent:Connect(function(list: { { id: string, text: string, done: boolean } })
	for i, t in list do
		local r: TextLabel = taskRows[t.id] or label(note, "Task_" .. t.id, "", UDim2.new(1, 0, 0, 18), UDim2.new(), INK, Enum.Font.GothamBold)
		if not taskRows[t.id] then
			r.TextXAlignment = Enum.TextXAlignment.Left
			r.LayoutOrder = i
			taskRows[t.id] = r
		end
		r.Text = (if t.done then "☑  " else "☐  ") .. t.text
		r.TextColor3 = if t.done then MUTED else INK
	end
	note.Size = UDim2.fromOffset(240, 18 + 22 + #list * 21)
	note.Visible = true
end)

-- Scoreboard (top right)
local board = Instance.new("Frame")
board.Name = "Scoreboard"
board.AnchorPoint = Vector2.new(1, 0)
board.Position = UDim2.new(1, -12, 0, 12)
board.Size = UDim2.fromOffset(220, 40)
board.BackgroundColor3 = CREAM
board.BorderSizePixel = 0
board.Parent = gui
round(board, 14)
local list = Instance.new("UIListLayout")
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Padding = UDim.new(0, 2)
list.Parent = board
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.Parent = board
local rows: { TextLabel } = {}

-- Controls hint (bottom left)
local hint = pill("Hint", UDim2.new(0, 12, 1, -60), UDim2.fromOffset(440, 40))
local hintText = label(hint, "Text", "E grab  •  Q drop  •  Space HONK  •  Shift sprint  •  your nest is safe", UDim2.new(1, -20, 1, 0), UDim2.new(0, 10, 0, 0), MUTED, Enum.Font.GothamBold)
hintText.TextXAlignment = Enum.TextXAlignment.Left

-- Toast (centre top)
local toast = pill("Toast", UDim2.new(0.5, -210, 0, 70), UDim2.fromOffset(420, 44))
toast.BackgroundColor3 = ORANGE
toast.Visible = false
local toastText = label(toast, "Text", "", UDim2.new(1, -24, 1, 0), UDim2.new(0, 12, 0, 0))
local toastToken = 0
Remotes.Toast.OnClientEvent:Connect(function(text: string)
	toastToken += 1
	local my = toastToken
	toastText.Text = text
	toast.Visible = true
	toast.BackgroundTransparency = 0
	toastText.TextTransparency = 0
	task.delay(2.4, function()
		if my == toastToken then
			TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(toastText, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
			task.delay(0.3, function()
				if my == toastToken then
					toast.Visible = false
				end
			end)
		end
	end)
end)

Remotes.Stamina.OnClientEvent:Connect(function(v: number)
	stamBar.Size = UDim2.fromScale(math.clamp(v, 0, 1), 1)
	stamBar.BackgroundColor3 = if v < 0.25 then RED else GREEN
end)

-- Floating score pops in the world
Remotes.Pop.OnClientEvent:Connect(function(position: Vector3, text: string, color: Color3?)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.Position = position
	anchor.Parent = workspace
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(200, 50)
	bb.AlwaysOnTop = true
	bb.Parent = anchor
	local t = label(bb, "Pop", text, UDim2.fromScale(1, 1), UDim2.new(), color or Color3.new(1, 1, 1))
	t.TextStrokeTransparency = 0
	t.TextStrokeColor3 = INK
	TweenService:Create(anchor, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = position + Vector3.new(0, 5, 0) }):Play()
	TweenService:Create(t, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.6), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(1.2, function()
		anchor:Destroy()
	end)
end)

-- Camera shake
local shake = 0
Remotes.Shake.OnClientEvent:Connect(function(strength: number)
	shake = math.max(shake, strength)
end)
RunService.RenderStepped:Connect(function(dt: number)
	if shake > 0.01 then
		local cam = workspace.CurrentCamera
		if cam then
			local s = shake * 0.6
			cam.CFrame = cam.CFrame * CFrame.new((math.random() - 0.5) * s, (math.random() - 0.5) * s, 0) * CFrame.Angles(0, 0, (math.random() - 0.5) * s * 0.04)
		end
		shake = math.max(0, shake - dt * 2.5)
	end
end)

-- Results card: stays up for the whole results phase so you can read it
local results = Instance.new("Frame")
results.Name = "Results"
results.AnchorPoint = Vector2.new(0.5, 0.5)
results.Position = UDim2.fromScale(0.5, 0.5)
results.Size = UDim2.fromOffset(460, 100)
results.BackgroundColor3 = CREAM
results.BorderSizePixel = 0
results.Visible = false
results.Parent = gui
round(results, 18)
local resultsList = Instance.new("UIListLayout")
resultsList.SortOrder = Enum.SortOrder.LayoutOrder
resultsList.Padding = UDim.new(0, 6)
resultsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
resultsList.Parent = results
local resultsPad = Instance.new("UIPadding")
resultsPad.PaddingTop = UDim.new(0, 16)
resultsPad.PaddingBottom = UDim.new(0, 14)
resultsPad.PaddingLeft = UDim.new(0, 18)
resultsPad.PaddingRight = UDim.new(0, 18)
resultsPad.Parent = results
local resTitle = label(results, "Title", "", UDim2.new(1, 0, 0, 40), UDim2.new(), ORANGE)
resTitle.LayoutOrder = 1
resTitle.TextStrokeTransparency = 0
resTitle.TextStrokeColor3 = INK
local resSub = label(results, "Sub", "", UDim2.new(1, 0, 0, 22), UDim2.new(), MUTED, Enum.Font.GothamBold)
resSub.LayoutOrder = 2
local resRows: { TextLabel } = {}
local resFoot = label(results, "Foot", "", UDim2.new(1, 0, 0, 18), UDim2.new(), MUTED, Enum.Font.GothamBold)
resFoot.LayoutOrder = 99
local resultsToken = 0

type ResultRow = { name: string, role: string, score: number, loot: number?, pranks: number?, scares: number?, honks: number?, caught: number?, catches: number?, returned: number? }
Remotes.Results.OnClientEvent:Connect(function(r: { winner: string, geeseWin: boolean, rows: { ResultRow }, seconds: number, totalPranks: number })
	resultsToken += 1
	local my = resultsToken
	resTitle.Text = if r.geeseWin then r.winner .. " wins! HONK." else r.winner .. " wins."
	resSub.Text = if r.geeseWin then "The geese ruined everyone's day." else "The village is safe. For now."
	for i, row in r.rows do
		local l: TextLabel = resRows[i] or label(results, "Row" .. i, "", UDim2.new(1, 0, 0, 44), UDim2.new(), INK, Enum.Font.GothamBold)
		if not resRows[i] then
			l.LayoutOrder = 10 + i
			l.TextXAlignment = Enum.TextXAlignment.Left
			l.TextScaled = false
			l.TextSize = 16
			l.TextWrapped = true
			resRows[i] = l
		end
		local mine = row.name == player.DisplayName
		if row.role == "keeper" then
			l.Text = string.format("🧢 %s  —  %d pts\n      %d catches  •  %d things put back", row.name, row.score, row.catches or 0, row.returned or 0)
		else
			l.Text = string.format("🪿 %s  —  %d pts\n      loot %d  •  pranks %d/%d  •  scares %d  •  honks %d  •  caught %d", row.name, row.score, row.loot or 0, row.pranks or 0, r.totalPranks, row.scares or 0, row.honks or 0, row.caught or 0)
		end
		l.TextColor3 = if mine then ORANGE else INK
		l.Visible = true
	end
	for i = #r.rows + 1, #resRows do
		resRows[i].Visible = false
	end
	results.Size = UDim2.fromOffset(460, 16 + 40 + 22 + #r.rows * 50 + 18 + 14 + 12)
	results.Visible = true
	-- countdown in the footer
	task.spawn(function()
		for left = r.seconds, 1, -1 do
			if my ~= resultsToken then
				return
			end
			resFoot.Text = "Next round in " .. left
			task.wait(1)
		end
		if my == resultsToken then
			results.Visible = false
		end
	end)
end)

type GameState = {
	phase: string,
	timeLeft: number,
	roles: { [string]: string },
	scores: { { name: string, role: string, score: number } },
}

Remotes.GameState.OnClientEvent:Connect(function(state: GameState)
	local t = math.floor(state.timeLeft)
	timeText.Text = string.format("%d:%02d", t // 60, t % 60)
	timeText.TextColor3 = if state.phase == "round" and t < 30 then RED else INK
	phaseText.Text = if state.phase == "round" then "ROUND" elseif state.phase == "results" then "RESULTS" else "NEXT ROUND"

	local role = state.roles[player.Name] or "spectator"
	if role == "goose" then
		roleText.Text = "🪿 Goose"
		hintText.Text = "E grab  •  Q drop  •  Space HONK  •  Shift sprint  •  your nest is safe"
	elseif role == "keeper" then
		roleText.Text = "🧢 Groundskeeper"
		hintText.Text = "Touch a goose to catch it  •  E on an item puts it back  •  walk onto a nest to raid it"
	else
		roleText.Text = "Spectator"
		hintText.Text = "Waiting for the next round"
	end
	stamBg.Visible = role == "goose"
	note.Visible = role == "goose" and state.phase == "round"
	if state.phase ~= "results" then
		results.Visible = false
	end

	for i, row in state.scores do
		local r: TextLabel = rows[i] or label(board, "Row" .. i, "", UDim2.new(1, 0, 0, 20), UDim2.new(), INK, Enum.Font.GothamBold)
		if not rows[i] then
			r.TextXAlignment = Enum.TextXAlignment.Left
			r.LayoutOrder = i
			rows[i] = r
		end
		local icon = if row.role == "keeper" then "🧢" else "🪿"
		r.Text = string.format("%s %s   %d", icon, row.name, row.score)
		r.TextColor3 = if row.name == player.DisplayName then ORANGE else INK
		r.Visible = true
	end
	for i = #state.scores + 1, #rows do
		rows[i].Visible = false
	end
	board.Size = UDim2.fromOffset(220, 16 + #state.scores * 22)
end)
