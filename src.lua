local Players = game:GetService("Players")
local player = Players.LocalPlayer

local items = {}
local selectedItem = nil

local gui = Instance.new("ScreenGui")
gui.Name = "RemoteValueFinder"
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 520, 0, 420)
main.Position = UDim2.new(0.5, -260, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel")
title.Parent = main
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(35,35,35)
title.Text = "Remote & Value Finder"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22

local listFrame = Instance.new("ScrollingFrame")
listFrame.Parent = main
listFrame.Position = UDim2.new(0,10,0,50)
listFrame.Size = UDim2.new(0,240,1,-60)
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.ScrollBarThickness = 6
listFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
listFrame.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0,5)

local info = Instance.new("TextLabel")
info.Parent = main
info.Position = UDim2.new(0,260,0,55)
info.Size = UDim2.new(1,-270,0,80)
info.BackgroundTransparency = 1
info.TextWrapped = true
info.Text = "Select an item"
info.TextColor3 = Color3.new(1,1,1)
info.Font = Enum.Font.SourceSans
info.TextSize = 16

local inputBox = Instance.new("TextBox")
inputBox.Parent = main
inputBox.Position = UDim2.new(0,260,0,150)
inputBox.Size = UDim2.new(1,-270,0,40)
inputBox.PlaceholderText = "Arguments / New Value"
inputBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.BorderSizePixel = 0
inputBox.Font = Enum.Font.SourceSans
inputBox.TextSize = 16


-- Run Button
local runBtn = Instance.new("TextButton")
runBtn.Parent = main
runBtn.Position = UDim2.new(0,260,0,205)
runBtn.Size = UDim2.new(1,-270,0,45)
runBtn.Text = "Run / Set"
runBtn.BackgroundColor3 = Color3.fromRGB(70,130,180)
runBtn.TextColor3 = Color3.new(1,1,1)
runBtn.Font = Enum.Font.SourceSansBold
runBtn.TextSize = 18
runBtn.BorderSizePixel = 0

local refreshBtn = Instance.new("TextButton")
refreshBtn.Parent = main
refreshBtn.Position = UDim2.new(0,260,0,265)
refreshBtn.Size = UDim2.new(1,-270,0,40)
refreshBtn.Text = "Refresh"
refreshBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.Font = Enum.Font.SourceSans
refreshBtn.TextSize = 16
refreshBtn.BorderSizePixel = 0

local function clearList()
	for _,v in ipairs(listFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
end


local function parseArgs(text)

	local args = {}

	if text == "" then
		return args
	end

	for part in string.gmatch(text,"[^,]+") do

		part = part:match("^%s*(.-)%s*$")

		local num = tonumber(part)

		if num then
			table.insert(args,num)

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

local function scan()

	items = {}
	clearList()

	for _,obj in ipairs(game:GetDescendants()) do

		if
			obj:IsA("RemoteEvent") or
			obj:IsA("RemoteFunction") or
			obj:IsA("ValueBase")
		then
			table.insert(items,obj)
		end
	end


	for i,item in ipairs(items) do

		local btn = Instance.new("TextButton")
		btn.Parent = listFrame
		btn.Size = UDim2.new(1,-10,0,34)

		btn.Text =
			i..". ["..item.ClassName.."] "..item.Name

		btn.TextWrapped = true
		btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
		btn.TextColor3 = Color3.new(1,1,1)
		btn.BorderSizePixel = 0
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 14


		btn.MouseButton1Click:Connect(function()

			selectedItem = item

			if item:IsA("ValueBase") then

				info.Text =
					"Name: "..item.Name..
					"\nType: "..item.ClassName..
					"\nValue: "..tostring(item.Value)

				inputBox.Text = tostring(item.Value)

			else

				info.Text =
					"Name: "..item.Name..
					"\nType: "..item.ClassName..
					"\nPath: "..item:GetFullName()

				inputBox.Text = ""

			end
		end)
	end


	task.wait()

	listFrame.CanvasSize = UDim2.new(
		0,0,
		0,layout.AbsoluteContentSize.Y + 10
	)
end

runBtn.MouseButton1Click:Connect(function()

	if not selectedItem then
		warn("Nothing selected")
		return
	end

	if selectedItem:IsA("RemoteEvent") then

		local args = parseArgs(inputBox.Text)

		selectedItem:FireServer(unpack(args))

		print("Fired:", selectedItem.Name)


	elseif selectedItem:IsA("RemoteFunction") then

		local args = parseArgs(inputBox.Text)

		local result = selectedItem:InvokeServer(unpack(args))

		print("Invoked:", selectedItem.Name, result)

elseif selectedItem:IsA("ValueBase") then

		local text = inputBox.Text


		if selectedItem:IsA("IntValue") or selectedItem:IsA("NumberValue") then

			local num = tonumber(text)

			if num then
				selectedItem.Value = num
			end


		elseif selectedItem:IsA("BoolValue") then

			selectedItem.Value = (text == "true")


		elseif selectedItem:IsA("StringValue") then

			selectedItem.Value = text


		elseif selectedItem:IsA("Vector3Value") then

			local parts = parseArgs(text)

			if #parts == 3 then
				selectedItem.Value = Vector3.new(
					parts[1],
					parts[2],
					parts[3]
				)
			end
		end


		info.Text =
			"Name: "..selectedItem.Name..
			"\nType: "..selectedItem.ClassName..
			"\nValue: "..tostring(selectedItem.Value)


		print("Set value:", selectedItem.Name)
	end

end)


refreshBtn.MouseButton1Click:Connect(scan)

scan()
