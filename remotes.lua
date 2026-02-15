-- Simple Remote Spy + Trigger UI
-- Loadstring Ready

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
repeat task.wait() until player and player:FindFirstChild("PlayerGui")

------------------------------------------------
-- GUI
------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "RemoteTool"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,900,0,500)
main.Position = UDim2.new(0.5,-450,0.5,-250)
main.BackgroundColor3 = Color3.fromRGB(20,20,25)
main.BorderSizePixel = 0
main.Visible = true
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

------------------------------------------------
-- Title
------------------------------------------------

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(30,30,40)
title.Text = "Remote Spy & Trigger   (Insert = Toggle)"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.BorderSizePixel = 0

------------------------------------------------
-- Panels
------------------------------------------------

local function makePanel(x)

	local f = Instance.new("Frame", main)
	f.Position = UDim2.new(0,x,0,50)
	f.Size = UDim2.new(0,280,1,-60)
	f.BackgroundColor3 = Color3.fromRGB(25,25,30)
	f.BorderSizePixel = 0

	Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)

	return f
end

local spyPanel = makePanel(10)
local listPanel = makePanel(310)
local controlPanel = makePanel(610)

------------------------------------------------
-- Scrolling Frames
------------------------------------------------

local function makeScroll(parent)

	local s = Instance.new("ScrollingFrame", parent)
	s.Size = UDim2.new(1,-10,1,-10)
	s.Position = UDim2.new(0,5,0,5)
	s.CanvasSize = UDim2.new(0,0,0,0)
	s.ScrollBarThickness = 5
	s.BackgroundTransparency = 1
	s.BorderSizePixel = 0

	local l = Instance.new("UIListLayout", s)
	l.Padding = UDim.new(0,4)

	return s,l
end

local spyList, spyLayout = makeScroll(spyPanel)
local remoteList, remoteLayout = makeScroll(listPanel)

------------------------------------------------
-- Controls
------------------------------------------------

local info = Instance.new("TextLabel", controlPanel)
info.Size = UDim2.new(1,-10,0,80)
info.Position = UDim2.new(0,5,0,5)
info.BackgroundTransparency = 1
info.Text = "Select a Remote"
info.TextWrapped = true
info.TextColor3 = Color3.new(1,1,1)
info.Font = Enum.Font.Gotham
info.TextSize = 14

local input = Instance.new("TextBox", controlPanel)
input.Size = UDim2.new(1,-10,0,40)
input.Position = UDim2.new(0,5,0,90)
input.PlaceholderText = "Args: 1,true,hello"
input.BackgroundColor3 = Color3.fromRGB(35,35,40)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.BorderSizePixel = 0

Instance.new("UICorner", input).CornerRadius = UDim.new(0,6)

local runBtn = Instance.new("TextButton", controlPanel)
runBtn.Size = UDim2.new(1,-10,0,45)
runBtn.Position = UDim2.new(0,5,0,145)
runBtn.Text = "Fire / Invoke"
runBtn.BackgroundColor3 = Color3.fromRGB(70,120,200)
runBtn.TextColor3 = Color3.new(1,1,1)
runBtn.Font = Enum.Font.GothamBold
runBtn.TextSize = 16
runBtn.BorderSizePixel = 0

Instance.new("UICorner", runBtn).CornerRadius = UDim.new(0,6)

------------------------------------------------
-- Logic
------------------------------------------------

local selected
local remotes = {}

------------------------------------------------
-- Arg Parser
------------------------------------------------

local function parseArgs(txt)

	local args = {}

	for part in string.gmatch(txt,"[^,]+") do

		part = part:match("^%s*(.-)%s*$")

		if tonumber(part) then
			table.insert(args, tonumber(part))

		elseif part == "true" then
			table.insert(args, true)

		elseif part == "false" then
			table.insert(args, false)

		else
			table.insert(args, part)
		end
	end

	return args
end

------------------------------------------------
-- Spy Logger
------------------------------------------------

local function log(text)

	local l = Instance.new("TextLabel", spyList)
	l.Size = UDim2.new(1,-6,0,22)
	l.BackgroundTransparency = 1
	l.TextWrapped = true
	l.TextXAlignment = Left
	l.Text = text
	l.TextColor3 = Color3.fromRGB(200,200,200)
	l.Font = Enum.Font.Gotham
	l.TextSize = 12

	task.wait()

	spyList.CanvasSize = UDim2.new(0,0,0,spyLayout.AbsoluteContentSize.Y+10)
	spyList.CanvasPosition = Vector2.new(0,math.max(0,spyList.CanvasSize.Y.Offset-200))
end

------------------------------------------------
-- Remote Scan
------------------------------------------------

local function scan()

	remotes = {}

	for _,v in ipairs(remoteList:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _,obj in ipairs(game:GetDescendants()) do

		if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
			table.insert(remotes, obj)
		end
	end

	for i,r in ipairs(remotes) do

		local b = Instance.new("TextButton", remoteList)

		b.Size = UDim2.new(1,-6,0,28)
		b.Text = "["..r.ClassName.."] "..r.Name
		b.BackgroundColor3 = Color3.fromRGB(35,35,40)
		b.TextColor3 = Color3.new(1,1,1)
		b.Font = Enum.Font.Gotham
		b.TextSize = 13
		b.BorderSizePixel = 0

		Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

		b.MouseButton1Click:Connect(function()

			selected = r

			info.Text =
				"Name: "..r.Name..
				"\nType: "..r.ClassName..
				"\nPath:\n"..r:GetFullName()
		end)
	end

	task.wait()

	remoteList.CanvasSize = UDim2.new(0,0,0,remoteLayout.AbsoluteContentSize.Y+10)
end

------------------------------------------------
-- Hook Remotes (Spy)
------------------------------------------------

local mt = getrawmetatable(game)
setreadonly(mt,false)

local old = mt.__namecall

mt.__namecall = newcclosure(function(self,...)

	local method = getnamecallmethod()
	local args = {...}

	if method == "FireServer" or method == "InvokeServer" then

		log(method.." -> "..self:GetFullName())
	end

	return old(self,...)
end)

------------------------------------------------
-- Run Button
------------------------------------------------

runBtn.MouseButton1Click:Connect(function()

	if not selected then return end

	local args = parseArgs(input.Text)

	if selected:IsA("RemoteEvent") then

		selected:FireServer(unpack(args))
		log("Manual Fire: "..selected.Name)

	elseif selected:IsA("RemoteFunction") then

		local res = selected:InvokeServer(unpack(args))
		log("Manual Invoke: "..selected.Name.." | "..tostring(res))
	end
end)

------------------------------------------------
-- Toggle (Insert)
------------------------------------------------

UIS.InputBegan:Connect(function(i,g)

	if g then return end

	if i.KeyCode == Enum.KeyCode.Insert then

		main.Visible = not main.Visible
	end
end)

------------------------------------------------
-- Init
------------------------------------------------

task.wait(1)
scan()
log("Remote tool loaded")
