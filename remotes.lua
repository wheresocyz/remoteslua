repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

------------------------------------------------
-- GUI
------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "RemotesLua"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = Gui
Main.Size = UDim2.new(0,800,0,500)
Main.Position = UDim2.new(0.5,-400,0.5,-250)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,12)

------------------------------------------------
-- Header
------------------------------------------------

local Header = Instance.new("Frame",Main)
Header.Size = UDim2.new(1,0,0,40)
Header.BackgroundColor3 = Color3.fromRGB(30,30,36)
Header.BorderSizePixel = 0

Instance.new("UICorner",Header).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel",Header)
Title.Size = UDim2.new(1,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = "remotes.lua | larpingrentals  (Insert = Toggle)"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Color3.new(1,1,1)

------------------------------------------------
-- Search
------------------------------------------------

local Search = Instance.new("TextBox",Main)
Search.Position = UDim2.new(0,10,0,50)
Search.Size = UDim2.new(1,-20,0,32)
Search.PlaceholderText = "Search remotes..."
Search.BackgroundColor3 = Color3.fromRGB(35,35,42)
Search.TextColor3 = Color3.new(1,1,1)
Search.Font = Enum.Font.Gotham
Search.TextSize = 13
Search.BorderSizePixel = 0

Instance.new("UICorner",Search)

------------------------------------------------
-- List
------------------------------------------------

local List = Instance.new("ScrollingFrame",Main)
List.Position = UDim2.new(0,10,0,90)
List.Size = UDim2.new(0.5,-15,1,-100)
List.CanvasSize = UDim2.new(0,0,0,0)
List.ScrollBarThickness = 6
List.BackgroundTransparency = 1
List.BorderSizePixel = 0

local Layout = Instance.new("UIListLayout",List)
Layout.Padding = UDim.new(0,5)

------------------------------------------------
-- Info Panel
------------------------------------------------

local InfoPanel = Instance.new("Frame",Main)
InfoPanel.Position = UDim2.new(0.5,5,0,90)
InfoPanel.Size = UDim2.new(0.5,-15,1,-100)
InfoPanel.BackgroundColor3 = Color3.fromRGB(26,26,32)
InfoPanel.BorderSizePixel = 0

Instance.new("UICorner",InfoPanel)

local Info = Instance.new("TextLabel",InfoPanel)
Info.Position = UDim2.new(0,10,0,10)
Info.Size = UDim2.new(1,-20,0,150)
Info.BackgroundTransparency = 1
Info.TextWrapped = true
Info.TextYAlignment = Top
Info.Font = Enum.Font.Gotham
Info.TextSize = 13
Info.TextColor3 = Color3.new(1,1,1)
Info.Text = "Select a remote"

------------------------------------------------
-- Args
------------------------------------------------

local Args = Instance.new("TextBox",InfoPanel)
Args.Position = UDim2.new(0,10,0,170)
Args.Size = UDim2.new(1,-20,0,40)
Args.PlaceholderText = "Arguments: 1,true,hello"
Args.BackgroundColor3 = Color3.fromRGB(36,36,44)
Args.TextColor3 = Color3.new(1,1,1)
Args.Font = Enum.Font.Gotham
Args.TextSize = 13
Args.BorderSizePixel = 0

Instance.new("UICorner",Args)

------------------------------------------------
-- Run Button
------------------------------------------------

local Run = Instance.new("TextButton",InfoPanel)
Run.Position = UDim2.new(0,10,0,220)
Run.Size = UDim2.new(1,-20,0,45)
Run.Text = "Fire / Invoke"
Run.BackgroundColor3 = Color3.fromRGB(80,130,220)
Run.TextColor3 = Color3.new(1,1,1)
Run.Font = Enum.Font.GothamBold
Run.TextSize = 14
Run.BorderSizePixel = 0

Instance.new("UICorner",Run)

------------------------------------------------
-- Logic
------------------------------------------------

local Remotes = {}
local Selected = nil

------------------------------------------------
-- Utils
------------------------------------------------

local function ParseArgs(text)

	local args = {}

	for part in string.gmatch(text,"[^,]+") do

		part = part:match("^%s*(.-)%s*$")

		if tonumber(part) then
			table.insert(args,tonumber(part))

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

------------------------------------------------
-- Add Remote
------------------------------------------------

local function AddRemote(obj)

	if Remotes[obj] then return end
	Remotes[obj] = true

	local Button = Instance.new("TextButton",List)

	Button.Size = UDim2.new(1,-6,0,28)
	Button.TextXAlignment = Left
	Button.Text = "["..obj.ClassName.."] "..obj:GetFullName()
	Button.BackgroundColor3 = Color3.fromRGB(38,38,45)
	Button.TextColor3 = Color3.new(1,1,1)
	Button.Font = Enum.Font.Gotham
	Button.TextSize = 12
	Button.BorderSizePixel = 0

	Instance.new("UICorner",Button)

	Button.MouseButton1Click:Connect(function()

		Selected = obj

		Info.Text =
			"Name: "..obj.Name..
			"\nType: "..obj.ClassName..
			"\n\nPath:\n"..obj:GetFullName()
	end)

	task.wait()

	List.CanvasSize =
		UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+5)
end

------------------------------------------------
-- Scan
------------------------------------------------

local function Scan()

	for _,v in ipairs(game:GetDescendants()) do

		if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
			AddRemote(v)
		end
	end
end

Scan()

game.DescendantAdded:Connect(function(obj)

	if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
		AddRemote(obj)
	end
end)

------------------------------------------------
-- Search Filter
------------------------------------------------

Search:GetPropertyChangedSignal("Text"):Connect(function()

	local q = Search.Text:lower()

	for _,b in ipairs(List:GetChildren()) do

		if b:IsA("TextButton") then

			b.Visible =
				b.Text:lower():find(q) ~= nil
		end
	end
end)

------------------------------------------------
-- Run
------------------------------------------------

Run.MouseButton1Click:Connect(function()

	if not Selected then return end

	local args = ParseArgs(Args.Text)

	if Selected:IsA("RemoteEvent") then

		Selected:FireServer(unpack(args))

	elseif Selected:IsA("RemoteFunction") then

		pcall(function()
			Selected:InvokeServer(unpack(args))
		end)
	end
end)

------------------------------------------------
-- Toggle
------------------------------------------------

UIS.InputBegan:Connect(function(i,g)

	if g then return end

	if i.KeyCode == Enum.KeyCode.Insert then

		Main.Visible = not Main.Visible
	end
end)
