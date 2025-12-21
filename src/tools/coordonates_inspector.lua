local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("CoordInspector: LocalPlayer not available — run as a LocalScript.")
    return
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screen = Instance.new("ScreenGui")
screen.Name = "CoordInspectorUI"
screen.ResetOnSpawn = false
screen.Parent = playerGui

local label = Instance.new("TextLabel")
label.Name = "CoordLabel"
label.Size = UDim2.new(0, 260, 0, 36)
label.Position = UDim2.new(0.01, 0, 0.01, 0)
label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
label.BackgroundTransparency = 0.15
label.BorderSizePixel = 0
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Center
label.Text = "Coords: ---"
label.Parent = screen

screen.Enabled = true

local function formatVec(v)
    return string.format("X: %.2f  Y: %.2f  Z: %.2f", v.X, v.Y, v.Z)
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if hrp then
        label.Text = formatVec(hrp.Position)
    else
        label.Text = "Coords: (character unavailable)"
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        screen.Enabled = not screen.Enabled
    end
end)


print("CoordInspector loaded. Press Insert to toggle the coordinates HUD.")
