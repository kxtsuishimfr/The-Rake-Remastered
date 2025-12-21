local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Cache references to avoid repeated searches
local cachedPowerValue
local cachedPowerValuesFolder

local function findPowerValue()
    if cachedPowerValue and cachedPowerValue.Parent then return cachedPowerValue end
    if not ReplicatedStorage then return nil end
    local pvFolder = ReplicatedStorage:FindFirstChild("PowerValues") or ReplicatedStorage:FindFirstChild("powervalues")
    if not pvFolder then return nil end
    cachedPowerValuesFolder = pvFolder
    local pl = pvFolder:FindFirstChild("PowerLevel") or pvFolder:FindFirstChild("powerlevel")
    if not pl then return nil end
    -- PowerLevel may be either a Value object itself (including IntConstrainedValue)
    if pl:IsA("NumberValue") or pl:IsA("IntValue") or pl:IsA("StringValue") or pl:IsA("IntConstrainedValue") then
        cachedPowerValue = pl
        return pl
    end
    local val = pl:FindFirstChild("Value") or pl:FindFirstChild("value")
    if val and (val:IsA("NumberValue") or val:IsA("IntValue") or val:IsA("StringValue")) then
        cachedPowerValue = val
        return val
    end
    return nil
end

-- GUI setup
local function createGui()
    if not LocalPlayer then
        Players.CharacterAdded:Wait()
        LocalPlayer = Players.LocalPlayer
        if not LocalPlayer then return end
    end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    if not playerGui then return end

    -- avoid duplicate
    local existing = playerGui:FindFirstChild("PowerLevelGui")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "PowerLevelGui"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 50
    sg.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "PowerLevelFrame"
    frame.Size = UDim2.new(0, 220, 0, 36)
    frame.Position = UDim2.new(1, -240, 0.85, 0)
    frame.AnchorPoint = Vector2.new(0,0)
    frame.BackgroundColor3 = Color3.fromRGB(24,24,28)
    frame.BackgroundTransparency = 0.06
    frame.ZIndex = 1
    frame.Parent = sg

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,8) corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "PowerLevelLabel"
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Text = "power: unknown"
    label.ZIndex = 2
    label.Parent = frame

    return sg, frame, label
end

local gui, frame, label = createGui()

local currentConn

local function updateLabel(value)
    if not label then return end
    local text
    if value == nil then
        text = "power: unknown"
    else
        if tonumber(value) == 0 then
            text = "power is out"
        else
            text = "power: " .. tostring(value)
        end
    end
    pcall(function() label.Text = text end)
end

local function hookPower(valueObj)
    if not valueObj then return end
    -- disconnect previous
    if currentConn then
        pcall(function() currentConn:Disconnect() end)
        currentConn = nil
    end
    -- initial
    local ok, v = pcall(function() return valueObj.Value end)
    if ok then updateLabel(v) end
    -- connect changed
    local conn
    pcall(function()
        if valueObj.GetPropertyChangedSignal then
            conn = valueObj:GetPropertyChangedSignal("Value"):Connect(function()
                local ok2, nv = pcall(function() return valueObj.Value end)
                if ok2 then updateLabel(nv) end
            end)
        else
            conn = valueObj.Changed:Connect(function(nv)
                updateLabel(nv)
            end)
        end
    end)
    currentConn = conn
end

-- Watch for the PowerLevel value and for the folder/objects appearing
local folderConn, descendantConn
local searchConn

local function startWatcher()
    -- try immediate find
    local val = findPowerValue()
    if val then
        hookPower(val)
    end

    -- fallback: poll briefly until we find the value
    if not cachedPowerValue then
        searchConn = RunService.Heartbeat:Connect(function()
            local v = findPowerValue()
            if v then
                if searchConn then searchConn:Disconnect() searchConn = nil end
                hookPower(v)
            end
        end)
    end

    -- watch for PowerValues folder if missing
    if not cachedPowerValuesFolder then
        folderConn = ReplicatedStorage.ChildAdded:Connect(function(child)
            if not child then return end
            if child.Name:lower() == "powervalues" then
                cachedPowerValuesFolder = child
                -- try find inside
                local pl = cachedPowerValuesFolder:FindFirstChild("PowerLevel") or cachedPowerValuesFolder:FindFirstChild("powerlevel")
                if pl then
                    local v = pl:FindFirstChild("Value") or pl:FindFirstChild("value")
                    if v then
                        hookPower(v)
                    end
                end
                -- watch descendants for PowerLevel/value
                descendantConn = cachedPowerValuesFolder.DescendantAdded:Connect(function(inst)
                    if not inst then return end
                    if inst.Name:lower() == "powerlevel" then
                        local v = inst:FindFirstChild("Value") or inst:FindFirstChild("value")
                        if v then hookPower(v) end
                    elseif inst.Name:lower() == "value" and inst.Parent and inst.Parent.Name:lower() == "powerlevel" then
                        hookPower(inst)
                    end
                end)
            end
        end)
    else
        -- folder exists, watch for powerlevel/value appearing or changing
        descendantConn = cachedPowerValuesFolder.DescendantAdded:Connect(function(inst)
            if not inst then return end
            if inst.Name:lower() == "powerlevel" then
                local v = inst:FindFirstChild("Value") or inst:FindFirstChild("value")
                if v then hookPower(v) end
            elseif inst.Name:lower() == "value" and inst.Parent and inst.Parent.Name:lower() == "powerlevel" then
                hookPower(inst)
            end
        end)
    end

    -- also watch for PowerValues being removed (cleanup)
    ReplicatedStorage.DescendantRemoving:Connect(function(inst)
        if cachedPowerValue and (inst == cachedPowerValue or inst == cachedPowerValue.Parent) then
            -- clear label
            updateLabel(nil)
            if currentConn then pcall(function() currentConn:Disconnect() end) end
            cachedPowerValue = nil
        end
    end)
end

-- run
spawn(function()
    -- ensure GUI exists (recreate if PlayerGui appears later)
    if not label then gui, frame, label = createGui() end
    startWatcher()
end)

return true
