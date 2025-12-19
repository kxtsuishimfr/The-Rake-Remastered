local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HeldItemDisplay"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Container"
frame.Size = UDim2.new(0, 240, 0, 44)
frame.Position = UDim2.new(0.5, -120, 0, 18)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundTransparency = 0.4
frame.BorderSizePixel = 0
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Parent = screenGui

local txt = Instance.new("TextLabel")
txt.Name = "ItemName"
txt.Size = UDim2.new(1, -12, 1, -8)
txt.Position = UDim2.new(0, 6, 0, 4)
txt.BackgroundTransparency = 1
txt.TextScaled = true
txt.TextWrapped = true
txt.Font = Enum.Font.GothamSemibold
txt.TextColor3 = Color3.fromRGB(255, 255, 255)
txt.Text = "No Item"
txt.Parent = frame

local mouse = player:GetMouse()
local currentTool
local activeConns = {}

local function clearCurrent()
    currentTool = nil
    txt.Text = "No Item"
    for _,c in ipairs(activeConns) do
        if c and c.Disconnect then
            pcall(function() c:Disconnect() end)
        end
    end
    activeConns = {}
end

local function watchTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    currentTool = tool
    txt.Text = tool.Name
    local uneqConn = tool.Unequipped:Connect(function()
        if currentTool == tool then
            clearCurrent()
        end
    end)
    table.insert(activeConns, uneqConn)
    local nameConn = tool:GetPropertyChangedSignal("Name"):Connect(function()
        if currentTool == tool then
            txt.Text = tool.Name
        end
    end)
    table.insert(activeConns, nameConn)
end

mouse.Equipped:Connect(function(tool)
    if tool and tool:IsA("Tool") then
        watchTool(tool)
    end
end)

player.CharacterAdded:Connect(function(char)
    for _,v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") then
            watchTool(v)
            break
        end
    end
    char.ChildAdded:Connect(function(c)
        if c:IsA("Tool") then
            watchTool(c)
        end
    end)
    char.ChildRemoved:Connect(function(c)
        if c:IsA("Tool") and currentTool == c then
            clearCurrent()
        end
    end)
end)

if player.Character then
    player.Character:WaitForChild("Humanoid") -- ensure character exist
    for _,v in ipairs(player.Character:GetChildren()) do
        if v:IsA("Tool") then
            watchTool(v)
            break
        end
    end
end
