-- Remote Spy + Trigger (Stable Version)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

repeat task.wait() until player
repeat task.wait() until player:FindFirstChild("PlayerGui")
repeat task.wait() until player.Character

--------------------------------------------------
-- Wait for at least one remote
--------------------------------------------------

task.spawn(function()
	while true do
		if RS:FindFirstChildWhichIsA("RemoteEvent", true)
		or RS:FindFirstChildWhichIsA("RemoteFunction", true) then
			break
		end
		task.wait(1)
	end
end)

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,850,0,480)
main.Position = UDim2.new(0.5,-425,0.5,-240)
main.BackgroundColor3 = Color3.fromRGB(20,20,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

--------------------------------------------------
-- Title
--------------------------------------------------

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(30,30,40)
title.Text = "Remote Spy & Trigger  |  Insert = Toggle"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BorderSizePixel = 0

--------------------------------------------------
-- Search
--------------------------------------------------

local search = Instance.new("TextBox", main)
search.Size = UDim2.new(1,-20,0,32)
search.Position = UDim2.new(0,10,0,45)
search.PlaceholderText = "Search remotes..."
search.BackgroundColor3 = Color3.fromRGB(35,35,40)
search.TextColor3 = Color3.new(1,1,1)
search.Font = Enum.Font.Gotham
search.TextSize = 14
search.BorderSizePixel = 0

Instance.new("UICorner", search)

--------------------------------------------------
-- List
--------------------------------------------------

local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,10,0,85)
list.Size = UDim2.new(0.45,-15,1,-95)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarThickness = 5
list.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,4)

--------------------------------------------------
-- Info
--------------------------------------------------

local info = Instance.new("TextLabel", main)
info.Position = UDim2.new(0.45,10,0,85)
info.Size = UDim2.new(0.55,-20,0,120)
info.BackgroundColor3 = Color3.fromRGB(25,25,30)
info.TextWrapped = true
info.Text = "Select a Remote"
info.TextColor3 = Color3.new(1,1,1)
info.Font = Enum.Font.Gotham
info.TextSize = 14
info.BorderSizePixel = 0

Instance.new("UICorner", info)

--------------------------------------------------
-- Input
--------------------------------------------------

local input = Instance.new("TextBox", main)
input.Position = UDim2.new(0.45,10,0,215)
input.Size = UDim2.new(0.55,-20,0,40)
input.PlaceholderText = "Args: 1,true,hello"
input.BackgroundColor3 = Color3.fromRGB(35,35,40)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.BorderSizePixel = 0

Instance.new("UICorner", input)

--------------------------------------------------
-- Run
--------------------------------------------------

local run = Instance.new("TextButton", main)
run.Position = UDim2.new(0.45,10,0,265)
run.Size = UDim2.new(0.55,-20,0,45)
run.Text = "Fire / Invoke"
run.BackgroundColor3 = Color3.fromRGB(70,120,200)
run.TextColor3 = Color3.new(1,1,1)
run.Font = Enum.Font.GothamBold
run.TextSize = 15
run.BorderSizePixel = 0

Instance.new("UICorner", run)

--------------------------------------------------
-- Logic
--------------------------------------------------

local remotes = {}
local selected

--------------------------------------------------
-- Parse Args
--------------------------------------------------

local function parseArgs(txt)

	local args = {}

	for part in string.gmatch(txt,"[^,]+") do

		part = part:match("^%s*(.-)%s*$")

		if tonumber(part) then
			table.insert(args, tonumber(part))

		elseif part == "true" then
			table.insert(args,true)

		elseif part == "false" then
			table.insert(args,false)

		else
			table.insert(args,part)
		end
	end

	return args
end

--------------------------------------------------
-- Scan
--------------------------------------------------

local function scan()

	for _,v in ipairs(list:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	remotes = {}

	for _,obj in ipairs(game:GetDescendants()) do

		if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then

			table.insert(remotes,obj)

			local b = Instance.new("TextButton", list)

			b.Size = UDim2.new(1,-6,0,28)
			b.Text = "["..obj.ClassName.."] "..obj:GetFullName()
			b.BackgroundColor3 = Color3.fromRGB(35,35,40)
			b.TextColor3 = Color3.new(1,1,1)
			b.Font = Enum.Font.Gotham
			b.TextSize = 12
			b.BorderSizePixel = 0

			Instance.new("UICorner", b)

			b.MouseButton1Click:Connect(function()

				selected = obj

				info.Text =
					"Name: "..obj.Name..
					"\nType: "..obj.ClassName..
					"\nPath:\n"..obj:GetFullName()
			end)
		end
	end

	task.wait()

	list.CanvasSize =
		UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

--------------------------------------------------
-- Filter
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
-- Run
--------------------------------------------------

run.MouseButton1Click:Connect(function()

	if not selected then return end

	local args = parseArgs(input.Text)

	if selected:IsA("RemoteEvent") then

		selected:FireServer(unpack(args))

	elseif selected:IsA("RemoteFunction") then

		selected:InvokeServer(unpack(args))
	end
end)

--------------------------------------------------
-- Toggle
--------------------------------------------------

UIS.InputBegan:Connect(function(i,g)

	if g then return end

	if i.KeyCode == Enum.KeyCode.Insert then
		main.Visible = not main.Visible
	end
end)

--------------------------------------------------
-- Auto Refresh
--------------------------------------------------

task.spawn(function()

	while true do
		task.wait(5)
		scan()
	end

end)

--------------------------------------------------
-- Init
--------------------------------------------------

task.wait(2)
scan()
