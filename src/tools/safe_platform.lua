-- safe_platform.lua
-- Press `P` to spawn a temporary safe platform above your head
-- Spawns an anchored platform and teleports the player on top of it
-- Usage: run as a LocalScript (StarterPlayerScripts) or execute locally

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("safe_platform: LocalPlayer not found — run as a LocalScript.")
    return
end

local PLATFORM_SIZE = Vector3.new(6, 1.5, 6)
local HEIGHT_ABOVE_HEAD = 4 -- base distance above the player's root

local function makePlatform(position)
    local p = Instance.new("Part")
    p.Size = PLATFORM_SIZE
    p.Anchored = true
    p.CanCollide = true
    p.Position = position
    p.Name = "SafePlatform"
    p.Material = Enum.Material.Metal
    p.Color = Color3.fromRGB(68, 72, 78)
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = Workspace
    return p
end

local function findSafePositionAbove(character)
    local hrp = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not hrp then return nil end

    local origin = hrp.Position
    -- try to place platform a fixed offset above the player head/root
    local desiredY = origin.Y + HEIGHT_ABOVE_HEAD + (PLATFORM_SIZE.Y / 2)
    local desiredPos = Vector3.new(origin.X, desiredY, origin.Z)

    -- raycast upward to check for obstacles
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = { character }

    local rayResult = Workspace:Raycast(origin, Vector3.new(0, (HEIGHT_ABOVE_HEAD + 6), 0), rayParams)
    if rayResult and rayResult.Position then
        -- place platform just below the obstacle (with small margin)
        local obstacleY = rayResult.Position.Y
        local safeY = obstacleY - 1 - (PLATFORM_SIZE.Y / 2)
        -- ensure it's still above origin; otherwise fallback to desiredPos
        if safeY > origin.Y + 1 then
            return Vector3.new(origin.X, safeY, origin.Z)
        end
    end

    return desiredPos
end

local function teleportOnPlatform(platform, character)
    local hrp = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not hrp then return end
    local aboveOffset = (PLATFORM_SIZE.Y / 2) + 2
    local targetPos = platform.Position + Vector3.new(0, aboveOffset, 0)
    -- teleport gently by setting CFrame
    pcall(function() hrp.CFrame = CFrame.new(targetPos, targetPos + hrp.CFrame.LookVector) end)
end

local function spawnPlatformForPlayer()
    local character = LocalPlayer.Character
    if not character then return end

    local pos = findSafePositionAbove(character)
    if not pos then return end

    local platform = makePlatform(pos)
    -- teleport the player onto it
    teleportOnPlatform(platform, character)
    return platform
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.P then
        spawnPlatformForPlayer()
    end
end)

-- no cleanup needed on character removal for persistent platforms

print("safe_platform loaded — Press P to spawn a temporary platform above your head.")
