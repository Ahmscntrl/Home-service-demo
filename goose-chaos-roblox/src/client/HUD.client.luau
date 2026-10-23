--!strict
-- On-screen info: phase + timer, your role, stamina, scoreboard, toasts.
-- Built from code so the project has no asset dependencies.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local ORANGE = Color3.fromRGB(240, 138, 36)
local GREEN = Color3.fromRGB(63, 154, 74)
local RED = Color3.fromRGB(211, 65, 43)

local function pill(name: string, pos: UDim2, size: UDim2): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.Position = pos
	f.Size = size
	f.BackgroundColor3 = CREAM
	f.BorderSizePixel = 0
	f.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = f
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
local phaseText = label(timerPill, "Phase", "WAITING", UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 10, 0, 0), Color3.fromRGB(122, 111, 90), Enum.Font.GothamBold)
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
for _, f in { stamBg, stamBar } do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = f
end

-- Scoreboard (top right)
local board = Instance.new("Frame")
board.Name = "Scoreboard"
board.AnchorPoint = Vector2.new(1, 0)
board.Position = UDim2.new(1, -12, 0, 12)
board.Size = UDim2.fromOffset(220, 40)
board.BackgroundColor3 = CREAM
board.BorderSizePixel = 0
board.Parent = gui
local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(0, 14)
bc.Parent = board
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
local hint = pill("Hint", UDim2.new(0, 12, 1, -60), UDim2.fromOffset(420, 40))
local hintText = label(hint, "Text", "E grab  •  Q drop  •  Space HONK  •  Shift sprint  •  bank at your nest", UDim2.new(1, -20, 1, 0), UDim2.new(0, 10, 0, 0), Color3.fromRGB(122, 111, 90), Enum.Font.GothamBold)
hintText.TextXAlignment = Enum.TextXAlignment.Left

-- Toast (centre top)
local toast = pill("Toast", UDim2.new(0.5, -200, 0, 70), UDim2.fromOffset(400, 44))
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
	task.delay(2.2, function()
		if my == toastToken then
			TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
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
		hintText.Text = "E grab  •  Q drop  •  Space HONK  •  Shift sprint  •  bank at your nest"
	elseif role == "keeper" then
		roleText.Text = "🧢 Groundskeeper"
		hintText.Text = "Touch a goose to catch it  •  E on an item puts it back  •  walk onto a nest to raid it"
	else
		roleText.Text = "Spectator"
		hintText.Text = "Waiting for the next round"
	end
	stamBg.Visible = role == "goose"

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
