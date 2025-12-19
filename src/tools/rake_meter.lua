local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Player and GUI Setup
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Destroy existing GUI if script is run multiple times
local existingGui = playerGui:FindFirstChild("RakeProximityGui")
if existingGui then
    existingGui:Destroy()
end

-- === GUI CREATION ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RakeProximityGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame")
frame.Name = "ProximityFrame"
frame.Parent = screenGui
frame.Size = UDim2.new(0, 220, 0, 60)
frame.Position = UDim2.new(1, -230, 0, 10)
frame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Active = true -- Allows it to be dragged

-- Add a corner for rounded edges
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Parent = frame
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Initializing..."
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSansBold

-- === LOGIC & DISTANCE THRESHOLDS ===
local RAKE_NAME = "Rake"
local DISTANCE_VERY_CLOSE = 50
local DISTANCE_CLOSE = 150
local DISTANCE_FAR = 300

-- Function to update the GUI based on distance
local function updateProximityGui(distance)
    local status, color
    
    if distance <= DISTANCE_VERY_CLOSE then
        status = "VERY CLOSE"
        color = Color3.new(1, 0, 0) -- Red
    elseif distance <= DISTANCE_CLOSE then
        status = "CLOSE"
        color = Color3.new(1, 0.5, 0) -- Orange
    elseif distance <= DISTANCE_FAR then
        status = "FAR"
        color = Color3.new(1, 1, 0) -- Yellow
    else
        status = "SAFE"
        color = Color3.new(0, 1, 0) -- Green
    end
    
    statusLabel.Text = status
    statusLabel.TextColor3 = color
end

-- === MAIN HEARTBEAT LOOP ===
-- This loop runs every frame to check the distance
local connection
connection = RunService.Heartbeat:Connect(function()
    -- Find the Rake in the workspace
    local rake = workspace:FindFirstChild(RAKE_NAME)
    
    if rake and rake.PrimaryPart then
        -- Get the player's character and their root part
        local character = player.Character
        if character and character.PrimaryPart then
            -- Calculate the distance between the player and the Rake
            local distance = (rake.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude
            updateProximityGui(distance)
        else
            statusLabel.Text = "No Character"
            statusLabel.TextColor3 = Color3.new(0.5, 0.5, 0.5)
        end
    else
        statusLabel.Text = "Rake Not Found"
        statusLabel.TextColor3 = Color3.new(0.5, 0.5, 0.5)
    end
end)

-- Optional: Add a way to close the GUI by pressing a key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.End then -- Press 'End' key to close the GUI
        if connection then
            connection:Disconnect()
        end
        if screenGui then
            screenGui:Destroy()
        end
    end
end)

-- Make the GUI draggable
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
