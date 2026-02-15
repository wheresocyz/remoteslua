local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")

local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
repeat task.wait() until player
repeat task.wait() until player:FindFirstChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "RemotesUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,850,0,500)
main.Position = UDim2.new(0.5,-425,0.5,-250)
main.BackgroundColor3 = Color3.fromRGB(20,20,24)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(30,30,36)
title.Text = "remotes.lua | larpingrentals"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 15

Instance.new("UICorner", title).CornerRadius = UDim.new(0,10)

local search = Instance.new("TextBox", main)
search.Position = UDim2.new(0,10,0,50)
search.Size = UDim2.new(1,-20,0,32)
search.PlaceholderText = "Search..."
search.BackgroundColor3 = Color3.fromRGB(35,35,40)
search.TextColor3 = Color3.new(1,1,1)
search.BorderSizePixel = 0
search.Font = Enum.Font.Gotham
search.TextSize = 14

Instance.new("UICorner", search)

local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,10,0,90)
list.Size = UDim2.new(0.45,-15,1,-100)
list.ScrollBarThickness = 6
list.BackgroundTransparency = 1
list.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,6)

local info = Instance.new("TextLabel", main)
info.Position = UDim2.new(0.45,5,0,90)
info.Size = UDim2.new(0.55,-15,0,200)
info.BackgroundTransparency = 1
info.TextWrapped = true
info.TextYAlignment = Top
info.Text = "Select a remote"
info.TextColor3 = Color3.new(1,1,1)
info.Font = Enum.Font.Gotham
info.TextSize = 14

local args = Instance.new("TextBox", main)
args.Position = UDim2.new(0.45,5,0,300)
args.Size = UDim2.new(0.55,-15,0,36)
args.PlaceholderText = "Arguments: 1,true,test"
args.BackgroundColor3 = Color3.fromRGB(35,35,40)
args.TextColor3 = Color3.new(1,1,1)
args.BorderSizePixel = 0
args.Font = Enum.Font.Gotham
args.TextSize = 14

Instance.new("UICorner", args)

local fire = Instance.new("TextButton", main)
fire.Position = UDim2.new(0.45,5,0,350)
fire.Size = UDim2.new(0.55,-15,0,42)
fire.Text = "Fire / Invoke"
fire.BackgroundColor3 = Color3.fromRGB(70,120,200)
fire.TextColor3 = Color3.new(1,1,1)
fire.BorderSizePixel = 0
fire.Font = Enum.Font.GothamBold
fire.TextSize = 15

Instance.new("UICorner", fire)

local remoteList = {}
local selected

local function parse(text)

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

local function clear()

	for _,v in ipairs(list:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
end

local function refresh()

	clear()
	remoteList = {}

	for _,v in ipairs(game:GetDescendants()) do

		if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
			table.insert(remoteList,v)
		end
	end

	for i,r in ipairs(remoteList) do

		local b = Instance.new("TextButton", list)

		b.Size = UDim2.new(1,-6,0,32)
		b.Text = "["..r.ClassName.."] "..r.Name
		b.TextXAlignment = Left
		b.BackgroundColor3 = Color3.fromRGB(35,35,42)
		b.TextColor3 = Color3.new(1,1,1)
		b.BorderSizePixel = 0
		b.Font = Enum.Font.Gotham
		b.TextSize = 13

		Instance.new("UICorner", b)

		b.MouseButton1Click:Connect(function()

			selected = r

			info.Text =
				"Name: "..r.Name..
				"\nType: "..r.ClassName..
				"\n\nPath:\n"..r:GetFullName()
		end)
	end

	task.wait()

	list.CanvasSize =
		UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

task.spawn(function()

	while true do

		refresh()
		task.wait(3)
	end
end)

search:GetPropertyChangedSignal("Text"):Connect(function()

	local q = search.Text:lower()

	for _,b in ipairs(list:GetChildren()) do

		if b:IsA("TextButton") then

			b.Visible =
				b.Text:lower():find(q) ~= nil
		end
	end
end)

fire.MouseButton1Click:Connect(function()

	if not selected then return end

	local a = parse(args.Text)

	if selected:IsA("RemoteEvent") then

		selected:FireServer(unpack(a))

	else

		selected:InvokeServer(unpack(a))
	end
end)

local function toggle()

	main.Visible = not main.Visible
	return Enum.ContextActionResult.Sink
end

CAS:BindAction(
	"ToggleRemotes",
	toggle,
	false,
	Enum.KeyCode.Insert,
	Enum.KeyCode.RightShift
)
