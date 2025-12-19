-- Object Inspector (LocalScript)
-- Place this in StarterPlayer > StarterPlayerScripts or run as a LocalScript.
-- Press Insert to toggle inspection: prints full paths to Output and highlights objects.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("ObjectInspector: LocalPlayer not available — run as a LocalScript.")
    return
end

local MAX_PER_FRAME = 150 -- avoid hitches by chunking
local highlights = {}
local billboards = {}
local active = false

local function getFullPath(inst)
    local parts = {}
    local cur = inst
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return table.concat(parts, "/")
end

local function makeHighlight(target, labelText)
    if not target or not target.Parent then return end
    local parent = target
    if target:IsA("BasePart") then
        parent = target
    elseif target:IsA("Model") then
        parent = target:FindFirstChildWhichIsA("BasePart") or target.PrimaryPart
    end
    if not parent or not parent:IsA("BasePart") then return end

    local h = Instance.new("Highlight")
    h.Name = "InspectorHighlight"
    h.Parent = parent
    h.FillTransparency = 0.7
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillColor = Color3.fromRGB(255, 200, 40)
    h.OutlineColor = Color3.fromRGB(255,255,255)

    local bg = Instance.new("BillboardGui")
    bg.Name = "InspectorLabel"
    bg.Size = UDim2.fromScale(3, 0.8)
    bg.AlwaysOnTop = true
    bg.StudsOffset = Vector3.new(0, 2.5, 0)
    bg.Adornee = parent
    bg.Parent = parent

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1, 1)
    txt.BackgroundTransparency = 1
    txt.TextScaled = true
    txt.Font = Enum.Font.Gotham
    txt.TextColor3 = Color3.new(1,1,1)
    txt.TextStrokeTransparency = 0
    txt.Text = labelText or parent.Name
    txt.Parent = bg

    table.insert(highlights, h)
    table.insert(billboards, bg)
end

local function clearInspector()
    for _, h in ipairs(highlights) do
        pcall(function() h:Destroy() end)
    end
    for _, b in ipairs(billboards) do
        pcall(function() b:Destroy() end)
    end
    highlights = {}
    billboards = {}
end

local function runInspection()
    clearInspector()
    local descendants = Workspace:GetDescendants()
    local count = #descendants
    local i = 1
    while i <= count and active do
        for j = i, math.min(i + MAX_PER_FRAME - 1, count) do
            local inst = descendants[j]
            if inst then
                -- print the path (safe pcall)
                pcall(function()
                    local path = getFullPath(inst)
                    print("ObjectInspector:", path, " (", inst.ClassName, ")")
                end)
                -- create highlight for Model or BasePart
                if inst:IsA("Model") or inst:IsA("BasePart") then
                    pcall(function()
                        local label = tostring(inst.Name)
                        makeHighlight(inst, label)
                    end)
                end
            end
        end
        i = i + MAX_PER_FRAME
        task.wait(0) -- yield to avoid frame hitches
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        active = not active
        if active then
            print("ObjectInspector: enabled — scanning workspace...")
            task.spawn(runInspection)
        else
            print("ObjectInspector: disabled — clearing highlights")
            clearInspector()
        end
    end
end)

print("ObjectInspector loaded. Press Insert to scan and highlight Workspace objects.")
