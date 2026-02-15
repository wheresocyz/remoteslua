local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local items = {}
local filtered = {}
local selected = nil
local favorites = {}
local logs = {}

local visible = true
local minimized = false
local currentTab = "All"


local gui = Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false


local main = Instance.new("Frame",gui)
main.Size = UDim2.new(0,760,0,520)
main.Position = UDim2.new(0.5,-380,0.5,-260)
main.BackgroundColor3 = Color3.fromRGB(18,18,24)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner",main).CornerRadius = UDim.new(0,14)


local shadow = Instance.new("ImageLabel",main)
shadow.AnchorPoint = Vector2.new(0.5,0.5)
shadow.Position = UDim2.new(0.5,0,0.5,0)
shadow.Size = UDim2.new(1,50,1,50)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.6
shadow.ZIndex = -1


local titleBar = Instance.new("Frame",main)
titleBar.Size = UDim2.new(1,0,0,45)
titleBar.BackgroundColor3 = Color3.fromRGB(26,26,34)
titleBar.BorderSizePixel = 0
Instance.new("UICorner",titleBar).CornerRadius = UDim.new(0,14)


local title = Instance.new("TextLabel",titleBar)
title.Size = UDim2.new(1,-120,1,0)
title.Position = UDim2.new(0,15,0,0)
title.BackgroundTransparency = 1
title.Text = "remotes.lua - larpingrentals"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Left
title.TextColor3 = Color3.fromRGB(230,230,255)


local minimize = Instance.new("TextButton",titleBar)
minimize.Position = UDim2.new(1,-90,0,7)
minimize.Size = UDim2.new(0,35,0,30)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BackgroundColor3 = Color3.fromRGB(50,50,65)
Instance.new("UICorner",minimize)


local close = Instance.new("TextButton",titleBar)
close.Position = UDim2.new(1,-45,0,7)
close.Size = UDim2.new(0,35,0,30)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(150,60,60)
Instance.new("UICorner",close)


local tabBar = Instance.new("Frame",main)
tabBar.Position = UDim2.new(0,0,0,45)
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.BackgroundColor3 = Color3.fromRGB(22,22,30)
tabBar.BorderSizePixel = 0


local tabs = {"All","Remotes","Values","Players","Favorites","Logs"}


local tabButtons = {}

for i,v in ipairs(tabs) do

	local b = Instance.new("TextButton",tabBar)
	b.Size = UDim2.new(0,120,1,0)
	b.Position = UDim2.new(0,(i-1)*125,0,0)
	b.Text = v
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.BackgroundColor3 = Color3.fromRGB(30,30,40)
	b.TextColor3 = Color3.fromRGB(200,200,200)
	Instance.new("UICorner",b)

	tabButtons[v] = b
end


local search = Instance.new("TextBox",main)
search.Position = UDim2.new(0,15,0,95)
search.Size = UDim2.new(0,300,0,36)
search.PlaceholderText = "Search..."
search.BackgroundColor3 = Color3.fromRGB(32,32,42)
search.TextColor3 = Color3.new(1,1,1)
search.BorderSizePixel = 0
search.Font = Enum.Font.Gotham
search.TextSize = 14
search.ClearTextOnFocus = false
Instance.new("UICorner",search)


local list = Instance.new("ScrollingFrame",main)
list.Position = UDim2.new(0,15,0,140)
list.Size = UDim2.new(0,300,1,-155)
list.BackgroundColor3 = Color3.fromRGB(22,22,30)
list.ScrollBarThickness = 5
list.BorderSizePixel = 0
Instance.new("UICorner",list)

local layout = Instance.new("UIListLayout",list)
layout.Padding = UDim.new(0,6)


local panel = Instance.new("Frame",main)
panel.Position = UDim2.new(0,330,0,95)
panel.Size = UDim2.new(1,-345,1,-110)
panel.BackgroundColor3 = Color3.fromRGB(24,24,34)
panel.BorderSizePixel = 0
Instance.new("UICorner",panel)


local info = Instance.new("TextLabel",panel)
info.Position = UDim2.new(0,10,0,10)
info.Size = UDim2.new(1,-20,0,140)
info.TextWrapped = true
info.TextYAlignment = Top
info.BackgroundTransparency = 1
info.Font = Enum.Font.Gotham
info.TextSize = 14
info.TextColor3 = Color3.new(1,1,1)


local input = Instance.new("TextBox",panel)
input.Position = UDim2.new(0,10,0,160)
input.Size = UDim2.new(1,-20,0,38)
input.BackgroundColor3 = Color3.fromRGB(40,40,55)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.ClearTextOnFocus = false
Instance.new("UICorner",input)


local function makeBtn(t,y,c)

	local b = Instance.new("TextButton",panel)
	b.Position = UDim2.new(0,10,0,y)
	b.Size = UDim2.new(1,-20,0,38)
	b.Text = t
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.BackgroundColor3 = c
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner",b)

	return b
end


local run = makeBtn("Run / Set",210,Color3.fromRGB(80,140,200))
local fav = makeBtn("Favorite",255,Color3.fromRGB(200,160,60))
local export = makeBtn("Export Config",300,Color3.fromRGB(100,160,120))


local function parse(text)

	local args = {}

	for p in string.gmatch(text,"[^,]+") do

		p = p:match("^%s*(.-)%s*$")

		local n = tonumber(p)

		if n then
			table.insert(args,n)
		elseif p=="true" then
			table.insert(args,true)
		elseif p=="false" then
			table.insert(args,false)
		else
			table.insert(args,p)
		end
	end

	return args
end


local function log(text)

	table.insert(logs,1,text)

	if #logs>100 then
		table.remove(logs)
	end
end


local function clear()

	for _,v in ipairs(list:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
end


local function match(obj,q)

	if q=="" then return true end

	q = q:lower()

	return
		obj.Name:lower():find(q) or
		obj:GetFullName():lower():find(q)
end


local function allowed(obj)

	if currentTab=="All" then return true end
	if currentTab=="Remotes" then return obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") end
	if currentTab=="Values" then return obj:IsA("ValueBase") end
	if currentTab=="Players" then return obj:IsDescendantOf(Players) end
	if currentTab=="Favorites" then return favorites[obj] end
	if currentTab=="Logs" then return false end

	return true
end


local function build()

	clear()
	filtered = {}

	if currentTab=="Logs" then

		for _,v in ipairs(logs) do

			local b = Instance.new("TextLabel",list)
			b.Size = UDim2.new(1,-10,0,30)
			b.BackgroundTransparency = 1
			b.TextWrapped = true
			b.TextXAlignment = Left
			b.Text = v
			b.Font = Enum.Font.Gotham
			b.TextSize = 12
			b.TextColor3 = Color3.new(1,1,1)
		end

		return
	end


	for _,obj in ipairs(items) do

		if allowed(obj) and match(obj,search.Text) then
			table.insert(filtered,obj)
		end
	end


	for _,obj in ipairs(filtered) do

		local b = Instance.new("TextButton",list)
		b.Size = UDim2.new(1,-10,0,34)
		b.Text = "["..obj.ClassName.."] "..obj.Name
		b.Font = Enum.Font.Gotham
		b.TextSize = 12
		b.BackgroundColor3 = Color3.fromRGB(42,42,56)
		b.TextColor3 = Color3.new(1,1,1)
		Instance.new("UICorner",b)

		b.MouseButton1Click:Connect(function()

			selected = obj

			if obj:IsA("ValueBase") then
				input.Text = tostring(obj.Value)
			else
				input.Text = ""
			end

			info.Text =
				"Name: "..obj.Name..
				"\nType: "..obj.ClassName..
				"\n\n"..obj:GetFullName()
		end)
	end


	task.wait()

	list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end


local function scan()

	items = {}

	for _,v in ipairs(game:GetDescendants()) do

		if
			v:IsA("RemoteEvent") or
			v:IsA("RemoteFunction") or
			v:IsA("ValueBase")
		then
			table.insert(items,v)
		end
	end

	build()
end


run.MouseButton1Click:Connect(function()

	if not selected then return end


	if selected:IsA("RemoteEvent") then

		local args = parse(input.Text)

		selected:FireServer(unpack(args))

		log("Fired "..selected.Name.." | "..input.Text)


	elseif selected:IsA("RemoteFunction") then

		local args = parse(input.Text)

		local r = selected:InvokeServer(unpack(args))

		log("Invoked "..selected.Name.." -> "..tostring(r))


	elseif selected:IsA("ValueBase") then

		local t = input.Text

		if selected:IsA("IntValue") or selected:IsA("NumberValue") then
			local n = tonumber(t)
			if n then selected.Value = n end

		elseif selected:IsA("BoolValue") then
			selected.Value = (t=="true")

		elseif selected:IsA("StringValue") then
			selected.Value = t

		elseif selected:IsA("Vector3Value") then

			local p = parse(t)

			if #p==3 then
				selected.Value = Vector3.new(p[1],p[2],p[3])
			end
		end

		log("Set "..selected.Name.." = "..tostring(selected.Value))
	end

	build()
end)


fav.MouseButton1Click:Connect(function()

	if not selected then return end

	favorites[selected] = not favorites[selected]

	build()
end)


export.MouseButton1Click:Connect(function()

	local data = {}

	for obj,_ in pairs(favorites) do
		table.insert(data,obj:GetFullName())
	end

	setclipboard(table.concat(data,"\n"))
end)


for name,btn in pairs(tabButtons) do

	btn.MouseButton1Click:Connect(function()

		currentTab = name

		for _,b in pairs(tabButtons) do
			b.BackgroundColor3 = Color3.fromRGB(30,30,40)
		end

		btn.BackgroundColor3 = Color3.fromRGB(60,60,90)

		build()
	end)
end


search:GetPropertyChangedSignal("Text"):Connect(build)


close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)


minimize.MouseButton1Click:Connect(function()

	minimized = not minimized

	if minimized then
		main.Size = UDim2.new(0,760,0,45)
	else
		main.Size = UDim2.new(0,760,0,520)
	end
end)


UserInputService.InputBegan:Connect(function(i,g)

	if g then return end

	if i.KeyCode==Enum.KeyCode.Insert then

		visible = not visible
		gui.Enabled = visible
	end
end)


scan()
