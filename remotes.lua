local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")

local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
repeat task.wait() until player
repeat task.wait() until player:FindFirstChild("PlayerGui")

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "RemoteToolV2"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0,800,0,480)
main.Position = UDim2.new(0.5,-400,0.5,-240)
main.BackgroundColor3 = Color3.fromRGB(22,22,26)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

--------------------------------------------------
-- Top Bar
--------------------------------------------------

local top = Instance.new("Frame")
top.Parent = main
top.Size = UDim2.new(1,0,0,40)
top.BackgroundColor3 = Color3.fromRGB(32,32,38)
top.BorderSizePixel = 0

Instance.new("UICorner", top).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Parent = top
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "remotes.lua  |  larpingrentals"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 15

--------------------------------------------------
-- Search
--------------------------------------------------

local search = Instance.new("TextBox")
search.Parent = main
search.Position = UDim2.new(0,10,0,50)
search.Size = UDim2.new(1,-20,0,32)
search.PlaceholderText = "Search remotes..."
search.BackgroundColor3 = Color3.fromRGB(35,35,40)
search.TextColor3 = Color3.new(1,1,1)
search.BorderSizePixel = 0
search.Font = Enum.Font.Gotham
search.TextSize = 14

Instance.new("UICorner", search)

--------------------------------------------------
-- List
--------------------------------------------------

local list = Instance.new("ScrollingFrame")
list.Parent = main
list.Position = UDim2.new(0,10,0,90)
list.Size = UDim2.new(0.45,-10,1,-100)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,6)

--------------------------------------------------
-- Right Panel
--------------------------------------------------

local panel = Instance.new("Frame")
panel.Parent = main
panel.Position = UDim2.new(0.45,10,0,90)
panel.Size = UDim2.new(0.55,-20,1,-100)
panel.BackgroundColor3 = Color3.fromRGB(28,28,34)
panel.BorderSizePixel = 0

Instance.new("UICorner", panel)

--------------------------------------------------
-- Info
--------------------------------------------------

local info = Instance.new("TextLabel")
info.Parent = panel
info.Position = UDim2.new(0,10,0,10)
info.Size = UDim2.new(1,-20,0,160)
info.BackgroundTransparency = 1
info.TextWrapped = true
info.TextYAlignment = Top
info.Text = "Select a remote"
info.TextColor3 = Color3.new(1,1,1)
info.Font = Enum.Font.Gotham
info.TextSize = 14

--------------------------------------------------
-- Arguments
--------------------------------------------------

local argsBox = Instance.new("TextBox")
argsBox.Parent = panel
argsBox.Position = UDim2.new(0,10,0,180)
argsBox.Size = UDim2.new(1,-20,0,36)
argsBox.PlaceholderText = "Arguments: 1,true,hello"
argsBox.BackgroundColor3 = Color3.fromRGB(38,38,44)
argsBox.TextColor3 = Color3.new(1,1,1)
argsBox.BorderSizePixel = 0
argsBox.Font = Enum.Font.Gotham
argsBox.TextSize = 14

Instance.new("UICorner", argsBox)

--------------------------------------------------
-- Fire Button
--------------------------------------------------

local fire = Instance.new("TextButton")
fire.Parent = panel
fire.Position = UDim2.new(0,10,0,230)
fire.Size = UDim2.new(1,-20,0,42)
fire.Text = "Fire / Invoke"
fire.BackgroundColor3 = Color3.fromRGB(70,120,200)
fire.TextColor3 = Color3.new(1,1,1)
fire.BorderSizePixel = 0
fire.Font = Enum.Font.GothamBold
fire.TextSize = 15

Instance.new("UICorner", fire)

--------------------------------------------------
-- Data
--------------------------------------------------

local remotes = {}
local selected = nil

--------------------------------------------------
-- Utils
--------------------------------------------------

local function parseArgs(text)

	local t = {}

	for p in string.gmatch(text,"[^,]+") do

		p = p:match("^%s*(.-)%s*$")

		if tonumber(p) then
			table.insert(t,tonumber(p))
		elseif p == "true" then
			table.insert(t,true)
		elseif p == "false" then
			table.insert(t,false)
		else
			table.insert(t,p)
		end
	end

	return t
end

--------------------------------------------------
-- UI Helpers
--------------------------------------------------

local function clearList()

	for _,v in ipairs(list:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
end

local function updateCanvas()

	task.wait()

	list.CanvasSize =
		UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

--------------------------------------------------
-- Build List
--------------------------------------------------

local function rebuild()

	clearList()
	remotes = {}

	for _,v in ipairs(game:GetDescendants()) do

		if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
			table.insert(remotes,v)
		end
	end

	for _,r in ipairs(remotes) do

		local btn = Instance.new("TextButton")
		btn.Parent = list
		btn.Size = UDim2.new(1,-6,0,32)
		btn.Text = "["..r.ClassName.."] "..r.Name
		btn.TextXAlignment = Left
		btn.BackgroundColor3 = Color3.fromRGB(36,36,42)
		btn.TextColor3 = Color3.new(1,1,1)
		btn.BorderSizePixel = 0
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13

		Instance.new("UICorner", btn)

		btn.MouseButton1Click:Connect(function()

			selected = r

			info.Text =
				"Name: "..r.Name..
				"\nType: "..r.ClassName..
				"\n\nPath:\n"..r:GetFullName()
		end)
	end

	updateCanvas()
end

--------------------------------------------------
-- Auto Refresh
--------------------------------------------------

task.spawn(function()

	while true do

		rebuild()
		task.wait(3)
	end
end)

--------------------------------------------------
-- Search
--------------------------------------------------

search:GetPropertyChangedSignal("Text"):Connect(function()

	local q = search.Text:lower()

	for _,b in ipairs(list:GetChildren()) do

		if b:IsA("TextButton") then

			b.Visible =
				b.Text:lower():find(q) ~= nil
		end
	end
end)

--------------------------------------------------
-- Fire
--------------------------------------------------

fire.MouseButton1Click:Connect(function()

	if not selected then return end

	local args = parseArgs(argsBox.Text)

	if selected:IsA("RemoteEvent") then

		selected:FireServer(unpack(args))

	elseif selected:IsA("RemoteFunction") then

		selected:InvokeServer(unpack(args))
	end
end)

--------------------------------------------------
-- Toggle
--------------------------------------------------

local function toggle()

	main.Visible = not main.Visible
	return Enum.ContextActionResult.Sink
end

CAS:BindAction(
	"RemoteToolToggle",
	toggle,
	false,
	Enum.KeyCode.Insert,
	Enum.KeyCode.RightShift
)

--------------------------------------------------
-- REMOTE SPY
--------------------------------------------------

local SpyEnabled = true

local LogFrame = Instance.new("Frame")
LogFrame.Parent = main
LogFrame.Position = UDim2.new(0,0,1,5)
LogFrame.Size = UDim2.new(1,0,0,160)
LogFrame.BackgroundColor3 = Color3.fromRGB(18,18,22)
LogFrame.BorderSizePixel = 0
LogFrame.Visible = true

Instance.new("UICorner", LogFrame)

local LogList = Instance.new("ScrollingFrame")
LogList.Parent = LogFrame
LogList.Size = UDim2.new(1,-10,1,-10)
LogList.Position = UDim2.new(0,5,0,5)
LogList.CanvasSize = UDim2.new(0,0,0,0)
LogList.ScrollBarThickness = 5
LogList.BackgroundTransparency = 1

local LogLayout = Instance.new("UIListLayout")
LogLayout.Parent = LogList
LogLayout.Padding = UDim.new(0,4)

local function addLog(text)

	local label = Instance.new("TextLabel")

	label.Parent = LogList
	label.Size = UDim2.new(1,-5,0,22)
	label.BackgroundTransparency = 1
	label.TextWrapped = false
	label.TextXAlignment = Left
	label.Text = text
	label.Font = Enum.Font.Code
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(180,220,255)

	task.wait()

	LogList.CanvasSize =
		UDim2.new(0,0,0,LogLayout.AbsoluteContentSize.Y+5)

	LogList.CanvasPosition =
		Vector2.new(0,LogList.CanvasSize.Y.Offset)
end

--------------------------------------------------
-- Hook
--------------------------------------------------

local mt = getrawmetatable(game)
local old = mt.__namecall

setreadonly(mt,false)

mt.__namecall = newcclosure(function(self,...)

	local method = getnamecallmethod()
	local args = {...}

	if SpyEnabled then

		if method == "FireServer" or method == "InvokeServer" then

			local msg = "["..method.."] "..self:GetFullName()

			for i,v in ipairs(args) do
				msg = msg.." | "..tostring(v)
			end

			addLog(msg)
		end
	end

	return old(self,...)
end)

setreadonly(mt,true)

