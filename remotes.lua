local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
repeat task.wait() until player
repeat task.wait() until player:FindFirstChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "RemotesLarping"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,900,0,520)
main.Position = UDim2.new(0.5,-450,0.5,-260)
main.BackgroundColor3 = Color3.fromRGB(18,18,22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,45)
header.BackgroundColor3 = Color3.fromRGB(28,28,35)
header.BorderSizePixel = 0

Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "remotes.lua  |  by larpingrentals   (Insert = Toggle)"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local search = Instance.new("TextBox", main)
search.Position = UDim2.new(0,15,0,55)
search.Size = UDim2.new(1,-30,0,32)
search.PlaceholderText = "Search name / path / player..."
search.BackgroundColor3 = Color3.fromRGB(32,32,38)
search.TextColor3 = Color3.new(1,1,1)
search.Font = Enum.Font.Gotham
search.TextSize = 14
search.BorderSizePixel = 0

Instance.new("UICorner", search)

local listFrame = Instance.new("ScrollingFrame", main)
listFrame.Position = UDim2.new(0,15,0,95)
listFrame.Size = UDim2.new(0.5,-20,1,-110)
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.ScrollBarThickness = 6
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel = 0

local listLayout = Instance.new("UIListLayout", listFrame)
listLayout.Padding = UDim.new(0,5)

local infoFrame = Instance.new("Frame", main)
infoFrame.Position = UDim2.new(0.5,10,0,95)
infoFrame.Size = UDim2.new(0.5,-25,1,-110)
infoFrame.BackgroundColor3 = Color3.fromRGB(24,24,30)
infoFrame.BorderSizePixel = 0

Instance.new("UICorner", infoFrame)

local info = Instance.new("TextLabel", infoFrame)
info.Position = UDim2.new(0,10,0,10)
info.Size = UDim2.new(1,-20,0,160)
info.BackgroundTransparency = 1
info.TextWrapped = true
info.TextYAlignment = Top
info.Text = "Select a remote"
info.TextColor3 = Color3.new(1,1,1)
info.Font = Enum.Font.Gotham
info.TextSize = 14

local input = Instance.new("TextBox", infoFrame)
input.Position = UDim2.new(0,10,0,180)
input.Size = UDim2.new(1,-20,0,40)
input.PlaceholderText = "Arguments: 1,true,hello"
input.BackgroundColor3 = Color3.fromRGB(35,35,42)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.BorderSizePixel = 0

Instance.new("UICorner", input)

local run = Instance.new("TextButton", infoFrame)
run.Position = UDim2.new(0,10,0,235)
run.Size = UDim2.new(1,-20,0,45)
run.Text = "Fire / Invoke"
run.BackgroundColor3 = Color3.fromRGB(75,120,200)
run.TextColor3 = Color3.new(1,1,1)
run.Font = Enum.Font.GothamBold
run.TextSize = 15
run.BorderSizePixel = 0

Instance.new("UICorner", run)

local remoteMap = {}
local selected

local function getOwner(obj)

	local p = obj:FindFirstAncestorOfClass("Player")

	if p then
		return "Player: "..p.Name
	end

	return "Global"
end

local function parseArgs(text)

	local args = {}

	for part in string.gmatch(text,"[^,]+") do

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

local function addRemote(obj)

	if remoteMap[obj] then return end
	remoteMap[obj] = true

	local owner = getOwner(obj)
	local path = obj:GetFullName()

	local button = Instance.new("TextButton", listFrame)

	button.Size = UDim2.new(1,-8,0,30)
	button.Text = "["..obj.ClassName.."] "..obj.Name.."  |  "..owner
	button.TextXAlignment = Left
	button.BackgroundColor3 = Color3.fromRGB(35,35,42)
	button.TextColor3 = Color3.new(1,1,1)
	button.Font = Enum.Font.Gotham
	button.TextSize = 13
	button.BorderSizePixel = 0

	Instance.new("UICorner", button)

	button.MouseButton1Click:Connect(function()

		selected = obj

		info.Text =
			"Name: "..obj.Name..
			"\nType: "..obj.ClassName..
			"\nOwner: "..owner..
			"\n\nPath:\n"..path
	end)

	task.wait()

	listFrame.CanvasSize =
		UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y+10)
end

task.spawn(function()

	while true do

		for _,v in ipairs(game:GetDescendants()) do

			if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
				addRemote(v)
			end
		end

		task.wait(2)
	end
end)

search:GetPropertyChangedSignal("Text"):Connect(function()

	local q = search.Text:lower()

	for _,b in ipairs(listFrame:GetChildren()) do

		if b:IsA("TextButton") then

			b.Visible =
				b.Text:lower():find(q) ~= nil
		end
	end
end)

run.MouseButton1Click:Connect(function()

	if not selected then return end

	local args = parseArgs(input.Text)

	if selected:IsA("RemoteEvent") then

		selected:FireServer(unpack(args))

	elseif selected:IsA("RemoteFunction") then

		selected:InvokeServer(unpack(args))
	end
end)

UIS.InputBegan:Connect(function(i,g)

	if g then return end

	if i.KeyCode == Enum.KeyCode.Insert then

		main.Visible = not main.Visible
	end
end)
