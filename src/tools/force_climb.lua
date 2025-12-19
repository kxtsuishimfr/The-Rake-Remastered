-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local isForcingClimb = false
local climbConnection = nil

local function toggleClimb(active)
    isForcingClimb = active
    
    if active then
        climbConnection = RunService.Heartbeat:Connect(function()
            if humanoid:GetState() ~= Enum.HumanoidStateType.Climbing then
                humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
            end
            
            if rootPart.AssemblyLinearVelocity.Y < 0 then
                rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, 0, rootPart.AssemblyLinearVelocity.Z)
            end
        end)
    else
        if climbConnection then
            climbConnection:Disconnect()
            climbConnection = nil
        end
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end

-- Spawn an actual climbable ladder
local function spawnClimbable()
    local ladder = Instance.new("Part")
    ladder.Size = Vector3.new(2, 10, 1) -- ladder width, height, depth
    ladder.Anchored = true
    ladder.CanCollide = true
    ladder.Material = Enum.Material.Metal
    ladder.Color = Color3.fromRGB(128,128,128)
    ladder.Position = rootPart.Position + rootPart.CFrame.LookVector * 5
    
    -- Make it climbable
    local ladderAttachment = Instance.new("LadderConstraint")
    ladderAttachment.Parent = ladder
    
    ladder.Parent = Workspace
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        toggleClimb(not isForcingClimb)
        print("Forced Climb:", isForcingClimb)
    elseif input.KeyCode == Enum.KeyCode.K then
        spawnClimbable()
        print("Spawned climbable metal!")
    end
end)
