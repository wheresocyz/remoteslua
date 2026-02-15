-- remotes.lua (loadstring-ready)
-- Insanely styled glassy remote/value UI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Wait for character and PlayerGui
repeat task.wait() until player and player:FindFirstChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteValueUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- Data
local items, filtered, selected, logs, favorites = {}, {}, nil, {}, {}
local currentTab = "All"

-- Utils
local function parseArgs(text)
    local args = {}
    for part in string.gmatch(text, "[^,]+") do
        part = part:match("^%s*(.-)%s*$")
        local n = tonumber(part)
        if n then table.insert(args,n)
        elseif part=="true" then table.insert(args,true)
        elseif part=="false" then table.insert(args,false)
        else table.insert(args,part)
        end
    end
    return args
end

local function logAction(text)
    table.insert(logs,1,text)
    if #logs>100 then table.remove(logs) end
end

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,850,0,550)
main.Position = UDim2.new(0.5,-425,0.5,-275)
main.BackgroundColor3 = Color3.fromRGB(30,30,40)
main.BackgroundTransparency = 0
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,20)

-- Gradient overlay for glassy effect
local grad = Instance.new("UIGradient", main)
grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(50,50,70)), ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,35))}
grad.Rotation = 45

-- Shadow glow
local shadow = Instance.new("ImageLabel", main)
shadow.Size = UDim2.new(1,60,1,60)
shadow.Position = UDim2.new(0.5,0,0.5,0)
shadow.AnchorPoint = Vector2.new(0.5,0.5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0,255,255)
shadow.ImageTransparency = 0.7
shadow.ZIndex = -1

-- Title bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,50)
titleBar.BackgroundColor3 = Color3.fromRGB(35,35,45)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,20)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "remotes.lua - larpingrentals"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(200,255,255)
title.TextStrokeTransparency = 0.6

local close = Instance.new("TextButton", titleBar)
close.Size = UDim2.new(0,45,0,30)
close.Position = UDim2.new(1,-50,0,10)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.fromRGB(255,100,100)
close.TextSize = 16
close.BackgroundTransparency = 0.3
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Tabs
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1,0,0,45)
tabBar.Position = UDim2.new(0,0,0,50)
tabBar.BackgroundTransparency = 0.8

local tabs = {"All","Remotes","Values","Players","Favorites","Logs"}
local tabButtons = {}

-- Tab creation
for i,v in ipairs(tabs) do
    local b = Instance.new("TextButton", tabBar)
    b.Size = UDim2.new(0,130,1,0)
    b.Position = UDim2.new(0,(i-1)*140,0,0)
    b.Text = v
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BackgroundTransparency = 0.4
    b.TextColor3 = Color3.fromRGB(220,220,255)
    Instance.new("UICorner", b)
    tabButtons[v] = b

    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.2),{BackgroundTransparency=0}):Play()
    end)
    b.MouseLeave:Connect(function()
        if currentTab~=v then TweenService:Create(b,TweenInfo.new(0.2),{BackgroundTransparency=0.4}):Play() end
    end)
    b.MouseButton1Click:Connect(function()
        currentTab = v
        for _,tb in pairs(tabButtons) do tb.BackgroundTransparency = 0.4 end
        b.BackgroundTransparency = 0
        buildList()
    end)
end

-- Search box
local search = Instance.new("TextBox", main)
search.Position = UDim2.new(0,15,0,105)
search.Size = UDim2.new(0,300,0,35)
search.PlaceholderText = "Search remotes, players, paths..."
search.BackgroundColor3 = Color3.fromRGB(40,40,60)
search.TextColor3 = Color3.new(1,1,1)
search.Font = Enum.Font.Gotham
search.TextSize = 14
Instance.new("UICorner", search)

-- List frame
local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,15,0,150)
list.Size = UDim2.new(0,300,1,-165)
list.BackgroundColor3 = Color3.fromRGB(25,25,40)
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
Instance.new("UICorner", list)
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,6)

-- Info panel
local panel = Instance.new("Frame", main)
panel.Position = UDim2.new(0,330,0,105)
panel.Size = UDim2.new(1,-345,1,-115)
panel.BackgroundColor3 = Color3.fromRGB(30,30,40)
Instance.new("UICorner", panel)

local info = Instance.new("TextLabel", panel)
info.Position = UDim2.new(0,10,0,10)
info.Size = UDim2.new(1,-20,0,150)
info.TextWrapped = true
info.TextYAlignment = Enum.TextYAlignment.Top
info.Font = Enum.Font.Gotham
info.TextSize = 14
info.TextColor3 = Color3.fromRGB(200,255,255)
info.BackgroundTransparency = 1

local input = Instance.new("TextBox", panel)
input.Position = UDim2.new(0,10,0,170)
input.Size = UDim2.new(1,-20,0,35)
input.BackgroundColor3 = Color3.fromRGB(50,50,70)
input.TextColor3 = Color3.new(1,1,1)
input.Font = Enum.Font.Gotham
input.TextSize = 14
Instance.new("UICorner", input)

local runBtn = Instance.new("TextButton", panel)
runBtn.Size = UDim2.new(1,-20,0,35)
runBtn.Position = UDim2.new(0,10,0,220)
runBtn.Text = "Run / Set"
runBtn.Font = Enum.Font.GothamBold
runBtn.TextSize = 14
runBtn.BackgroundColor3 = Color3.fromRGB(100,180,220)
runBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", runBtn)

-- Scan for items
local function scan()
    items = {}
    repeat task.wait() until game:IsLoaded()
    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("ValueBase") then
            table.insert(items,v)
        end
    end
end

-- Filter for current tab
local function allowed(obj)
    if currentTab=="All" then return true end
    if currentTab=="Remotes" then return obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") end
    if currentTab=="Values" then return obj:IsA("ValueBase") end
    if currentTab=="Players" then return obj:IsDescendantOf(Players) end
    if currentTab=="Favorites" then return favorites[obj] end
    if currentTab=="Logs" then return false end
    return true
end

-- Build list UI
function buildList()
    for _,v in ipairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    filtered = {}
    if currentTab=="Logs" then
        for _,v in ipairs(logs) do
            local b = Instance.new("TextLabel", list)
            b.Size = UDim2.new(1,-10,0,30)
            b.BackgroundTransparency = 1
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.TextWrapped = true
            b.Text = v
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.TextColor3 = Color3.fromRGB(200,255,255)
        end
        return
    end
    for _,v in ipairs(items) do
        if allowed(v) and (v.Name:lower():find(search.Text:lower()) or v:GetFullName():lower():find(search.Text:lower())) then
            table.insert(filtered,v)
        end
    end
    for _,v in ipairs(filtered) do
        local b = Instance.new("TextButton", list)
        b.Size = UDim2.new(1,-10,0,38)
        b.Text = "["..v.ClassName.."] "..v.Name
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.BackgroundColor3 = Color3.fromRGB(50,50,70)
        b.TextColor3 = Color3.fromRGB(200,255,255)
        Instance.new("UICorner", b)
        b.MouseEnter:Connect(function()
            TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(70,70,100)}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(50,50,70)}):Play()
        end)
        b.MouseButton1Click:Connect(function()
            selected = v
            if v:IsA("ValueBase") then input.Text = tostring(v.Value) else input.Text = "" end
            info.Text = "Name: "..v.Name.."\nType: "..v.ClassName.."\n\n"..v:GetFullName()
        end)
    end
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

-- Run button
runBtn.MouseButton1Click:Connect(function()
    if not selected then return end
    if selected:IsA("RemoteEvent") then
        selected:FireServer(unpack(parseArgs(input.Text)))
        logAction("Fired "..selected.Name.." | "..input.Text)
    elseif selected:IsA("RemoteFunction") then
        local r = selected:InvokeServer(unpack(parseArgs(input.Text)))
        logAction("Invoked "..selected.Name.." -> "..tostring(r))
    elseif selected:IsA("ValueBase") then
        local t = input.Text
        if selected:IsA("IntValue") or selected:IsA("NumberValue") then selected.Value = tonumber(t) or selected.Value
        elseif selected:IsA("BoolValue") then selected.Value = (t=="true")
        elseif selected:IsA("StringValue") then selected.Value = t
        elseif selected:IsA("Vector3Value") then
            local p = parseArgs(t)
            if #p==3 then selected.Value = Vector3.new(p[1],p[2],p[3]) end
        end
        logAction("Set "..selected.Name.." = "..tostring(selected.Value))
    end
    buildList()
end)

-- Refresh on search change
search:GetPropertyChangedSignal("Text"):Connect(buildList)

-- Initial scan & build
task.wait(1)
scan()
buildList()
