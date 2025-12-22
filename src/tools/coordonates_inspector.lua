-- ─────────────── ✦ REMASTERED VERSION OF TRK Exploit ✦ ───────────────
--  Created by: primesto.fx
--  Maintained by: primesto.fx & therealowner69
--  DM on Discord for requests: primesto.fx // therealowner69
-- ────────────────────────────────────────────────────────────────

-- ** This script should not be used by normal players, it is in beta state
--    and may be buggy. Wait for an official release. **

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

---------------------------------------------------------------------------

-- ** Interactables API ** --

local ToggleAPI = setmetatable({}, { __mode = "k" })
local DropdownAPI = setmetatable({}, { __mode = "k" })

-- ** Color palette (GUI) **
local COLORS = {
    bg = Color3.fromRGB(26,26,26),
    panel = Color3.fromRGB(30,30,30),
    panelAlt = Color3.fromRGB(40,40,40),
    panelDark = Color3.fromRGB(44,44,44),
    divider = Color3.fromRGB(64,64,64),
    accent = Color3.fromRGB(0,150,255),
    accentHover = Color3.fromRGB(0,170,255),
    text = Color3.fromRGB(235,235,235),
    textDim = Color3.fromRGB(200,200,200),
    tabText = Color3.fromRGB(220,220,220),
    highlight = Color3.fromRGB(80,80,80),
    white = Color3.fromRGB(255,255,255),
    close = Color3.fromRGB(255,255,255),
    closeHover = Color3.fromRGB(220,50,50),
}

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "SCREEN_GUI"
gui.ResetOnSpawn = false
local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not ok then
    if player then
        gui.Parent = player:WaitForChild("PlayerGui")
    else
        gui.Parent = game:GetService("CoreGui")
    end
end

-------------------------------------------------------------------------------

-- ** makeTab

local function makeTab(name, tabsParent, pagesParent, onSelect, colHeaders)
    local btn = Instance.new("TextButton")
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = btn
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(0, 120, 0, 32)
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = name
    btn.BackgroundColor3 = COLORS.bg
    btn.TextColor3 = COLORS.tabText

    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.Visible = false

    if tabsParent then btn.Parent = tabsParent end
    if pagesParent then page.Parent = pagesParent end

    btn.MouseButton1Click:Connect(function()
        if type(onSelect) == "function" then pcall(onSelect, btn, page) end
    end)

---------------------------------------------------------------------------------

-- ** Col Stuff

    -- ** Left col
    local leftCol = Instance.new("Frame")
    leftCol.Name = "LeftCol"
    leftCol.Size = UDim2.new(0.5, -12, 1, -12)
    leftCol.Position = UDim2.new(0, 8, 0, 8)
    leftCol.BackgroundColor3 = COLORS.panel
    leftCol.Parent = page
    leftCol.ClipsDescendants = true
    local list = Instance.new("UIListLayout") list.Parent = leftCol
    list.SortOrder = Enum.SortOrder.LayoutOrder

    -- Header for left col
    if colHeaders and colHeaders.Left then
        local hdr = Instance.new("TextLabel")
        hdr.Name = "Header"
        hdr.Size = UDim2.new(1, -12, 0, 24)
        hdr.Position = UDim2.new(0, 6, 0, 6)
        hdr.BackgroundTransparency = 1
        hdr.Font = Enum.Font.GothamBold
        hdr.TextSize = 16
        hdr.Text = tostring(colHeaders.Left)
        hdr.TextColor3 = COLORS.textDim
        hdr.TextXAlignment = Enum.TextXAlignment.Left
        hdr.LayoutOrder = 0
        hdr.Parent = leftCol
    end

    ------ Break 0

    -- ** Right col
    local rightCol = Instance.new("Frame")
    rightCol.Name = "RightCol"
    rightCol.Size = UDim2.new(0.5, -12, 1, -12)
    rightCol.Position = UDim2.new(0.5, 8, 0, 8)
    rightCol.BackgroundColor3 = COLORS.panel
    rightCol.Parent = page
    rightCol.ClipsDescendants = true
    local list2 = Instance.new("UIListLayout") list2.Parent = rightCol
    list2.SortOrder = Enum.SortOrder.LayoutOrder

    -- ** Header for right col
    if colHeaders and colHeaders.Right then
        local hdrr = Instance.new("TextLabel")
        hdrr.Name = "Header"
        hdrr.Size = UDim2.new(1, -12, 0, 24)
        hdrr.Position = UDim2.new(0, 6, 0, 6)
        hdrr.BackgroundTransparency = 1
        hdrr.Font = Enum.Font.GothamBold
        hdrr.TextSize = 16
        hdrr.Text = tostring(colHeaders.Right)
        hdrr.TextColor3 = COLORS.textDim
        hdrr.TextXAlignment = Enum.TextXAlignment.Left
        hdrr.LayoutOrder = 0
        hdrr.Parent = rightCol
    end

    -- ** vertical divider between cols
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(0, 2, 1, -16)
    divider.Position = UDim2.new(0.5, -1, 0, 8)
    divider.BackgroundColor3 = COLORS.divider
    divider.Parent = page
    local divCorner = Instance.new("UICorner") divCorner.CornerRadius = UDim.new(0,1) divCorner.Parent = divider

    local tab = {
        button = btn,
        page = page,
        LeftCol = leftCol,
        RightCol = rightCol,
        MakeCol = function(colName, size, pos, headerText)
            local col = Instance.new("Frame")
            col.Name = colName or "Col"
            col.Size = size or UDim2.new(0.5, -12, 1, -12)
            col.Position = pos or UDim2.new(0.5, 8, 0, 8)
            col.BackgroundColor3 = COLORS.panel
            col.Parent = page
            col.ClipsDescendants = true
            local l = Instance.new("UIListLayout") l.Parent = col
            l.SortOrder = Enum.SortOrder.LayoutOrder
            if headerText then
                local h = Instance.new("TextLabel")
                h.Name = "Header"
                h.Size = UDim2.new(1, -12, 0, 24)
                h.Position = UDim2.new(0, 6, 0, 6)
                h.BackgroundTransparency = 1
                h.Font = Enum.Font.GothamBold
                h.TextSize = 16
                h.Text = tostring(headerText)
                h.TextColor3 = COLORS.textDim
                h.TextXAlignment = Enum.TextXAlignment.Left
                h.LayoutOrder = 0
                h.Parent = col
            end
            return col
        end,
    }

    return tab
end

---------------------------------------------------------------------------

-- ** makeToggle
local function makeToggle(parent, labelText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,34)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.72, -6, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText or "Toggle"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextColor3 = COLORS.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 52, 0, 26)
    toggle.AnchorPoint = Vector2.new(1,0.5)
    toggle.Position = UDim2.new(1, -8, 0.5, 0)
    toggle.BackgroundColor3 = COLORS.panelDark
    toggle.Parent = frame
    local toggleCorner = Instance.new("UICorner") toggleCorner.CornerRadius = UDim.new(0, 14) toggleCorner.Parent = toggle

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.AnchorPoint = Vector2.new(0,0.5)
    knob.Position = UDim2.new(0, 4, 0.5, 0)
    knob.BackgroundColor3 = COLORS.white
    knob.Parent = toggle
    local knobCorner = Instance.new("UICorner") knobCorner.CornerRadius = UDim.new(0, 10) knobCorner.Parent = knob

    -- ** shadow under knob
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1,0,1,0)
    shadow.BackgroundTransparency = 1
    shadow.Parent = knob

    local state = false
    local tweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function setVisual(active)
        state = not not active
        if state then
            TweenService:Create(toggle, tweenInfo, {BackgroundColor3 = COLORS.accent}):Play()
            TweenService:Create(knob, tweenInfo, {Position = UDim2.new(1, -24, 0.5, 0)}):Play()
        else
            TweenService:Create(toggle, tweenInfo, {BackgroundColor3 = COLORS.panelDark}):Play()
            TweenService:Create(knob, tweenInfo, {Position = UDim2.new(0, 4, 0.5, 0)}):Play()
        end
        local api = ToggleAPI[frame]
        if api and type(api.OnToggle) == "function" then
            pcall(api.OnToggle, state)
        end
    end

    ToggleAPI[frame] = {
        Set = function(val) setVisual(val) end,
        Get = function() return state end,
        OnToggle = nil,
    }

    -- ** hover thing
    toggle.MouseEnter:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.12), {BackgroundColor3 = toggle.BackgroundColor3:Lerp(COLORS.highlight, 0.25)}):Play()
    end)
    toggle.MouseLeave:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.12), {BackgroundColor3 = state and COLORS.accent or COLORS.panelDark}):Play()
    end)

    toggle.Active = true
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setVisual(not state)
        end
    end)

    local maxOrder = 0
    for _,c in ipairs(parent:GetChildren()) do
        if c ~= frame and (c:IsA("Frame") or c:IsA("TextLabel")) then
            maxOrder = math.max(maxOrder, c.LayoutOrder or 0)
        end
    end
    frame.LayoutOrder = maxOrder + 1

    setVisual(false)
    return frame
end

--------------------------------------------------------------------------

-- ** makeDropDownList
local function makeDropDownList(parent, labelText, items, defaultIndex)
    local frame = Instance.new("Frame")
    frame.Name = tostring(labelText or "DropDown")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, -6, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText or "Select"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextColor3 = COLORS.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local display = Instance.new("TextButton")
    display.Name = frame.Name .. "_Display"
        display.Size = UDim2.new(0.4, -8, 1, 0)
    display.AnchorPoint = Vector2.new(1, 0)
    display.Position = UDim2.new(1, -8, 0, 0)
    display.BackgroundColor3 = COLORS.panelDark
    display.AutoButtonColor = true
    display.Font = Enum.Font.Gotham
    display.TextSize = 16
    display.TextColor3 = COLORS.text
    display.Text = ""
    display.Parent = frame
    local displayCorner = Instance.new("UICorner") displayCorner.CornerRadius = UDim.new(0,6) displayCorner.Parent = display

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 24, 1, 0)
    arrow.AnchorPoint = Vector2.new(1,0.5)
    arrow.Position = UDim2.new(1, -4, 0.5, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 18
    arrow.TextColor3 = COLORS.textDim
    arrow.Text = "▾"
    arrow.Parent = display

    local drop = Instance.new("Frame")
    drop.Size = UDim2.new(1, 0, 0, 0)
    drop.Position = UDim2.new(0, 0, 1, 4)
    drop.BackgroundColor3 = COLORS.panel
    drop.ClipsDescendants = true
    drop.Visible = false
    drop.Parent = frame
    local dropCorner = Instance.new("UICorner") dropCorner.CornerRadius = UDim.new(0,6) dropCorner.Parent = drop

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -8, 1, -8)
    scroll.Position = UDim2.new(0, 4, 0, 4)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.Parent = drop
    local layout = Instance.new("UIListLayout") layout.Parent = scroll
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    items = items or {}
    local selected = nil
    local btnRefs = {}
    local selectedIndices = {}

    local function populate()
        for _,c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for i, v in ipairs(items) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundTransparency = 1
            btn.AutoButtonColor = true
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 16
            btn.TextColor3 = COLORS.text
            btn.Text = tostring(v)
            btn.LayoutOrder = i
            btn.Parent = scroll

            btnRefs[i] = btn
            selectedIndices[i] = false

            local function updateBtnVisual(idx)
                local b = btnRefs[idx]
                if not b then return end
                if selectedIndices[idx] then
                    b.BackgroundTransparency = 0.9
                    b.BackgroundColor3 = COLORS.highlight
                else
                    b.BackgroundTransparency = 1
                end
            end

            btn.MouseButton1Click:Connect(function()
                    selectedIndices[i] = not selectedIndices[i]
                updateBtnVisual(i)
                selected = { index = i, value = v }
                display.Text = tostring(v)
                local api = DropdownAPI[frame]
                if api and type(api.OnSelect) == "function" then pcall(api.OnSelect, i, v, selectedIndices[i]) end
            end)
        end
        local total = #items * 28
        drop.Size = UDim2.new(1, 0, 0, math.min(total, 200))
    end

    display.MouseButton1Click:Connect(function()
        drop.Visible = not drop.Visible
    end)

    -- API
    DropdownAPI[frame] = {
        SetItems = function(tbl) items = tbl or {} populate() end,
        Set = function(idx)
            local v = items[idx]
            if v ~= nil then
                selected = { index = idx, value = v }
                display.Text = tostring(v)
                for k,_ in pairs(selectedIndices) do selectedIndices[k] = false end
                selectedIndices[idx] = true
                if btnRefs[idx] then btnRefs[idx].BackgroundTransparency = 0.9; btnRefs[idx].BackgroundColor3 = COLORS.highlight end
            end
        end,
        Get = function() return selected end,
        SetSelected = function(idx, on)
            selectedIndices[idx] = (on == true)
            if btnRefs[idx] then
                if selectedIndices[idx] then
                    btnRefs[idx].BackgroundTransparency = 0.9
                    btnRefs[idx].BackgroundColor3 = COLORS.highlight
                else
                    btnRefs[idx].BackgroundTransparency = 1
                end
            end
        end,
        IsSelected = function(idx) return selectedIndices[idx] == true end,
        OnSelect = nil,
    }

    populate()
    if defaultIndex then DropdownAPI[frame].Set(defaultIndex) end

    -- ** layout order
    local maxOrder = 0
    for _,c in ipairs(parent:GetChildren()) do
        if c ~= frame and (c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton")) then
            maxOrder = math.max(maxOrder, c.LayoutOrder or 0)
        end
    end
    frame.LayoutOrder = maxOrder + 1

    return frame
end

--------------------------------------------------------------------------

-- ** Config Stuff
local CONFIG_FILE = "Tempt-Config.json"
local function readConfig()
    local ok, contents = pcall(function() return readfile(CONFIG_FILE) end)
    if not ok or not contents then return {} end
    local success, decoded = pcall(function() return HttpService:JSONDecode(contents) end)
    if not success then return {} end
    return decoded or {}
end

local function writeConfig(tbl)
    local ok, encoded = pcall(function() return HttpService:JSONEncode(tbl) end)
    if not ok then return false end
    pcall(function() writefile(CONFIG_FILE, encoded) end)
    return true
end

local Config = readConfig()

local function SaveConfig()
    writeConfig(Config)
end

local function SetConfig(key, value)
    Config[key] = value
    SaveConfig()
end

local function GetConfig(key, default)
    if Config[key] == nil then return default end
    return Config[key]
end

local function BindToggleToConfig(toggleFrame, key, default)
    if not toggleFrame then return end
    local api = ToggleAPI[toggleFrame]
    if not api then return end
    local initial = GetConfig(key, default)
    api.Set(initial)
    api.OnToggle = function(state)
        SetConfig(key, state)
    end
end

--------------------------------------------------------------------------

-- ** Build UI
local root = Instance.new("Frame")
root.Size = UDim2.new(0, 760, 0, 520)
root.Position = UDim2.new(0.5, -380, 0.5, -260)
root.AnchorPoint = Vector2.new(0.5,0.5)
root.BackgroundColor3 = COLORS.bg
root.Parent = gui
local rootCorner = Instance.new("UICorner") rootCorner.Parent = root

local tabsBar = Instance.new("Frame")
tabsBar.Size = UDim2.new(1,0,0,40)
tabsBar.Position = UDim2.new(0,0,0,0)
tabsBar.BackgroundTransparency = 1
tabsBar.Parent = root

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1,0,1,-40)
pages.Position = UDim2.new(0,0,0,40)
pages.BackgroundTransparency = 1
pages.Parent = root

local tabsUnderlay = Instance.new("Frame")
tabsUnderlay.Name = "TabsUnderlay"
tabsUnderlay.Size = UDim2.new(1, -16, 0, 10)
tabsUnderlay.Position = UDim2.new(0, 8, 0, 40)
tabsUnderlay.BackgroundColor3 = COLORS.panel
tabsUnderlay.Parent = root
local tabsUnderCorner = Instance.new("UICorner") tabsUnderCorner.CornerRadius = UDim.new(0,4) tabsUnderCorner.Parent = tabsUnderlay
tabsUnderlay.ZIndex = 1
tabsBar.ZIndex = 2

---------------------------------------------------------------------------

-- ** close / unload UI
local function showUnloadConfirm()
    if root:FindFirstChild("UnloadConfirm") then return end
    local pop = Instance.new("Frame")
    pop.Name = "UnloadConfirm"
    pop.Size = UDim2.new(0, 360, 0, 140)
    pop.Position = UDim2.new(0.5, -180, 0.5, -70)
    pop.AnchorPoint = Vector2.new(0.5, 0.5)
    pop.BackgroundColor3 = COLORS.panel
    pop.Parent = root
    local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0,8) pc.Parent = pop

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -24, 0, 64)
    msg.Position = UDim2.new(0,12,0,12)
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.GothamBold
    msg.TextSize = 18
    msg.TextColor3 = COLORS.text
    msg.Text = "Are you sure you want to unload the script?"
    msg.TextWrapped = true
    msg.TextXAlignment = Enum.TextXAlignment.Center
    msg.Parent = pop

    local btnNo = Instance.new("TextButton")
    btnNo.Size = UDim2.new(0.44, -8, 0, 36)
    btnNo.Position = UDim2.new(0, 12, 1, -48)
    btnNo.BackgroundColor3 = COLORS.panelDark
    btnNo.Font = Enum.Font.GothamBold
    btnNo.TextSize = 16
    btnNo.TextColor3 = COLORS.text
    btnNo.Text = "No.."
    btnNo.Parent = pop
    local noCorner = Instance.new("UICorner") noCorner.CornerRadius = UDim.new(0,6) noCorner.Parent = btnNo

    local btnYes = Instance.new("TextButton")
    btnYes.Size = UDim2.new(0.44, -8, 0, 36)
    btnYes.Position = UDim2.new(1, -12 - (pop.Size.X.Offset * 0), 1, -48)
    btnYes.AnchorPoint = Vector2.new(1, 0)
    btnYes.BackgroundColor3 = COLORS.panelDark
    btnYes.Font = Enum.Font.GothamBold
    btnYes.TextSize = 16
    btnYes.TextColor3 = COLORS.close
    btnYes.Text = "Yes!"
    btnYes.Parent = pop
    local yesCorner = Instance.new("UICorner") yesCorner.CornerRadius = UDim.new(0,6) yesCorner.Parent = btnYes
    -- ** yes button hover color
    btnYes.MouseEnter:Connect(function() btnYes.TextColor3 = COLORS.closeHover end)
    btnYes.MouseLeave:Connect(function() btnYes.TextColor3 = COLORS.close end)

    btnNo.MouseButton1Click:Connect(function()
        pop:Destroy()
    end)

    btnYes.MouseButton1Click:Connect(function()
        -- ** call unload handlers then destroy GUI
        if type(_G) == "table" and _G.TemptUI and type(_G.TemptUI.RunUnload) == "function" then
            pcall(_G.TemptUI.RunUnload)
        end
    end)
end

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 6)
closeBtn.AnchorPoint = Vector2.new(0,0)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Text = "X"
closeBtn.TextColor3 = COLORS.close
closeBtn.Parent = root
closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = COLORS.closeHover end)
closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = COLORS.close end)
closeBtn.MouseButton1Click:Connect(function()
    showUnloadConfirm()
end)

---------------------------------------------------------------------------


-- ** tab selection
local function selectTab(button, page)
    for _,c in ipairs(tabsBar:GetChildren()) do
        if c:IsA("TextButton") then
            c.TextColor3 = COLORS.textDim
            c.Position = UDim2.new(c.Position.X.Scale, c.Position.X.Offset, 0, 6)
        end
    end
    for _,p in ipairs(pages:GetChildren()) do
        if p:IsA("Frame") then p.Visible = false end
    end
    button.TextColor3 = COLORS.white
    button.Position = UDim2.new(button.Position.X.Scale, button.Position.X.Offset, 0, -4)
    page.Visible = true
end

------------------------------------------------------------------------- 

-- ** All Tabs **

-- Visuals Tab
local visualTab = makeTab("Visuals", tabsBar, pages, selectTab, { Left = "ESP Related", Right = "Other" })
visualTab.button.Position = UDim2.new(0,0,0,6)
visualTab.page.Parent = pages
selectTab(visualTab.button, visualTab.page)

-------------------------------------------------------------------------

-- ** Visuals Tab Stuff **

local rakeToggle = makeToggle(visualTab.LeftCol, "Rake")
local playersToggle = makeToggle(visualTab.LeftCol, "Players")
local locationMarkersToggle = makeToggle(visualTab.LeftCol, "Location Markers")
local textBackgroundToggle = makeToggle(visualTab.LeftCol, "Location Background")

-- ** Loc marker places dropdown
local locationItems = { "Safe House", "Base Camp", "Observation Tower", "Power Station", "Shop" }
    local locationDropdown = makeDropDownList(visualTab.LeftCol, "Location Marker Places", locationItems)


-- ** Save Visuals to config
BindToggleToConfig(rakeToggle, "visuals.rakeESP", false)
BindToggleToConfig(playersToggle, "visuals.playersESP", false)
BindToggleToConfig(locationMarkersToggle, "visuals.locationMarkers", false)
BindToggleToConfig(textBackgroundToggle, "visuals.textBackground", false)

-------------------------------------------------------------------------

-- ** Public UI helpers
_G.TemptUI = {
    makeToggle = makeToggle,
    makeTab = makeTab,
    root = root,
    tabs = {
        Visuals = visualTab,
    },
    rakeToggle = rakeToggle,
    playersToggle = playersToggle,
    makeDropDownList = makeDropDownList,
    RegisterUnload = nil,
    RunUnload = nil,
    Config = {
        Get = GetConfig,
        Set = SetConfig,
        Save = SaveConfig,
        BindToggle = BindToggleToConfig,
    },
}

-------------- Break --------------------

-- unload handlers registry
local UnloadHandlers = {}
local function RegisterUnload(fn)
    if type(fn) == "function" then
        table.insert(UnloadHandlers, fn)
    end
end

local function RunUnload()
    -- call handlers (best-effort)
    for _, fn in ipairs(UnloadHandlers) do
        pcall(fn)
    end
    -- save config then remove GUI
    pcall(SaveConfig)
    pcall(function()
        if gui and gui.Parent then gui:Destroy() end
    end)
end

_G.TemptUI.RegisterUnload = RegisterUnload
_G.TemptUI.RunUnload = RunUnload

--------------------------------------------------------------------------

-- ** Code Starts Here ** --

-- ** ESP Logic

-- colors (Not a part of GUI palette)
local PLAYER_FILL = Color3.fromRGB(0, 120, 255)
local PLAYER_OUTLINE = Color3.fromRGB(255, 255, 255)
local RAKE_FILL = Color3.fromRGB(255, 50, 50)
local RAKE_OUTLINE = Color3.fromRGB(255, 0, 0)

-- players ESP state
local playerData = {}
local playersConns = {}

local function makeHighlight(adornee, fill, outline)
    if not adornee then return nil end
    local h = Instance.new("Highlight")
    h.Adornee = adornee
    h.FillColor = fill
    h.OutlineColor = outline
    h.Parent = Workspace
    return h
end

local function makeNameBillboard(part, text, color)
    if not (part and part:IsA("BasePart")) then return nil end
    local bg = Instance.new("BillboardGui")
    bg.Name = "ESPName"
    bg.Adornee = part
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 150, 0, 25)
    bg.StudsOffset = Vector3.new(0, 2.2, 0)
    bg.Parent = part

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.6
    label.TextScaled = true
    label.Parent = bg

    return bg
end

local function cleanupPlayer(player)
    local data = playerData[player]
    if not data then return end
    if data.charConn and data.charConn.Disconnect then
        data.charConn:Disconnect()
    end
    if data.highlight and data.highlight.Parent then
        data.highlight:Destroy()
    end
    if data.billboard and data.billboard.Parent then
        data.billboard:Destroy()
    end
    playerData[player] = nil
end

local function handleCharacter(player, character)
    cleanupPlayer(player)
    if not character then return end
    local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 2)

    local highlight = makeHighlight(character, PLAYER_FILL, PLAYER_OUTLINE)
    local billboard = head and makeNameBillboard(head, player.Name, PLAYER_OUTLINE)

    local conn = character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanupPlayer(player)
        end
    end)

    playerData[player] = { charConn = conn, highlight = highlight, billboard = billboard }
end

local function onPlayerAdded_internal(player)
    if player == Players.LocalPlayer then
        local conn = player.CharacterAdded:Connect(function() end)
        playerData[player] = playerData[player] or {}
        playerData[player].topConn = conn
        return
    end

    if player.Character then
        handleCharacter(player, player.Character)
    end
    local conn = player.CharacterAdded:Connect(function(char)
        handleCharacter(player, char)
    end)
    playerData[player] = playerData[player] or {}
    playerData[player].topConn = conn
end

local function onPlayerRemoving_internal(player)
    local data = playerData[player]
    if data and data.topConn and data.topConn.Disconnect then
        data.topConn:Disconnect()
    end
    cleanupPlayer(player)
end

-- ** Rake ESP state
local rake = nil
local rakeConn = nil

local function cleanupRake()
    if rake then
        if rake.conn and rake.conn.Disconnect then
            rake.conn:Disconnect()
        end
        if rake.highlight and rake.highlight.Parent then
            rake.highlight:Destroy()
        end
        if rake.billboard and rake.billboard.Parent then
            rake.billboard:Destroy()
        end
        rake = nil
    end
end

local function setupRake(model)
    if not (model and model:IsA("Model")) then return end
    cleanupRake()
    local highlight = makeHighlight(model, RAKE_FILL, RAKE_OUTLINE)
    local head = model:FindFirstChild("Head") or model:WaitForChild("Head", 2)
    local billboard = head and makeNameBillboard(head, "Rake", RAKE_OUTLINE)

    local conn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanupRake()
        end
    end)

    rake = { highlight = highlight, billboard = billboard, conn = conn }
end

local function onWorkspaceChildAdded_internal(child)
    if child and child.Name == "Rake" and child:IsA("Model") then
        setupRake(child)
    end
end

local function onWorkspaceChildRemoved_internal(child)
    if child and child.Name == "Rake" then
        cleanupRake()
    end
end

-- ** players control
local function StartPlayers()
    for _, p in ipairs(Players:GetPlayers()) do
        onPlayerAdded_internal(p)
    end
    table.insert(playersConns, Players.PlayerAdded:Connect(onPlayerAdded_internal))
    table.insert(playersConns, Players.PlayerRemoving:Connect(onPlayerRemoving_internal))
end

local function StopPlayers()
    for _, c in ipairs(playersConns) do
        if c and c.Disconnect then c:Disconnect() end
    end
    playersConns = {}
    for player, _ in pairs(playerData) do
        onPlayerRemoving_internal(player)
    end
end

-- ** Rake control
local function StartRake()
    local existing = Workspace:FindFirstChild("Rake")
    if existing and existing:IsA("Model") then
        setupRake(existing)
    end
    rakeConn = Workspace.ChildAdded:Connect(onWorkspaceChildAdded_internal)
    -- ** listen for removal too
    table.insert(playersConns, Workspace.ChildRemoved:Connect(onWorkspaceChildRemoved_internal))
end

local function StopRake()
    if rakeConn and rakeConn.Disconnect then rakeConn:Disconnect() end
    rakeConn = nil
    cleanupRake()
end

local ESP = {}
function ESP.EnablePlayers(enable)
    if enable then
        StartPlayers()
    else
        StopPlayers()
    end
end
function ESP.EnableRake(enable)
    if enable then
        StartRake()
    else
        StopRake()
    end
end

------------------ Break ----------------------

-- ** bind toggles to esp 
do
    local pApi = ToggleAPI[playersToggle]
    if pApi then
        local prev = pApi.OnToggle
        pApi.OnToggle = function(state)
            if prev then pcall(prev, state) end
            ESP.EnablePlayers(state)
        end
        pcall(function() pApi.Set(pApi.Get()) end)
    end

    local rApi = ToggleAPI[rakeToggle]
    if rApi then
        local prev = rApi.OnToggle
        rApi.OnToggle = function(state)
            if prev then pcall(prev, state) end
            ESP.EnableRake(state)
        end
        pcall(function() rApi.Set(rApi.Get()) end)
    end
end

-- ** so that ESP stops on unload
if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
    _G.TemptUI.RegisterUnload(function()
        pcall(StopPlayers)
        pcall(StopRake)
    end)
end

-- ** ESP Logic Ends Here ** --

--------------------------------------------------------------------------

-- ** Location Markers Logic ** --


local MARKER_DEFS = {
    { id = "SafeHouse", name = "Safe House", pos = Vector3.new(-363.56, 16.48, 74.48) },
    { id = "BaseCamp", name = "Base Camp", pos = Vector3.new(-43.67, 17.61, 202.36) },
    { id = "Tower", name = "Observation Tower", pos = Vector3.new(64.43, 13.49, -55.44) },
    { id = "PowerStation", name = "Power Station", pos = Vector3.new(-295.83, 20.00, -201.65) },
    { id = "Shop", name = "Shop", pos = Vector3.new(-24.29, 16.24, -254.70) },
}

local locStates = GetConfig("visuals.locationMarkers", nil)
if type(locStates) ~= "table" then
    locStates = {}
    for _, d in ipairs(MARKER_DEFS) do locStates[d.id] = true end
        SetConfig("visuals.locationMarkers", locStates)
end

local markers = {}

local textBackgroundEnabled = GetConfig("visuals.textBackground", false)
local tbApiInit = ToggleAPI[textBackgroundToggle]
if tbApiInit then
    textBackgroundEnabled = tbApiInit.Get()
end
local markersFolder = Workspace:FindFirstChild("TemptMarkers")
if not markersFolder then
    markersFolder = Instance.new("Folder")
    markersFolder.Name = "TemptMarkers"
    markersFolder.Parent = Workspace
end

local function createMarker(def)
    if markers[def.id] then return end
    local part = Instance.new("Part")
    part.Name = "LocationMarker_" .. def.id
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1,1,1)
    part.Position = def.pos
    part.Parent = markersFolder

    local bgEnabled = false
    local tbApi = ToggleAPI[textBackgroundToggle]
    if tbApi then bgEnabled = tbApi.Get() else bgEnabled = GetConfig("visuals.textBackground", false) end

    local gui = Instance.new("BillboardGui")
    gui.Name = "LMGui_" .. def.id
    gui.Adornee = part
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 180, 0, 32)
    gui.StudsOffset = Vector3.new(0, 2.2, 0)
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = textBackgroundEnabled and 0 or 1
    label.BackgroundColor3 = COLORS.panelDark
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.Text = def.name
    label.TextColor3 = COLORS.text
    label.TextScaled = true
    label.Parent = gui

    markers[def.id] = { part = part, gui = gui, label = label }
end

local function destroyMarker(id)
    local m = markers[id]
    if not m then return end
    pcall(function()
        if m.gui then m.gui:Destroy() end
        if m.part then m.part:Destroy() end
    end)
    markers[id] = nil
end

local function refreshMarkers()
    local globalEnabled = false
    local lmApi = ToggleAPI[locationMarkersToggle]
    if lmApi then globalEnabled = lmApi.Get() else globalEnabled = GetConfig("visuals.locationMarkers", false) end

    for _, def in ipairs(MARKER_DEFS) do
        local enabled = locStates[def.id] == true
        if enabled and globalEnabled then
            createMarker(def)
        else
            destroyMarker(def.id)
        end
    end
end

----------------- Break for UI ----------------------

-- ** UI for location markers
local markerNames = {}
for _, d in ipairs(MARKER_DEFS) do table.insert(markerNames, d.name) end

-- ** save changes
local locApi = DropdownAPI[locationDropdown]
if locApi then
    locApi.OnSelect = function(index, value)
        local def = MARKER_DEFS[index]
        if not def then return end
        -- toggle explicitly as boolean
        locStates[def.id] = not (locStates[def.id] == true)
        SetConfig("visuals.locationMarkers", locStates)
        refreshMarkers()
    end
    for i, def in ipairs(MARKER_DEFS) do
        locApi.SetSelected(i, locStates[def.id] == true)
    end
end

-- ** refresh markers when toggles change
do
    local lmApi = ToggleAPI[locationMarkersToggle]
    if lmApi then
        local prev = lmApi.OnToggle
        lmApi.OnToggle = function(s)
            if prev then pcall(prev, s) end
            refreshMarkers()
        end
    end
    local tbApi = ToggleAPI[textBackgroundToggle]
    if tbApi then
        local prev2 = tbApi.OnToggle
        tbApi.OnToggle = function(s)
            if prev2 then pcall(prev2, s) end
            textBackgroundEnabled = (s == true)
            local desired = textBackgroundEnabled and 0 or 1
            for _, def in ipairs(MARKER_DEFS) do
                local m = markers[def.id]
                if m and m.label then
                    if m.label.BackgroundTransparency ~= desired then
                        m.label.BackgroundTransparency = desired
                    end
                end
            end
        end
    end
end

------------------ Break for Unload ----------------------

refreshMarkers()

-- ** clean them up on unload
if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
    _G.TemptUI.RegisterUnload(function()
        for _, d in ipairs(MARKER_DEFS) do destroyMarker(d.id) end
        pcall(function()
            if markersFolder and markersFolder.Parent then markersFolder:Destroy() end
        end)
    end)
end

-- ** Location Markers Logic Ends Here ** --

--------------------------------------------------------------------------
