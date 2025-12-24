-- ─────────────── ✦ REMASTERED VERSION OF TRK Exploit ✦ ───────────────
--  Created by: primesto.fx
--  Maintained by: primesto.fx & therealowner69
--  DM on Discord for requests: primesto.fx // therealowner69
-- ────────────────────────────────────────────────────────────────


local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RepStorage = game:GetService("ReplicatedStorage") -- Dupe, but still needed

---------------------------------------------------------------------------

-- ** Interactables API ** --

local ToggleAPI = setmetatable({}, { __mode = "k" })
local DropdownAPI = setmetatable({}, { __mode = "k" })
local KeybindAPI = setmetatable({}, { __mode = "k" })
local SliderAPI = setmetatable({}, { __mode = "k" })
local ButtonAPI = setmetatable({}, { __mode = "k" })

--------------------------------------------------------------------------

-- ** Notification tracking ** --

local RECENT_NOTIFS = setmetatable({}, { __mode = "k" })

---------------------------------------------------------------------------

-- ** Model tracking ** --

local supplyConns = setmetatable({}, { __mode = "k" }) -- ** deprecated
local scrapConns = setmetatable({}, { __mode = "k" }) -- deprecated

---------------------------------------------------------------------------

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

    if tabsParent then btn.Parent = tabsParent end
    if pagesParent then page.Parent = pagesParent end

    if tabsParent then
        pcall(function()
            local btnWidth = 120
            local spacing = 8
            local idx = 0
            for _,c in ipairs(tabsParent:GetChildren()) do
                if c:IsA("TextButton") and c ~= btn then
                    idx = idx + 1
                end
            end
            btn.Position = UDim2.new(0, idx * (btnWidth + spacing), 0, 6)
        end)
    end


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
        frame.Size = UDim2.new(1, 0, 0, 34)
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

-- ** makeNotification
local function makeNotification(text, duration, parent)
    local dur = (type(duration) == "number" and duration > 0) and duration or 3
    local parentGui
    do
        local Players = game:GetService("Players")
        local CoreGui = game:GetService("CoreGui")
        local lp = Players and Players.LocalPlayer
        -- if caller provided a parent and it's NOT the main `gui` (SCREEN_GUI), use it
        if parent and parent ~= gui then
            parentGui = parent
        else
            parentGui = CoreGui:FindFirstChild("Tempt_Notifications")
            if not parentGui then
                local created = Instance.new("ScreenGui")
                created.Name = "Tempt_Notifications"
                created.ResetOnSpawn = false
                created.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                local ok = pcall(function() created.Parent = CoreGui end)
                if not ok then
                    if lp and lp:FindFirstChild("PlayerGui") then
                        created.Parent = lp:WaitForChild("PlayerGui")
                    else
                        pcall(function() created.Parent = CoreGui end)
                    end
                end
                pcall(function() created.DisplayOrder = 1000 end)
                parentGui = created
            end
        end
    end

    local ok2, blocked = pcall(function()
        local api = ToggleAPI[enableNotificationsToggle]
        if api and type(api.Get) == "function" then
            return not api.Get()
        end
        return false
    end)
    if ok2 and blocked then return nil end

    if NOTIFICATIONS_ENABLED == false then return nil end

    local holder = parentGui:FindFirstChild("TemptNotificationsHolder")
    if not holder then
        holder = Instance.new("Frame")
        holder.Name = "TemptNotificationsHolder"
        holder.Size = UDim2.new(0, 420, 0, 200)
        holder.AnchorPoint = Vector2.new(1, 1)
        holder.Position = UDim2.new(1, -12, 1, -12)
        holder.BackgroundTransparency = 1
        holder.ZIndex = 10000
        holder.Parent = parentGui
        local layout = Instance.new("UIListLayout")
        layout.Name = "TemptNotificationsLayout"
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Parent = holder
        local pad = Instance.new("UIPadding") pad.Parent = holder
        pad.PaddingRight = UDim.new(0, 0)
        pad.PaddingBottom = UDim.new(0, 0)
    end

    local container = Instance.new("Frame")
    container.Name = "TemptNotification"
    container.Size = UDim2.new(0, 420, 0, 56)
    container.BackgroundColor3 = COLORS.panelDark
    container.BorderSizePixel = 0
    container.ZIndex = holder.ZIndex
    container.LayoutOrder = math.floor(tick() * 1000)
    container.Parent = holder
    local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(0,10) cCorner.Parent = container

    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(1, -12, 1, -12)
    inner.Position = UDim2.new(0,6,0,6)
    inner.BackgroundTransparency = 1
    inner.ZIndex = container.ZIndex + 1
    inner.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, -12)
    label.Position = UDim2.new(0, 0, 0, 4)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Text = tostring(text or "Notification")
    label.TextColor3 = COLORS.text
    label.TextStrokeTransparency = 0.7
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ZIndex = container.ZIndex + 2
    label.Parent = inner

    -- ** the progress bar
    local barHolder = Instance.new("Frame")
    barHolder.Size = UDim2.new(1, -12, 0, 6)
    barHolder.Position = UDim2.new(0, 6, 1, -10)
    barHolder.BackgroundTransparency = 1
    barHolder.ZIndex = container.ZIndex + 1
    barHolder.Parent = container

    local prog = Instance.new("Frame")
    prog.AnchorPoint = Vector2.new(1, 0)
    prog.Position = UDim2.new(1, 0, 0, 0)
    prog.Size = UDim2.new(1, 0, 1, 0)
    prog.BackgroundColor3 = COLORS.white
    prog.BorderSizePixel = 0
    prog.ZIndex = container.ZIndex + 2
    prog.Parent = barHolder
    local progCorner = Instance.new("UICorner") progCorner.CornerRadius = UDim.new(0,3) progCorner.Parent = prog

    local ts = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    pcall(function()
        container.Size = UDim2.new(0, 420, 0, 0)
        TweenService:Create(container, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 420, 0, 56)}):Play()
    end)

    -- ** animate progress bar
    local progTween = TweenService:Create(prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
    progTween:Play()

    -- ** auto destroy: shrink then remove
    task.delay(dur, function()
        pcall(function()
            TweenService:Create(container, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 420, 0, 0), BackgroundTransparency = 1}):Play()
            TweenService:Create(label, TweenInfo.new(0.22), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
        end)
        task.delay(0.26, function()
            pcall(function() container:Destroy() end)
        end)
    end)

    return container
end


spawn(function()
    for i=1,60 do
        local api = ToggleAPI[enableNotificationsToggle]
        if api then
            local prev = api.OnToggle
            api.OnToggle = function(state)
                if prev then pcall(prev, state) end
                if not state then
                    pcall(function()
                        local CoreGui = game:GetService("CoreGui")
                        local Players = game:GetService("Players")
                        local root = CoreGui:FindFirstChild("Tempt_Notifications")
                        if not root and Players and Players.LocalPlayer then
                            local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
                            if pg then root = pg:FindFirstChild("Tempt_Notifications") end
                        end
                        if root then
                            local holder = root:FindFirstChild("TemptNotificationsHolder")
                            if holder then holder:Destroy() end
                        end
                    end)
                end
            end
            break
        end
        task.wait(0.1)
    end
end)

--------------------------------------------------------------------------

-- ** makeButton
local function makeButton(parent, labelText)
    local frame = Instance.new("Frame")
    frame.Name = tostring(labelText or "Button")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.72, -6, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText or "Button"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextColor3 = COLORS.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 84, 0, 26)
    btn.AnchorPoint = Vector2.new(1,0.5)
    btn.Position = UDim2.new(1, -8, 0.5, 0)
    btn.BackgroundColor3 = COLORS.panelDark
    btn.AutoButtonColor = true
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.TextColor3 = COLORS.text
    btn.Text = "Click"
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = btn

    -- ** Register API entry
    if type(ButtonAPI) ~= "table" then
        ButtonAPI = setmetatable({}, { __mode = "k" })
    end
    ButtonAPI[frame] = {
        OnClick = nil,
        Click = function()
            local api = ButtonAPI[frame]
            if api and type(api.OnClick) == "function" then pcall(api.OnClick) end
        end,
    }

    btn.MouseButton1Click:Connect(function()
        local api = ButtonAPI[frame]
        if api and type(api.OnClick) == "function" then pcall(api.OnClick) end
    end)

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

-- ** makeSlider

local function makeSlider(parent, labelText, minVal, maxVal, defaultVal)
    local MIN = (type(minVal) == "number") and minVal or 1
    local MAX = (type(maxVal) == "number") and maxVal or 100
    local initial = (type(defaultVal) == "number") and defaultVal or math.floor((MIN + MAX) / 2)

    local frame = Instance.new("Frame")
    frame.Name = tostring(labelText or "Slider")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, -6, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText or "Slider"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextColor3 = COLORS.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local holder = Instance.new("Frame")
    holder.AnchorPoint = Vector2.new(1, 0)
    holder.Position = UDim2.new(1, -8, 0, 2)
    holder.Size = UDim2.new(0.6, -8, 1, -4)
    holder.BackgroundTransparency = 1
    holder.Parent = frame

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(1, 0, 0, 12)
    bar.Position = UDim2.new(0, 0, 0.5, -6)
    bar.BackgroundColor3 = COLORS.panelDark
    bar.BorderSizePixel = 0
    bar.Parent = holder
    local barCorner = Instance.new("UICorner") barCorner.CornerRadius = UDim.new(0,6) barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    local fillCorner = Instance.new("UICorner") fillCorner.CornerRadius = UDim.new(0,6) fillCorner.Parent = fill

    local handle = Instance.new("TextButton")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(0, -8, 0.5, -8)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.AutoButtonColor = false
    handle.BackgroundColor3 = COLORS.panel
    handle.Text = ""
    handle.Parent = bar
    local handleCorner = Instance.new("UICorner") handleCorner.CornerRadius = UDim.new(0,8) handleCorner.Parent = handle

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0.5, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.25, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = COLORS.text
    valueLabel.Text = tostring(initial)
    valueLabel.Parent = holder
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.TextYAlignment = Enum.TextYAlignment.Center

    -------------------- Continue from UI --------------------

    -- ** internal state
    local dragging = false
    local current = math.clamp(initial, MIN, MAX)

    local function setValue(v)
        v = math.floor(math.clamp(v or MIN, MIN, MAX))
        local prev = current
        current = v
        local pct = 0
        if MAX > MIN then pct = (current - MIN) / (MAX - MIN) end
        fill.Size = UDim2.new(pct, 0, 1, 0)
        handle.Position = UDim2.new(pct, 0, 0.5, 0)
        valueLabel.Text = tostring(current)
        if current ~= prev then
            local api = SliderAPI[frame]
            if api and type(api.OnChange) == "function" then pcall(api.OnChange, current) end
        end
    end

    local function inputToValue(inputX)
        local absPos = inputX - bar.AbsolutePosition.X
        local w = bar.AbsoluteSize.X
        local pct = 0
        if w > 0 then pct = math.clamp(absPos / w, 0, 1) end
        local v = math.floor(MIN + pct * (MAX - MIN) + 0.5)
        return v
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            pcall(function() handle:CaptureFocus() end)
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            pcall(function() handle:ReleaseFocus() end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local v = inputToValue(input.Position.X)
            setValue(v)
        end
    end)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local v = inputToValue(input.Position.X)
            setValue(v)
        end
    end)

    -- ** API
    SliderAPI[frame] = {
        Get = function() return current end,
        Set = function(v) setValue(v) end,
        OnChange = nil,
        Min = MIN,
        Max = MAX,
    }

    local maxOrder = 0
    for _,c in ipairs(parent:GetChildren()) do
        if c ~= frame and (c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton")) then
            maxOrder = math.max(maxOrder, c.LayoutOrder or 0)
        end
    end
    frame.LayoutOrder = maxOrder + 1

    if bar.AbsoluteSize and bar.AbsoluteSize.X > 0 then
        pcall(setValue, current)
    else
        local conn
        conn = bar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            if bar.AbsoluteSize and bar.AbsoluteSize.X > 0 then
                pcall(setValue, current)
                pcall(function() if conn and conn.Disconnect then conn:Disconnect() end end)
            end
        end)
        task.delay(0.1, function()
            pcall(setValue, current)
            pcall(function() if conn and conn.Disconnect then conn:Disconnect() end end)
        end)
    end
    return frame
end

--------------------------------------------------------------------------


-- ** makeKeyBindButton
local function makeKeyBindButton(parent, title, defaultKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,34)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -6, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title or "Keybind"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextColor3 = COLORS.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Name = frame.Name .. "_Bind"
    btn.Size = UDim2.new(0.5, -8, 1, 0)
    btn.AnchorPoint = Vector2.new(1,0)
    btn.Position = UDim2.new(1, -8, 0, 0)
    btn.BackgroundColor3 = COLORS.panelDark
    btn.AutoButtonColor = true
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.TextColor3 = COLORS.text
    btn.Text = "None"
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(0,6) btnCorner.Parent = btn

    local function keyName(k)
        if not k then return "None" end
        if typeof(k) == "EnumItem" then return k.Name end
        return tostring(k)
    end

    local current = nil
    if defaultKey then
        if typeof(defaultKey) == "EnumItem" then current = defaultKey end
    end

    local listening = false
    local pending = nil
    local inputConn = nil

    local function updateText()
        if listening then
            btn.Text = 'Press enter to save keybind to "' .. (title or "keybind") .. '"!'
        else
            btn.Text = keyName(current)
        end
    end

    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        pending = nil
        updateText()
        task.wait(0.05)
        inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local kc = input.KeyCode
            if kc == Enum.KeyCode.Unknown then return end
            if kc == Enum.KeyCode.Return or kc == Enum.KeyCode.KeypadEnter then
                if pending then
                    current = pending
                    local api = KeybindAPI[frame]
                    if api and type(api.OnBind) == "function" then
                        pcall(api.OnBind, current)
                    end
                end
                listening = false
                if inputConn then inputConn:Disconnect() inputConn = nil end
                updateText()
            elseif kc == Enum.KeyCode.Escape then
                listening = false
                pending = nil
                if inputConn then inputConn:Disconnect() inputConn = nil end
                updateText()
            else
                pending = kc
                btn.Text = kc.Name .. " (Press Enter to save)"
            end
        end)
    end)

    KeybindAPI[frame] = {
        Get = function() return current end,
        Set = function(k)
            if typeof(k) == "EnumItem" then current = k else current = nil end
            updateText()
        end,
        OnBind = nil,
    }

    -- ** layout order
    local maxOrder = 0
    for _,c in ipairs(parent:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton") then
            if c.LayoutOrder and c.LayoutOrder > maxOrder then maxOrder = c.LayoutOrder end
        end
    end
    frame.LayoutOrder = maxOrder + 1

    updateText()
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
local NOTIFICATIONS_ENABLED = nil

local function SaveConfig()
    writeConfig(Config)
end

local function SetConfig(key, value)
    Config[key] = value
    SaveConfig()
end

do
    local ok, v = pcall(function() return Config["settings.enableNotifications"] end)
    if ok and type(v) == "boolean" then
        NOTIFICATIONS_ENABLED = v
    else
        NOTIFICATIONS_ENABLED = true
    end
    local _origSetConfig = SetConfig
    SetConfig = function(key, value)
        Config[key] = value
        if key == "settings.enableNotifications" then
            NOTIFICATIONS_ENABLED = not not value
        end
        SaveConfig()
    end
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

------------ Break for Dragable ------------
tabsBar.Active = true
do
    local dragging = false
    local dragStart, startPos
    tabsBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- ** dragable
            local overGui = false
            pcall(function()
                local objs = UserInputService:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
                for _, o in ipairs(objs or {}) do
                    if o and (o:IsA("TextButton") or o:IsA("ImageButton") or o:IsA("TextBox")) then
                        overGui = true
                        break
                    end
                end
            end)
            if overGui then return end
            dragging = true
            dragStart = input.Position
            startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

------------ Continue ------------

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
local visualTab = makeTab("Visuals", tabsBar, pages, selectTab, { Left = "General", Right = "Rake Related" })
visualTab.page.Parent = pages
selectTab(visualTab.button, visualTab.page)


-- ** Player Tab
local playerTab = makeTab("Player", tabsBar, pages, selectTab, { Left = "General", Right = "Advanced" })
playerTab.page.Parent = pages
selectTab(playerTab.button, playerTab.page)

-- ** Game Tab
local gameTab = makeTab("Game", tabsBar, pages, selectTab, { Left = "General", Right = "Advanced" })
gameTab.page.Parent = pages
selectTab(gameTab.button, gameTab.page)

-- Settings Tab
local settingsTab = makeTab("Settings", tabsBar, pages, selectTab, { Left = "General", Right = "Advanced" })
settingsTab.page.Parent = pages
selectTab(settingsTab.button, settingsTab.page)


-------------------------------------------------------------------------

-- ** Visuals Tab Stuff **

local rakeToggle = makeToggle(visualTab.LeftCol, "Rake") -- 1vst
local playersToggle = makeToggle(visualTab.LeftCol, "Players") -- 2vst
local locationMarkersToggle = makeToggle(visualTab.LeftCol, "Location Markers") -- 3vst
local textBackgroundToggle = makeToggle(visualTab.LeftCol, "Location Background") -- 4vst
local rakeMeterToggle = makeToggle(visualTab.RightCol, "Rake Meter") -- 5vst

local locationItems = { "Safe House", "Base Camp", "Observation Tower", "Power Station", "Shop" }
    local locationDropdown = makeDropDownList(visualTab.LeftCol, "Location Marker Places", locationItems)

local fullBrightToggle = makeToggle(visualTab.LeftCol, "Full Bright") -- 6vst
local rakeHealthToggle = makeToggle(visualTab.RightCol, "Rake Health") -- 7vst
local removeFogToggle = makeToggle(visualTab.LeftCol, "Remove Fog") -- 8vst

-- ** Save Visuals to config
BindToggleToConfig(rakeToggle, "visuals.rakeESP", false)
BindToggleToConfig(playersToggle, "visuals.playersESP", false)
BindToggleToConfig(locationMarkersToggle, "visuals.locationMarkers", false)
BindToggleToConfig(textBackgroundToggle, "visuals.textBackground", false)
BindToggleToConfig(rakeMeterToggle, "visuals.rakeMeter", false)
BindToggleToConfig(fullBrightToggle, "visuals.fullBright", false)
BindToggleToConfig(rakeHealthToggle, "visuals.rakeHealth", false)
BindToggleToConfig(removeFogToggle, "visuals.removeFog", false)

---------------------------------------------------------------------------

-- ** Settings Tab Stuff **

local showGUIOnLoadToggle = makeToggle(settingsTab.LeftCol, "Show GUI on load")
local autoScaleESPNameToggle = makeToggle(settingsTab.LeftCol, "Auto-Scale ESP Name")
local autoHideWhenRakeCloseToggle = makeToggle(settingsTab.RightCol, "Auto-hide when Rake is close")
local enableNotificationsToggle = makeToggle(settingsTab.LeftCol, "Enable Notifications")

-- ** Save Settings to config
BindToggleToConfig(showGUIOnLoadToggle, "settings.showGUIOnLoad", true)
BindToggleToConfig(autoScaleESPNameToggle, "settings.autoScaleESPName", false)
BindToggleToConfig(autoHideWhenRakeCloseToggle, "settings.autoHideWhenRakeClose", false)
BindToggleToConfig(enableNotificationsToggle, "settings.enableNotifications", true)


-------------------- Break for Close/Open --------------------

do
    local savedClose = GetConfig("settings.closeOpenKey", nil)
    local defaultClose = nil
    if type(savedClose) == "string" and Enum.KeyCode[savedClose] then
        defaultClose = Enum.KeyCode[savedClose]
    else
        defaultClose = Enum.KeyCode.Insert
    end

    -- ** so it appears in settings tab
    closeBind = makeKeyBindButton(settingsTab.LeftCol, "Close/Open GUI", defaultClose)
    local cbApi = KeybindAPI[closeBind]
    if cbApi and type(cbApi.Set) == "function" then cbApi.Set(defaultClose) end
end

-------------------- Continue from Close/Open --------------------

-- ** Player Tab Stuff **

local playerSpeedToggle = makeToggle(playerTab.LeftCol, "Player Speed")
local removeFallDamageToggle = makeToggle(playerTab.RightCol, "Remove Fall Damage")



-- ** Save Player to config
BindToggleToConfig(playerSpeedToggle, "player.playerSpeed", false)
BindToggleToConfig(removeFallDamageToggle, "player.removeFallDamage", false)
BindToggleToConfig(rakeKillAuraToggle, "player.rakeKillAura", false)



-------------------- Break from Player Speed --------------------

do
    local defaultSpeed = GetConfig("player.speedValue", 1)
    local speedSlider = makeSlider(playerTab.LeftCol, "Speed Value", 1, 30, defaultSpeed)
    local sApi = SliderAPI[speedSlider]
    if sApi and type(sApi.Set) == "function" then sApi.Set(defaultSpeed) end
    if sApi then
        local prev = sApi.OnChange
        sApi.OnChange = function(v)
            if prev then pcall(prev, v) end
            pcall(function() SetConfig("player.speedValue", v) end)
            -- apply immediately if toggle is enabled
            local tApi = ToggleAPI[playerSpeedToggle]
            local enabled = tApi and type(tApi.Get) == "function" and tApi.Get()
            if enabled then
                pcall(function()
                    local char = player and player.Character
                    if not char then return end
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid:IsA("Humanoid") then
                        if humanoid:GetState() ~= Enum.HumanoidStateType.Climbing then
                            humanoid.WalkSpeed = v
                        end
                    end
                end)
            end
        end
    end
end

-------------------- Continue from Player Speed --------------------  

local rakeKillAuraToggle = makeToggle(playerTab.RightCol, "Rake Kill Aura")
local kbFrame = makeKeyBindButton(playerTab.RightCol, "Keybind for Kill Aura")


--------------------------------------------------------------------------

-- ** Game Tab Stuff **

local showPowerLevelToggle = makeToggle(gameTab.LeftCol, "Show Power Level") -- 1gst
local bringScrapsButton = makeButton(gameTab.LeftCol, "Bring Scraps") -- 2gst
local showObjectFinderToggle = makeToggle(gameTab.RightCol, "Object Finder") -- 3gst

-------------------- Break for Object List --------------------

local objectListItems = { "Traps", "Scrap", "Flaregun", "Supply Drop" }
local objectListDropdown = makeDropDownList(gameTab.RightCol, "Object List", objectListItems)
local objectListConfigKey = "game.objectFinder.objects"
local stored = GetConfig(objectListConfigKey, nil)
if type(stored) ~= "table" then
    stored = {}
    for i=1,#objectListItems do stored[i] = true end
    SetConfig(objectListConfigKey, stored)
end
local objApi = DropdownAPI[objectListDropdown]
if objApi then
    objApi.OnSelect = function(index, value, selected)
        stored[index] = selected == true
        SetConfig(objectListConfigKey, stored)
        local tApi = ToggleAPI[showObjectFinderToggle]
        if tApi and type(tApi.Get) == "function" and tApi.Get() and type(tApi.Set) == "function" then
            tApi.Set(false)
            tApi.Set(true)
        end
    end
    for i=1,#objectListItems do objApi.SetSelected(i, stored[i] == true) end
end

-------------------- Continue from Object List --------------------

local bypassSafeHouseDoorToggle = makeToggle(gameTab.RightCol, "Bypass Safe House Door") -- 4gst
local gameTimerToggle = makeToggle(gameTab.LeftCol, "Game Timer")


-- ** Save Game to config
BindToggleToConfig(showPowerLevelToggle, "game.showPowerLevel", false)
BindToggleToConfig(showObjectFinderToggle, "game.showObjectFinder", false)
BindToggleToConfig(bypassSafeHouseDoorToggle, "game.bypassSafeHouseDoor", false)
BindToggleToConfig(gameTimerToggle, "game.gameTimer", false)


--------------------------------------------------------------------------

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

local UnloadHandlers = {}
local function RegisterUnload(fn)
    if type(fn) == "function" then
        table.insert(UnloadHandlers, fn)
    end
end

local function RunUnload()
    for _, fn in ipairs(UnloadHandlers) do
        pcall(fn)
    end
    pcall(SaveConfig)
    pcall(function()
        if gui and gui.Parent then gui:Destroy() end
    end)
    -- Final forced cleanup: remove any lingering Tempt visuals across Workspace and GUIs
    pcall(function()
        local Players = game:GetService("Players")
        local CoreGui = game:GetService("CoreGui")
        -- sweep Workspace and all game descendants for any stray Tempt visuals
        for _, obj in ipairs(game:GetDescendants()) do
            if obj and (obj.Name == "Tempt_ScrapHL" or obj.Name == "Tempt_ScrapBB" or obj.Name == "Tempt_SupplyHL" or obj.Name == "Tempt_SupplyBB" or obj.Name == "Tempt_FlareHL" or obj.Name == "Tempt_FlareBB" or obj.Name == "Tempt_TrapsHL" or obj.Name == "Tempt_TrapsBB" or obj.Name == "TemptESP_Highlight") then
                pcall(function() obj:Destroy() end)
            end
        end
        -- also ensure PlayerGui/CoreGui billboards removed
        local lp = Players.LocalPlayer
        if lp then
            local pg = lp:FindFirstChild("PlayerGui")
            if pg then
                for _, obj in ipairs(pg:GetDescendants()) do
                    if obj and (obj.Name == "Tempt_ScrapBB" or obj.Name == "Tempt_SupplyBB" or obj.Name == "Tempt_FlareBB" or obj.Name == "Tempt_TrapsBB") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end
        for _, obj in ipairs(CoreGui:GetDescendants()) do
            if obj and (obj.Name == "Tempt_ScrapBB" or obj.Name == "Tempt_SupplyBB" or obj.Name == "Tempt_FlareBB" or obj.Name == "Tempt_TrapsBB") then
                pcall(function() obj:Destroy() end)
            end
        end
    end)
end

_G.TemptUI.RegisterUnload = RegisterUnload
_G.TemptUI.RunUnload = RunUnload

--------------------------------------------------------------------------

-- ** Code Starts Here ** --

-- ** Visuals Tab Parts ** --

-- ** ESP Logic
-- ** colors (Not a part of GUI palette)
local PLAYER_FILL = Color3.fromRGB(0, 120, 255)
local PLAYER_OUTLINE = Color3.fromRGB(255, 255, 255)
local RAKE_FILL = Color3.fromRGB(255, 50, 50)
local RAKE_OUTLINE = Color3.fromRGB(255, 0, 0)

-- ** players ESP state
local playerData = {}
local playersConns = {}

local function makeHighlight(adornee, fill, outline)
    if not adornee then return nil end
    local h = Instance.new("Highlight")
    h.Name = "TemptESP_Highlight"
    if h.SetAttribute then
        pcall(function() h:SetAttribute("TemptESP", true) end)
    end
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
    -- ** config for auto scale
    local function useAutoScale()
        local api = ToggleAPI[autoScaleESPNameToggle]
        if api and type(api.Get) == "function" then
            return api.Get()
        end
        return GetConfig("settings.autoScaleESPName", false)
    end
    local auto = false
    pcall(function() auto = not not useAutoScale() end)
    label.TextScaled = auto
    if not auto then label.TextSize = 14 end
    label.Parent = bg

    return bg
end

-------------------- Break for Text UI --------------------

-- ** handle auto scale changes
do
    local api = ToggleAPI[autoScaleESPNameToggle]
    local function applyToAll(auto)
        for _, inst in ipairs(Workspace:GetDescendants()) do
            if inst:IsA("BillboardGui") and inst.Name == "ESPName" then
                local label = nil
                for _,c in ipairs(inst:GetChildren()) do if c:IsA("TextLabel") then label = c break end end
                if label then
                    label.TextScaled = not not auto
                    if not auto then label.TextSize = 14 end
                end
            end
        end
    end

    if api then
        local prev = api.OnToggle
        api.OnToggle = function(state)
            if prev then pcall(prev, state) end
            pcall(function() applyToAll(state) end)
        end
        pcall(function() applyToAll(api.Get()) end)
    else
        pcall(function() applyToAll(GetConfig("settings.autoScaleESPName", false)) end)
    end
end

-------------------- Continue from UI --------------------

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

    rake = { highlight = highlight, billboard = billboard, conn = conn, model = model }
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
    local players = {}
    for player,_ in pairs(playerData) do table.insert(players, player) end
    for _, player in ipairs(players) do
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

------------------ Continue ----------------------

-- ** so that ESP stops on unload
if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
    local function cleanupESPInstances()
        pcall(function()
            for _, inst in ipairs(Workspace:GetDescendants()) do
                if inst:IsA("Highlight") then
                    local remove = false
                    if inst.GetAttribute and inst:GetAttribute("TemptESP") == true then
                        remove = true
                    else
                        local ador = inst.Adornee
                        if ador and ador:IsA("Model") then
                            if Players:GetPlayerFromCharacter(ador) then
                                remove = true
                            elseif ador.Name == "Rake" then
                                remove = true
                            end
                        end
                    end
                    if remove then pcall(function() if inst.Parent then inst:Destroy() end end) end
                elseif inst:IsA("BillboardGui") and inst.Name == "ESPName" then
                    pcall(function() if inst.Parent then inst:Destroy() end end)
                end
            end
        end)
    end

    _G.TemptUI.RegisterUnload(function()
        pcall(StopPlayers)
        pcall(StopRake)
        pcall(cleanupESPInstances)
    end)
end

-- ** ESP Logic Ends Here ** --

--------------------------------------------------------------------------

-- ** Remove Fog Logic ** --

do
    local RS = RunService

    local removeEnabled = false
    local hbConn = nil

    local function findFogEnd()
        if not ReplicatedStorage then return nil end
        local props = ReplicatedStorage:FindFirstChild("CurrentLightingProperties")
        if not props then return nil end
        local fog = props:FindFirstChild("FogEnd")
        if fog and fog:IsA("NumberValue") then return fog end
        return nil
    end

    local function setFog(enabled)
        local fog = findFogEnd()
        if fog then
            pcall(function()
                fog.Value = enabled and 9e9 or 75
            end)
        end
        -- ** expose state, maybe i wanna check it elsewhere
        pcall(function() _G.NoFog = not not enabled end)
    end

    local function start()
        if removeEnabled then return end
        removeEnabled = true
        setFog(true)
        if hbConn and hbConn.Disconnect then hbConn:Disconnect() hbConn = nil end
        hbConn = RS.Heartbeat:Connect(function()
            if not removeEnabled then return end
            local fog = findFogEnd()
            if fog then
                pcall(function() fog.Value = 9e9 end)
            end
        end)
    end

    local function stop()
        if not removeEnabled then return end
        removeEnabled = false
        if hbConn and hbConn.Disconnect then hbConn:Disconnect() end
        hbConn = nil
        setFog(false)
    end

    local api = ToggleAPI[removeFogToggle]
    if api then
        local prev = api.OnToggle
        api.OnToggle = function(s)
            if prev then pcall(prev, s) end
            if s then start() else stop() end
        end
        pcall(function() if api.Get() then start() end end)
    end

    -------------------- Break for Unload --------------------
    if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
        _G.TemptUI.RegisterUnload(function()
            pcall(stop)
        end)
    end
end

-- ** Remove Fog Logic Ends Here ** --

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

-- ** Rake Meter Logic ** --

    local RakeMeter = {}
    RakeMeter.Enabled = false
    local rakeGui = nil
    local rakeUpdateConn = nil
    local cachedCharRoot = nil
    local charConn = nil
    local cachedRakePart = nil
    local rakeModelConn = nil
    local workspaceChildConn = nil

    local function createRakeMeterUI()
        if rakeGui and rakeGui.ScreenGui and rakeGui.ScreenGui.Parent then return rakeGui end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "RakeMeterGUI"
        screenGui.IgnoreGuiInset = true
        screenGui.ResetOnSpawn = false

        local root = Instance.new("Frame")
        root.Name = "RakeMeterPanel"
        root.Size = UDim2.new(0, 200, 0, 88)
        root.Position = UDim2.new(1, -12, 0, 12)
        root.AnchorPoint = Vector2.new(1, 0)
        root.BackgroundColor3 = COLORS.panel
        root.BorderSizePixel = 0
        root.Parent = screenGui
        local rootCorner = Instance.new("UICorner") rootCorner.Parent = root

        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 28)
        header.BackgroundColor3 = COLORS.bg
        header.Parent = root
        local headerCorner = Instance.new("UICorner") headerCorner.Parent = header

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -12, 1, 0)
        title.Position = UDim2.new(0, 8, 0, 0)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextColor3 = COLORS.text
        title.Text = "Rake Meter"
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = header

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 20, 0, 20)
        closeBtn.Position = UDim2.new(1, -28, 0, 4)
        closeBtn.AnchorPoint = Vector2.new(0, 0)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.TextColor3 = COLORS.text
        closeBtn.Text = "X"
        closeBtn.Parent = header
        closeBtn.MouseButton1Click:Connect(function()
            RakeMeter.Stop()
            local api = ToggleAPI[rakeMeterToggle]
            if api and type(api.Set) == "function" then pcall(function() api.Set(false) end) end
        end)

        local body = Instance.new("Frame")
        body.Name = "Body"
        body.Size = UDim2.new(1, 0, 1, -28)
        body.Position = UDim2.new(0, 0, 0, 28)
        body.BackgroundTransparency = 1
        body.Parent = root

        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "Distance"
        distanceLabel.Size = UDim2.new(1, -12, 0, 32)
        distanceLabel.Position = UDim2.new(0, 8, 0, 8)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Font = Enum.Font.GothamBold
        distanceLabel.TextSize = 18
        distanceLabel.TextColor3 = COLORS.text
        distanceLabel.Text = "Distance: -- m"
        distanceLabel.Parent = body

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 18)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = COLORS.text
        nameLabel.Text = "" 
        nameLabel.TextStrokeTransparency = 0.7
        nameLabel.Parent = root

        local stateLabel = Instance.new("TextLabel")
        stateLabel.Size = UDim2.new(1, -12, 0, 18)
        stateLabel.Position = UDim2.new(0, 6, 0, 40)
        stateLabel.BackgroundTransparency = 1
        stateLabel.Font = Enum.Font.GothamBold
        stateLabel.TextSize = 14
        stateLabel.TextColor3 = COLORS.text
        stateLabel.Text = "N/A"
        stateLabel.TextWrapped = true
        stateLabel.TextXAlignment = Enum.TextXAlignment.Center
        stateLabel.Parent = body

    --------------- Break from UI ----------------

        local dragging = false
        local dragStart, startPos
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = root.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
                local delta = input.Position - dragStart
                local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                root.Position = newPos
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        screenGui.Parent = player:WaitForChild("PlayerGui")
        rakeGui = { ScreenGui = screenGui, Root = root, Distance = distanceLabel, State = stateLabel }
        return rakeGui
    end

    -- ** distance stuff
    local function distanceState(dist)
        if dist >= 500 then return "Very Safe"
        elseif dist >= 200 then return "Safe"
        elseif dist >= 100 then return "Far"
        elseif dist >= 50 then return "Close"
        else return "Very Close" end
    end

    local function updateCachedRakePart()
        if cachedRakePart and cachedRakePart.Parent then return end
        local rakeModel = Workspace:FindFirstChild("Rake")
        if rakeModel and rakeModel:IsA("Model") then
            cachedRakePart = rakeModel:FindFirstChild("HumanoidRootPart") or rakeModel:FindFirstChild("HumanoidRoot")
            if rakeModel then
                if rakeModelConn then rakeModelConn:Disconnect() rakeModelConn = nil end
                rakeModelConn = rakeModel.AncestryChanged:Connect(function(_, parent)
                    if not parent then cachedRakePart = nil end
                end)
            end
        else
            cachedRakePart = nil
        end
    end

    -- ** Tracking stuff
    local function startTracking()
        if rakeUpdateConn then return end
        if charConn then charConn:Disconnect() charConn = nil end
        local char = player.Character
        if not char then
            char = player.CharacterAdded:Wait()
        end
        cachedCharRoot = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("HumanoidRoot")
        if not cachedCharRoot then
            cachedCharRoot = char:WaitForChild("HumanoidRootPart", 2) or char:WaitForChild("HumanoidRoot", 2)
        end
        charConn = player.CharacterAdded:Connect(function(newChar)
            cachedCharRoot = newChar:FindFirstChild("HumanoidRootPart") or newChar:FindFirstChild("HumanoidRoot")
            if not cachedCharRoot then cachedCharRoot = newChar:WaitForChild("HumanoidRootPart", 2) or newChar:WaitForChild("HumanoidRoot", 2) end
        end)

        updateCachedRakePart()
        if not workspaceChildConn then
            workspaceChildConn = Workspace.ChildAdded:Connect(function(child)
                if child and child.Name == "Rake" and child:IsA("Model") then
                    updateCachedRakePart()
                end
            end)
        end

        local lastDistanceText, lastStateText, lastStateColor
        rakeUpdateConn = RunService.RenderStepped:Connect(function()
            if not rakeGui then return end
            updateCachedRakePart()
            local rakePart = cachedRakePart
            if rakePart and rakePart.Parent then
                local refPos = (cachedCharRoot and cachedCharRoot.Position) or (player.Character and player.Character:GetModelCFrame().p) or Vector3.new(0,0,0)
                local dist = (rakePart.Position - refPos).Magnitude
                local meters = math.floor(dist)
                local distText = string.format("Distance: %d m", meters)
                local stateText = distanceState(dist)
                local stateColor = COLORS.accent
                if lastDistanceText ~= distText then rakeGui.Distance.Text = distText; lastDistanceText = distText end
                if lastStateText ~= stateText then rakeGui.State.Text = stateText; lastStateText = stateText end
                if lastStateColor ~= stateColor then rakeGui.State.TextColor3 = stateColor; lastStateColor = stateColor end
            else
                if lastDistanceText ~= "Rake: Inactive" then rakeGui.Distance.Text = "Rake: Inactive"; lastDistanceText = "Rake: Inactive" end
                if lastStateText ~= "--" then rakeGui.State.Text = "--"; lastStateText = "--" end
                if lastStateColor ~= COLORS.text then rakeGui.State.TextColor3 = COLORS.text; lastStateColor = COLORS.text end
            end
        end)
    end

    local function stopTracking()
        if rakeUpdateConn then
            rakeUpdateConn:Disconnect()
            rakeUpdateConn = nil
        end
        if rakeGui and rakeGui.ScreenGui then
            pcall(function() if rakeGui.ScreenGui.Parent then rakeGui.ScreenGui:Destroy() end end)
        end
        rakeGui = nil
        if charConn then charConn:Disconnect() charConn = nil end
        if rakeModelConn then rakeModelConn:Disconnect() rakeModelConn = nil end
        if workspaceChildConn then workspaceChildConn:Disconnect() workspaceChildConn = nil end
        cachedCharRoot = nil
        cachedRakePart = nil
    end

    function RakeMeter.Start()
        if RakeMeter.Enabled then return end
        RakeMeter.Enabled = true
        createRakeMeterUI()
        startTracking()
    end

    function RakeMeter.Stop()
        if not RakeMeter.Enabled then return end
        RakeMeter.Enabled = false
        stopTracking()
    end

    function RakeMeter.Toggle()
        if RakeMeter.Enabled then RakeMeter.Stop() else RakeMeter.Start() end
    end

    local rmApi = ToggleAPI[rakeMeterToggle]
    if rmApi then
        local prev = rmApi.OnToggle
        rmApi.OnToggle = function(state)
            if prev then pcall(prev, state) end
            if state then pcall(function() RakeMeter.Start() end) else pcall(function() RakeMeter.Stop() end) end
        end
        pcall(function() rmApi.Set(rmApi.Get()) end)
    end

    --------------------- Break for Unload ----------------------

    -- ** unload handler

    if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
        _G.TemptUI.RegisterUnload(function()
            pcall(function() RakeMeter.Stop() end)
        end)
    end

-- ** Rake Meter Logic Ends Here ** --


--------------------------------------------------------------------------

-- ** Full Bright Logic ** --

do
    local fbConn = nil
    local saved = {}
    local charConn = nil

    local function applyFullBrightLocal()
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
    end

    local function startFullBright()
        if fbConn then return end
        -- ** save originals once
        if saved.Ambient == nil then
            saved.Ambient = Lighting.Ambient
            saved.Bottom = Lighting.ColorShift_Bottom
            saved.Top = Lighting.ColorShift_Top
        end
        applyFullBrightLocal()
        fbConn = Lighting.LightingChanged:Connect(applyFullBrightLocal)
        -- ** apply again on character respawn
        if charConn and charConn.Disconnect then charConn:Disconnect() charConn = nil end
        charConn = player.CharacterAdded:Connect(function()
            pcall(applyFullBrightLocal)
        end)
    end

    local function stopFullBright()
        if fbConn then fbConn:Disconnect() fbConn = nil end
        if charConn then charConn:Disconnect() charConn = nil end
        if saved.Ambient ~= nil then
            Lighting.Ambient = saved.Ambient
            Lighting.ColorShift_Bottom = saved.Bottom
            Lighting.ColorShift_Top = saved.Top
            saved = {}
        end
    end

    local fbApi = ToggleAPI[fullBrightToggle]
    if fbApi then
        local prev = fbApi.OnToggle
        fbApi.OnToggle = function(state)
            if prev then pcall(prev, state) end
            if state then pcall(startFullBright) else pcall(stopFullBright) end
        end
        pcall(function() fbApi.Set(fbApi.Get()) end)
    end

---------------------- Break for Unload ----------------------

    -- ** unload handler

    if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
        _G.TemptUI.RegisterUnload(function()
            pcall(stopFullBright)
        end)
    end
end

-- ** Full Bright Logic Ends Here ** --

--------------------------------------------------------------------------

-- ** Rake Health Logic ** --

do
    local enabled = false
    local healthGui = nil
    local renderConn = nil
    local rakeModelConn = nil
    local modelChildConn = nil
    local humanoidConn = nil
    local workspaceChildConn = nil
    local workspaceChildRemConn = nil
    local rakeHeartbeatConn = nil

    -- ** rake presence flags
    local _rakePresent = false
    local function isRakeActive() return _rakePresent end
    local function isRakeInactive() return not _rakePresent end

    -- ** colors (not part of GUI palette)
    local HEALTH_TEXT = COLORS.text
    local HEALTH_BG = COLORS.panelDark
    local HEALTH_FILL = RAKE_FILL
    local HEALTH_OUTLINE = RAKE_OUTLINE
    local HEALTH_FULL_COLOR = Color3.fromRGB(160, 0, 0)

    local FADE_START = 180
    local FADE_END = 300  
    local _lastHP = nil
    local _lastMaxHP = nil
    local _lastDist = nil

    local function findRakePart(model)
        if not model or not model:IsA("Model") then return nil end
        local part = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        if part and part:IsA("BasePart") then return part end
        for _,v in ipairs(model:GetDescendants()) do
            if v:IsA("BasePart") then return v end
        end
        return nil
    end

    local function createHealthUIForRake(rakeModel)
        if not rakeModel then return end
        local part = findRakePart(rakeModel)
        if not part then return end

        -- ** clean dupes
        if healthGui and healthGui.Root and healthGui.Root.Parent then
            pcall(function() healthGui.Root:Destroy() end)
            healthGui = nil
        end

        -------------------- Break for UI --------------------

        local bb = Instance.new("BillboardGui")
        bb.Name = "RakeHealthDisplay"
        bb.Adornee = part
        bb.Size = UDim2.new(0, 150, 0, 48) 
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = false
        bb.ResetOnSpawn = false
        bb.Parent = part

        local root = Instance.new("Frame")
        root.Size = UDim2.new(1, 0, 1, 0)
        root.BackgroundTransparency = 1
        root.Parent = bb

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 18)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = HEALTH_TEXT
        nameLabel.Text = ""
        nameLabel.TextStrokeTransparency = 0.7
        nameLabel.Parent = root

        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(1, 0, 0, 12)
        barBg.Position = UDim2.new(0, 0, 0, 22)
        barBg.BackgroundColor3 = HEALTH_BG
        barBg.BorderSizePixel = 0
        barBg.Parent = root

        local barFill = Instance.new("Frame")
        barFill.Name = "Fill"
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.Position = UDim2.new(0, 0, 0, 0)
        barFill.BackgroundColor3 = HEALTH_FILL
        barFill.BorderSizePixel = 0
        barFill.Parent = barBg

        local barOutline = Instance.new("Frame")
        barOutline.Size = UDim2.new(1, 0, 1, 0)
        barOutline.Position = UDim2.new(0, 0, 0, 0)
        barOutline.BackgroundTransparency = 1
        barOutline.BorderSizePixel = 1
        barOutline.BorderColor3 = HEALTH_OUTLINE
        barOutline.Parent = barBg

        healthGui = { Root = bb, Name = nameLabel, BarBg = barBg, BarFill = barFill, ParentPart = part, RakeModel = rakeModel }

        -------------------- Continue from UI --------------------

        local function updateHealthValues(h, maxH)
            maxH = maxH or 100
            local hp = math.floor(h or 0)
            local m = math.floor(maxH)
            if _lastHP == hp and _lastMaxHP == m then return end
            _lastHP = hp
            _lastMaxHP = m
            local pct = 0
            if m > 0 then pct = math.clamp(hp / m, 0, 1) end
            if healthGui and healthGui.BarFill then
                healthGui.BarFill.Size = UDim2.new(pct, 0, 1, 0)
                if hp >= m then
                    healthGui.BarFill.BackgroundColor3 = HEALTH_FULL_COLOR
                else
                    healthGui.BarFill.BackgroundColor3 = HEALTH_FILL
                end
                if healthGui.Name then healthGui.Name.Text = string.format("HP: %d / %d", hp, m) end
            end
        end

        local humanoid = rakeModel:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if humanoidConn and humanoidConn.Disconnect then humanoidConn:Disconnect() end
            humanoidConn = humanoid.HealthChanged:Connect(function(h)
                updateHealthValues(h, humanoid.MaxHealth)
            end)
            pcall(function() updateHealthValues(humanoid.Health, humanoid.MaxHealth) end)
        else
            local monster = rakeModel:FindFirstChild("Monster")
            if monster then
                if humanoidConn and humanoidConn.Disconnect then humanoidConn:Disconnect() end
                if monster:IsA("NumberValue") or monster:IsA("IntValue") then
                    humanoidConn = monster.Changed:Connect(function(v)
                        local maxH = 100
                        local parentMax = monster.Parent and monster.Parent:FindFirstChild("MaxHealth")
                        if parentMax and (parentMax:IsA("NumberValue") or parentMax:IsA("IntValue")) then
                            maxH = parentMax.Value
                        end
                        updateHealthValues(v, maxH)
                    end)
                    pcall(function()
                        local maxH = 100
                        local parentMax = monster.Parent and monster.Parent:FindFirstChild("MaxHealth")
                        if parentMax and (parentMax:IsA("NumberValue") or parentMax:IsA("IntValue")) then
                            maxH = parentMax.Value
                        end
                        updateHealthValues(monster.Value, maxH)
                    end)
                else
                    if monster.GetPropertyChangedSignal then
                        humanoidConn = monster:GetPropertyChangedSignal("Health"):Connect(function()
                            local ok, h = pcall(function() return monster.Health end)
                            local ok2, maxH = pcall(function() return monster.MaxHealth end)
                            if not ok2 or not maxH then
                                maxH = 100
                            end
                            updateHealthValues(ok and h or 0, maxH)
                        end)
                        pcall(function() local ok, h = pcall(function() return monster.Health end); local ok2, maxH = pcall(function() return monster.MaxHealth end); if not ok2 or not maxH then maxH = 100 end; updateHealthValues(ok and h or 0, maxH) end)
                    else
                        local healthChild = monster:FindFirstChild("Health")
                        if healthChild and (healthChild:IsA("NumberValue") or healthChild:IsA("IntValue")) then
                            humanoidConn = healthChild.Changed:Connect(function(v)
                                local maxH = 100
                                local mMax = monster:FindFirstChild("MaxHealth")
                                if mMax and (mMax:IsA("NumberValue") or mMax:IsA("IntValue")) then maxH = mMax.Value end
                                updateHealthValues(v, maxH)
                            end)
                            pcall(function() local mMax = monster:FindFirstChild("MaxHealth"); local maxH = (mMax and (mMax.Value)) or 100; updateHealthValues(healthChild.Value, maxH) end)
                        end
                    end
                end
            end
        end
    end

    local function destroyHealthUI()
        if renderConn and renderConn.Disconnect then renderConn:Disconnect() renderConn = nil end
        if humanoidConn and humanoidConn.Disconnect then humanoidConn:Disconnect() humanoidConn = nil end
        if modelChildConn and modelChildConn.Disconnect then modelChildConn:Disconnect() modelChildConn = nil end
        if rakeModelConn and rakeModelConn.Disconnect then rakeModelConn:Disconnect() rakeModelConn = nil end
        if workspaceChildConn and workspaceChildConn.Disconnect then workspaceChildConn:Disconnect() workspaceChildConn = nil end
        if workspaceChildRemConn and workspaceChildRemConn.Disconnect then workspaceChildRemConn:Disconnect() workspaceChildRemConn = nil end
        if rakeHeartbeatConn and rakeHeartbeatConn.Disconnect then rakeHeartbeatConn:Disconnect() rakeHeartbeatConn = nil end
        _rakePresent = false
        if healthGui and healthGui.Root and healthGui.Root.Parent then
            pcall(function() healthGui.Root:Destroy() end)
        end
        healthGui = nil
    end

    local function updateFade()
        if not healthGui or not healthGui.ParentPart then return end
        local char = player.Character
        local refPos = nil
        if char then
            local rootp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("HumanoidRoot")
            if rootp then refPos = rootp.Position end
        end
        if not refPos then
            local cam = workspace.CurrentCamera
            if cam then refPos = cam:GetRenderCFrame().p end
        end
        if not refPos then return end
        local dist = (healthGui.ParentPart.Position - refPos).Magnitude
        local alpha = 0
        if dist <= FADE_START then alpha = 0
        elseif dist >= FADE_END then alpha = 1
        else alpha = (dist - FADE_START) / (FADE_END - FADE_START) end

        local textTrans = math.clamp(alpha, 0, 1)
        local bgTrans = math.clamp(0.15 + alpha * 0.85, 0, 1)

        if healthGui.Name then healthGui.Name.TextTransparency = textTrans end
        if healthGui.BarBg then healthGui.BarBg.BackgroundTransparency = bgTrans end
        if healthGui.BarFill then healthGui.BarFill.BackgroundTransparency = bgTrans end
    end

    local CLUSTER_RADIUS = 6
    local CLUSTER_THRESHOLD = 4 
    local function detectClusters()
        local scraps = {}
        for model,_ in pairs(scrapModels) do
            if model and model.Parent then
                local p = findDisplayPart(model)
                if p and p.Parent then table.insert(scraps, { model = model, pos = p.Position }) end
            end
        end

        local visited = {}
        local newClusters = {}
        for i, s in ipairs(scraps) do
            if not visited[i] then
                local stack = {i}
                visited[i] = true
                local members = { s }
                local idx = 1
                while idx <= #stack do
                    local cur = stack[idx]
                    local curPos = scraps[cur].pos
                    for j = 1, #scraps do
                        if not visited[j] then
                            if (scraps[j].pos - curPos).Magnitude <= CLUSTER_RADIUS then
                                visited[j] = true
                                table.insert(stack, j)
                                table.insert(members, scraps[j])
                            end
                        end
                    end
                    idx = idx + 1
                end
                if #members >= CLUSTER_THRESHOLD then
                    table.insert(newClusters, members)
                end
            end
        end

        for _, members in ipairs(newClusters) do
            local already = false
            for id,c in pairs(supplyClusters) do
                for _, m in ipairs(c.members) do
                    for _, mm in ipairs(members) do
                        if m == mm.model then already = true break end
                    end
                    if already then break end
                end
                if already then break end
            end
            if not already then
                local sum = Vector3.new(0,0,0)
                for _, m in ipairs(members) do sum = sum + m.pos end
                local centroid = sum / #members
                local anchor = Instance.new("Part")
                anchor.Name = "Tempt_SupplyAnchor"
                anchor.Size = Vector3.new(1,1,1)
                anchor.Transparency = 1
                anchor.Anchored = true
                anchor.CanCollide = false
                anchor.Position = centroid
                anchor.Parent = Workspace

                local clusterId = tostring(math.random(1,1e9))
                local memberModels = {}
                for _, m in ipairs(members) do
                    memberModels[#memberModels+1] = m.model
                    suppressedScraps[m.model] = clusterId
                    if entries[m.model] then destroyEntry(m.model) end
                end
                supplyClusters[clusterId] = { anchor = anchor, members = memberModels }
                createEntry(anchor, "Supply Drop", Color3.fromRGB(34,139,34), true)
                supplyClusters[clusterId].entry = anchor
            end
        end

        for id, c in pairs(supplyClusters) do
            local ok = true
            for _, m in ipairs(c.members) do if not m or not m.Parent then ok = false break end end
            if not ok then
                if c.entry then destroyEntry(c.entry) end
                if c.anchor and c.anchor.Parent then pcall(function() c.anchor:Destroy() end) end
                for _, m in ipairs(c.members) do
                    suppressedScraps[m] = nil
                    if m and m.Parent and not entries[m] then
                        local lvl = scrapLevelFromModel(m) or ""
                        local sub = lvl and tonumber(lvl) and ("Lv " .. tostring(lvl)) or nil
                        createEntry(m, "Scrap", Color3.fromRGB(150,75,0), true, sub)
                    end
                end
                supplyClusters[id] = nil
            end
        end
    end

    local function tryAttachToExistingRake()
        local rakeModel = Workspace:FindFirstChild("Rake")
        if rakeModel and rakeModel:IsA("Model") then
            _rakePresent = true
            createHealthUIForRake(rakeModel)
            if rakeModelConn and rakeModelConn.Disconnect then rakeModelConn:Disconnect() end
            rakeModelConn = rakeModel.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    _rakePresent = false
                    destroyHealthUI()
                end
            end)
        else
            _rakePresent = false
        end
    end

    local function start()
        if enabled then return end
        enabled = true
        tryAttachToExistingRake()
        if not workspaceChildConn then
            workspaceChildConn = Workspace.ChildAdded:Connect(function(child)
                if child and child:IsA("Model") and child.Name == "Rake" then
                    _rakePresent = true
                    pcall(function() createHealthUIForRake(child) end)
                end
            end)
        end
        if not workspaceChildRemConn then
            workspaceChildRemConn = Workspace.ChildRemoved:Connect(function(child)
                if child and child:IsA("Model") and child.Name == "Rake" then
                    _rakePresent = false
                    destroyHealthUI()
                end
            end)
        end

        if not renderConn then
            renderConn = RunService.RenderStepped:Connect(function()
                pcall(function()
                    if healthGui and healthGui.RakeModel and (not healthGui.RakeModel.Parent) then
                        _rakePresent = false
                        destroyHealthUI()
                        return
                    end
                    if healthGui and healthGui.ParentPart then
                        local cam = workspace.CurrentCamera
                        local refPos = nil
                        local char = player.Character
                        if char then
                            local rootp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("HumanoidRoot")
                            if rootp then refPos = rootp.Position end
                        end
                        if not refPos and cam then refPos = cam:GetRenderCFrame().p end
                        if refPos and healthGui.ParentPart and healthGui.ParentPart.Position then
                            local dist = (healthGui.ParentPart.Position - refPos).Magnitude
                            if _lastDist == nil or math.abs(dist - _lastDist) >= 0.5 then
                                _lastDist = dist
                                updateFade()
                            end
                        end
                    else
                        updateFade()
                    end
                end)
            end)
        end

        if not rakeHeartbeatConn then
            rakeHeartbeatConn = RunService.Heartbeat:Connect(function()
                if not enabled then return end
                if not isRakeActive() then return end
                local r = Workspace:FindFirstChild("Rake")
                if not r then _rakePresent = false return end
                local monster = r:FindFirstChild("Monster")
                if monster then
                    local ok, h = pcall(function()
                        if monster:IsA("NumberValue") or monster:IsA("IntValue") then return monster.Value end
                        local hv = monster:FindFirstChild("Health")
                        if hv and (hv:IsA("NumberValue") or hv:IsA("IntValue")) then return hv.Value end
                        if monster.GetAttribute and monster:GetAttribute("Health") then return monster:GetAttribute("Health") end
                        if monster.GetPropertyChangedSignal then
                            local ok2, val = pcall(function() return monster.Health end)
                            if ok2 then return val end
                        end
                        return nil
                    end)
                    if ok and h then
                        local maxH = 100
                        local parentMax = monster.Parent and monster.Parent:FindFirstChild("MaxHealth")
                        if parentMax and (parentMax:IsA("NumberValue") or parentMax:IsA("IntValue")) then maxH = parentMax.Value end
                        pcall(function() updateHealthValues(h, maxH) end)
                    end
                end
            end)
        end
    end

    local function stop()
        if not enabled then return end
        enabled = false
        destroyHealthUI()
    end

    -- ** wrap up to toggle
    local api = ToggleAPI[rakeHealthToggle]
    if api then
        local prev = api.OnToggle
        api.OnToggle = function(s)
            if prev then pcall(prev, s) end
            if s then pcall(start) else pcall(stop) end
        end
        pcall(function() api.Set(api.Get()) end)
    end

    --------------------- Break for Unload ----------------------

    -- ** unload handler
    if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
        _G.TemptUI.RegisterUnload(function()
            pcall(stop)
        end)
    end
end


-- ** Rake Health Logic Ends Here ** --

--------------------------------------------------------------------------

-- ** Player Tab Parts ** --

-- ** Player Speed Logic ** --

do
    local enabled = false
    local charAddedConn
    local propConn
    local heartbeatConn
    local renderConn
    local originalSpeed = nil
    local activeHumanoid 

    local stateConn
    local function stopEnforce()
        if propConn and propConn.Disconnect then pcall(function() propConn:Disconnect() end) end
        propConn = nil
        if stateConn and stateConn.Disconnect then pcall(function() stateConn:Disconnect() end) end
        stateConn = nil
        if heartbeatConn and heartbeatConn.Disconnect then pcall(function() heartbeatConn:Disconnect() end) end
        heartbeatConn = nil
        if renderConn and renderConn.Disconnect then pcall(function() renderConn:Disconnect() end) end
        renderConn = nil
        activeHumanoid = nil
    end

    local function enforceHumanoid(hum)
        if not hum or not hum.Parent or not hum:IsA("Humanoid") then return end
        stopEnforce()
        activeHumanoid = hum
        if originalSpeed == nil then pcall(function() originalSpeed = hum.WalkSpeed end) end

        local function getDesired()
            return GetConfig("player.speedValue", 16) or 16
        end

        local playerSpeed = getDesired()
        pcall(function() if hum:GetState() ~= Enum.HumanoidStateType.Climbing then hum.WalkSpeed = playerSpeed end end)

        propConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if not hum or not hum.Parent then stopEnforce() return end
            local curDesired = getDesired()
            if hum:GetState() == Enum.HumanoidStateType.Climbing then
                local hrp = hum.Parent and hum.Parent:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local moveDir = hum.MoveDirection or Vector3.new(0,0,0)
                    if moveDir.Magnitude > 0.001 then
                        local desiredVel = moveDir.Unit * curDesired
                        pcall(function()
                            local av = hrp.AssemblyLinearVelocity
                            hrp.AssemblyLinearVelocity = Vector3.new(desiredVel.X, av and av.Y or 0, desiredVel.Z)
                        end)
                    end
                end
            else
                if hum.WalkSpeed ~= curDesired then
                    pcall(function() hum.WalkSpeed = curDesired end)
                end
            end
        end)

        stateConn = hum.StateChanged:Connect(function(oldState, newState)
            if not hum or not hum.Parent then return end
            if newState == Enum.HumanoidStateType.Climbing then
                return
            else
                local d = getDesired()
                pcall(function() hum.WalkSpeed = d end)
            end
        end)

        heartbeatConn = RunService.Heartbeat:Connect(function(dt)
            if not hum or not hum.Parent then stopEnforce() return end
            local curDesired = getDesired()
            if hum:GetState() ~= Enum.HumanoidStateType.Climbing then
                if hum.WalkSpeed ~= curDesired then pcall(function() hum.WalkSpeed = curDesired end) end
            end

            local hrp = hum.Parent and hum.Parent:FindFirstChild("HumanoidRootPart")
            if hrp then
                local moveDir = hum.MoveDirection or Vector3.new(0,0,0)
                if moveDir.Magnitude > 0.001 then
                    local desiredVel = moveDir.Unit * curDesired
                    pcall(function()
                        local av = hrp.AssemblyLinearVelocity
                        hrp.AssemblyLinearVelocity = Vector3.new(desiredVel.X, av and av.Y or 0, desiredVel.Z)
                    end)
                    if hum:GetState() ~= Enum.HumanoidStateType.Climbing then
                        local predicted = hrp.Position + desiredVel * math.clamp(dt, 0, 0.1)
                        local rollbackDist = (hrp.Position - predicted).Magnitude
                        if rollbackDist > 3 then
                            pcall(function()
                                hrp.CFrame = CFrame.new(predicted, predicted + hrp.CFrame.LookVector)
                            end)
                        end
                    end
                else
                    pcall(function()
                        local av = hrp.AssemblyLinearVelocity
                        if av then hrp.AssemblyLinearVelocity = Vector3.new(0, av.Y, 0) end
                    end)
                end
            end
        end)

        renderConn = RunService.RenderStepped:Connect(function(dt)
            if not hum or not hum.Parent then stopEnforce() return end
            if hum:GetState() == Enum.HumanoidStateType.Climbing then return end
            local hrp = hum.Parent and hum.Parent:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local moveDir = hum.MoveDirection or Vector3.new(0,0,0)
            local curDesired = getDesired()
            if moveDir.Magnitude > 0.001 then
                local desiredVel = moveDir.Unit * curDesired
                pcall(function()
                    local av = hrp.AssemblyLinearVelocity
                    hrp.AssemblyLinearVelocity = Vector3.new(desiredVel.X, av and av.Y or 0, desiredVel.Z)
                end)
                local step = math.clamp(dt, 0, 0.06)
                local predicted = hrp.Position + desiredVel * step
                pcall(function()
                    hrp.CFrame = CFrame.new(predicted, predicted + hrp.CFrame.LookVector)
                end)
            else
                pcall(function()
                    local av = hrp.AssemblyLinearVelocity
                    if av then hrp.AssemblyLinearVelocity = Vector3.new(0, av.Y, 0) end
                end)
            end
        end)
    end

    local function onCharacterAdded(char)
        local hum = char and (char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 2))
        if hum then
            local api = ToggleAPI[playerSpeedToggle]
            if api and type(api.Get) == "function" and api.Get() then
                enforceHumanoid(hum)
            end
        end
    end

    local function start()
        if enabled then return end
        enabled = true
        local ch = player and player.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum then enforceHumanoid(hum) end
        end
        charAddedConn = player.CharacterAdded:Connect(onCharacterAdded)
    end

    local function stop()
        if not enabled then return end
        enabled = false
        if charAddedConn and charAddedConn.Disconnect then charAddedConn:Disconnect() end
        charAddedConn = nil
        stopEnforce()
        local ch = player and player.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum and originalSpeed then pcall(function() hum.WalkSpeed = originalSpeed end) end
        end
        originalSpeed = nil
    end

    local api = ToggleAPI[playerSpeedToggle]
    if api then
        local prev = api.OnToggle
        api.OnToggle = function(s)
            if prev then pcall(prev, s) end
            if s then start() else stop() end
        end
        pcall(function() if api.Get() then start() end end)
    end

    -------------------- Break for Unload --------------------

    if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
        _G.TemptUI.RegisterUnload(function()
            pcall(stop)
        end)
    end
end

-- ** Player Speed Logic Ends Here ** --

--------------------------------------------------------------------------


-- ** Remove Fall Damage Logic ** --


do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local childConn = nil
    local enabled = false

    local function removeFD()
        pcall(function()
            local ev = ReplicatedStorage:FindFirstChild("FD_Event")
            if ev and ev.Destroy then
                ev:Destroy()
            end
        end)
    end

    local function onChildAdded(child)
        if not child then return end
        if child.Name == "FD_Event" then
            pcall(function() child:Destroy() end)
        end
    end

    local function start()
        if enabled then return end
        enabled = true
        removeFD()
        if childConn and childConn.Disconnect then childConn:Disconnect() childConn = nil end
        childConn = ReplicatedStorage.ChildAdded:Connect(onChildAdded)
    end

    local function stop()
        if not enabled then return end
        enabled = false
        if childConn and childConn.Disconnect then childConn:Disconnect() end
        childConn = nil
    end

    local api = ToggleAPI[removeFallDamageToggle]
    if api then
        local prev = api.OnToggle
        api.OnToggle = function(s)
            if prev then pcall(prev, s) end
            if s then start() else stop() end
        end
        pcall(function() if api.Get() then start() end end)
    end

    -------------------- Break for Unload --------------------
    if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
        _G.TemptUI.RegisterUnload(function() pcall(stop) end)
    end
end



--------------------------------------------------------------------------

-- ** Settings Tab Parts ** --

-- ** Close/Open Keybind Logic ** --
do
    -- ** saved keybind or default which is Insert
    local kbApi = KeybindAPI[closeBind]
    local closeKey = nil
    if kbApi and type(kbApi.Get) == "function" then closeKey = kbApi.Get() end
    if not closeKey and kbApi and type(kbApi.Set) == "function" then
        closeKey = Enum.KeyCode.Insert
        kbApi.Set(closeKey)
    end

    -- ** listen for keybind changes

    if kbApi then
        kbApi.OnBind = function(k)
            if typeof(k) == "EnumItem" then
                closeKey = k
                pcall(function() SetConfig("settings.closeOpenKey", k.Name) end)
            end
        end
    end

    -------------------- Break for Mouse Unlocker --------------------
    
    local MOUSE_STEP = "Tempt_MouseUnlocker"
    local mouseUnlocked = false
    local savedMouseBehavior, savedMousePos
    local savedOffset, savedLook

    local function getRootPart()
        local c = player and player.Character
        return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("HumanoidRoot"))
    end

    local function getCamera()
        local cam = Workspace.CurrentCamera
        if cam then return cam end
        Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
        return Workspace.CurrentCamera
    end

    local function safeSetMouseLocation(x, y)
        pcall(function() UserInputService:SetMouseLocation(x, y) end)
    end

    local function safeSetMouseBehavior(b)
        pcall(function() UserInputService.MouseBehavior = b end)
    end

    local function startMouseUnlock()
        if mouseUnlocked then return end
        local cam = getCamera()
        local root = getRootPart()

        savedMouseBehavior = UserInputService.MouseBehavior
        local ok, pos = pcall(function() return UserInputService:GetMouseLocation() end)
        if ok then savedMousePos = pos end

        if root and cam then
            local ok2, cf = pcall(function() return cam.CFrame end)
            if ok2 and cf then
                savedOffset = cf.Position - root.Position
                savedLook = cf.LookVector
            else
                savedOffset = Vector3.new(0, 2, 8)
                savedLook = cf and cf.LookVector or Vector3.new(0, 0, -1)
            end
        else
            savedOffset = Vector3.new(0, 2, 8)
            savedLook = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
        end

        pcall(function() RunService:UnbindFromRenderStep(MOUSE_STEP) end)
        RunService:BindToRenderStep(MOUSE_STEP, Enum.RenderPriority.First.Value, function()
            local camNow = Workspace.CurrentCamera
            if not camNow then return end
            pcall(function()
                safeSetMouseBehavior(Enum.MouseBehavior.Default)
                camNow.CameraType = Enum.CameraType.Scriptable

                local rootNow = getRootPart()
                if rootNow and savedOffset and savedLook then
                    local newPos = rootNow.Position + savedOffset
                    camNow.CFrame = CFrame.new(newPos, newPos + savedLook)
                end
            end)
        end)

        mouseUnlocked = true
    end

    local function stopMouseUnlock()
        if not mouseUnlocked then return end
        pcall(function() RunService:UnbindFromRenderStep(MOUSE_STEP) end)

        local cam = Workspace.CurrentCamera
        if cam then pcall(function() cam.CameraType = Enum.CameraType.Custom end) end

        if savedMouseBehavior then
            pcall(function() UserInputService.MouseBehavior = savedMouseBehavior end)
        else
            pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter end)
        end

        if savedMousePos and typeof(savedMousePos) == "Vector2" then
            pcall(function() safeSetMouseLocation(savedMousePos.X, savedMousePos.Y) end)
        end

        savedOffset = nil
        savedLook = nil
        mouseUnlocked = false
    end

    if type(_G) == "table" and _G.TemptUI and type(_G.TemptUI) == "table" then
        pcall(function()
            _G.TemptUI.StartMouseUnlock = startMouseUnlock
            _G.TemptUI.StopMouseUnlock = stopMouseUnlock
        end)
    end

    -------------------- Continue from Mouse Unlocker --------------------

    -- ** listen for keypresses

    local closeConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if not closeKey then return end
        if input.KeyCode == closeKey then
            if gui and gui.Parent then
                gui.Enabled = not gui.Enabled
                if gui.Enabled then pcall(startMouseUnlock) else pcall(stopMouseUnlock) end
            end
        end
    end)

    -- ** not necessary but clean up so shennanigans don't happen

    if type(_G) == "table" and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
        _G.TemptUI.RegisterUnload(function()
            if closeConn and closeConn.Disconnect then pcall(function() closeConn:Disconnect() end) end
            if guiEnabledConn and guiEnabledConn.Disconnect then pcall(function() guiEnabledConn:Disconnect() end) end
            pcall(stopMouseUnlock)
        end)
    end
end

-- ** Close/Open Keybind Logic Ends Here ** --

--------------------------------------------------------------------------


-- ** Show GUI on Load Logic ** --
do
    local api = ToggleAPI[showGUIOnLoadToggle]
    local initial = nil
    if api and type(api.Get) == "function" then
        initial = api.Get()
    else
        initial = GetConfig("settings.showGUIOnLoad", true)
    end

    if gui then
        gui.Enabled = (initial == true)
    end

    if api then
        local prev = api.OnToggle
        api.OnToggle = function(state)
            if prev then pcall(prev, state) end
            if gui then gui.Enabled = (state == true) end
        end
    end
end

-- ** No need for cleanup

-- ** Show GUI on Load Logic Ends Here ** --

--------------------------------------------------------------------------

-- ** Auto-hide when Rake is close Logic ** --
do
    local api = ToggleAPI[autoHideWhenRakeCloseToggle]
    local enabled = false
    local renderConn = nil
    local _wasHiddenByAuto = false
    local _savedGuiEnabled = nil
    local THRESHOLD = 15

    local function getRakePart()
        local rm = Workspace:FindFirstChild("Rake")
        if rm and rm:IsA("Model") then
            return rm:FindFirstChild("HumanoidRootPart") or rm:FindFirstChild("HumanoidRoot")
        end
        return nil
    end

    local function getRefPosition()
        local char = player and player.Character
        if char then
            local rootp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("HumanoidRoot")
            if rootp then return rootp.Position end
        end
        local cam = Workspace.CurrentCamera
        if cam then return cam:GetRenderCFrame().p end
        return nil
    end

    local function evaluate()
        if not gui then return end
        local auto = false
        if api and type(api.Get) == "function" then
            auto = api.Get()
        else
            auto = GetConfig("settings.autoHideWhenRakeClose", false)
        end

        if not auto then
            if _wasHiddenByAuto then
                pcall(function() if _savedGuiEnabled ~= nil and gui then gui.Enabled = _savedGuiEnabled end end)
                _wasHiddenByAuto = false
                _savedGuiEnabled = nil
            end
            return
        end

        local rakePart = getRakePart()
        local refPos = getRefPosition()
        if not rakePart or not refPos or not rakePart.Parent then
            if _wasHiddenByAuto then
                pcall(function() if _savedGuiEnabled ~= nil and gui then gui.Enabled = _savedGuiEnabled end end)
                _wasHiddenByAuto = false
                _savedGuiEnabled = nil
            end
            return
        end

        local dist = (rakePart.Position - refPos).Magnitude
        if dist <= THRESHOLD then
            if not _wasHiddenByAuto then
                _savedGuiEnabled = (gui and gui.Enabled)
                pcall(function() if gui then gui.Enabled = false end end)
                -- ** relock mouse if it was unlocked when auto hiding
                pcall(function()
                    if type(_G) == "table" and _G.TemptUI and type(_G.TemptUI.StopMouseUnlock) == "function" then
                        _G.TemptUI.StopMouseUnlock()
                    end
                end)
                _wasHiddenByAuto = true
            end
        else
            if _wasHiddenByAuto then
                pcall(function() if _savedGuiEnabled ~= nil and gui then gui.Enabled = _savedGuiEnabled end end)
                pcall(function()
                    if _savedGuiEnabled and type(_G) == "table" and _G.TemptUI and type(_G.TemptUI.StartMouseUnlock) == "function" then
                        _G.TemptUI.StartMouseUnlock()
                    end
                end)
                _wasHiddenByAuto = false
                _savedGuiEnabled = nil
            end
        end
    end

    local function start()
        if renderConn then return end
        renderConn = RunService.RenderStepped:Connect(evaluate)
    end

    local function stop()
        if renderConn and renderConn.Disconnect then renderConn:Disconnect() end
        renderConn = nil
        if _wasHiddenByAuto then
            pcall(function() if _savedGuiEnabled ~= nil and gui then gui.Enabled = _savedGuiEnabled end end)
            _wasHiddenByAuto = false
            _savedGuiEnabled = nil
        end
    end

    if api then
        local prev = api.OnToggle
        api.OnToggle = function(s)
            if prev then pcall(prev, s) end
            if s then start() else stop() end
        end
        pcall(function() if api.Get() then start() end end)
    else
        if GetConfig("settings.autoHideWhenRakeClose", false) then start() end
    end

    if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
        _G.TemptUI.RegisterUnload(function()
            pcall(stop)
        end)
    end
end

-- ** Auto-hide when Rake is close Logic Ends Here ** --

--------------------------------------------------------------------------

-- ** Game Tab Parts ** --


-- ** Power Level Logic ** --
 do
     local PowerUI = {}
     PowerUI.Enabled = false
     local screenGui, panel, header, body, valLabel, titleLabel
     local valueConn
     local cachedValueInst
 
     local function createPowerUI()
         if screenGui and screenGui.Parent then return end
         screenGui = Instance.new("ScreenGui")
         screenGui.Name = "PowerLevelGUI"
         screenGui.IgnoreGuiInset = true
         screenGui.ResetOnSpawn = false
 
         panel = Instance.new("Frame")
         panel.Name = "PowerPanel"
         panel.Size = UDim2.new(0, 220, 0, 84)
         panel.Position = UDim2.new(1, -12, 0, 120)
         panel.AnchorPoint = Vector2.new(1, 0)
         panel.BackgroundColor3 = COLORS.panel
         panel.BorderSizePixel = 0
         panel.Parent = screenGui
         local pCorner = Instance.new("UICorner") pCorner.Parent = panel
 
         header = Instance.new("Frame")
         header.Name = "Header"
         header.Size = UDim2.new(1, 0, 0, 28)
         header.BackgroundColor3 = COLORS.bg
         header.Parent = panel
         local hCorner = Instance.new("UICorner") hCorner.Parent = header
 
         titleLabel = Instance.new("TextLabel")
         titleLabel.Size = UDim2.new(1, -36, 1, 0)
         titleLabel.Position = UDim2.new(0, 8, 0, 0)
         titleLabel.BackgroundTransparency = 1
         titleLabel.Font = Enum.Font.GothamBold
         titleLabel.TextSize = 14
         titleLabel.TextColor3 = COLORS.text
         titleLabel.Text = "Power Level"
         titleLabel.TextXAlignment = Enum.TextXAlignment.Left
         titleLabel.Parent = header
 
         local closeBtn = Instance.new("TextButton")
         closeBtn.Size = UDim2.new(0, 20, 0, 20)
         closeBtn.Position = UDim2.new(1, -28, 0, 4)
         closeBtn.AnchorPoint = Vector2.new(0, 0)
         closeBtn.BackgroundTransparency = 1
         closeBtn.Font = Enum.Font.GothamBold
         closeBtn.TextSize = 14
         closeBtn.TextColor3 = COLORS.text
         closeBtn.Text = "X"
         closeBtn.Parent = header
         closeBtn.MouseButton1Click:Connect(function()
             local api = ToggleAPI[showPowerLevelToggle]
             if api and type(api.Set) == "function" then pcall(function() api.Set(false) end) end
         end)
 
         body = Instance.new("Frame")
         body.Name = "Body"
         body.Size = UDim2.new(1, 0, 1, -28)
         body.Position = UDim2.new(0, 0, 0, 28)
         body.BackgroundTransparency = 1
         body.Parent = panel
 
         local label = Instance.new("TextLabel")
         label.Size = UDim2.new(1, -16, 0, 20)
         label.Position = UDim2.new(0, 8, 0, 8)
         label.BackgroundTransparency = 1
         label.Font = Enum.Font.Gotham
         label.TextSize = 14
         label.TextColor3 = COLORS.textDim
         label.Text = "Value:"
         label.TextXAlignment = Enum.TextXAlignment.Left
         label.Parent = body
 
         valLabel = Instance.new("TextLabel")
         valLabel.Size = UDim2.new(1, -16, 0, 22)
         valLabel.Position = UDim2.new(0, 8, 0, 30)
         valLabel.BackgroundTransparency = 1
         valLabel.Font = Enum.Font.GothamBold
         valLabel.TextSize = 16
         valLabel.TextColor3 = COLORS.text
         valLabel.Text = "--"
         valLabel.TextXAlignment = Enum.TextXAlignment.Left
         valLabel.Parent = body
 
         -- ** draglable thing
         header.Active = true
         local dragging, dragStart, startPos = false, nil, nil
         header.InputBegan:Connect(function(input)
             if input.UserInputType == Enum.UserInputType.MouseButton1 then
                 local overGui = false
                 pcall(function()
                     local objs = UserInputService:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
                     for _, o in ipairs(objs or {}) do
                         if o and (o:IsA("TextButton") or o:IsA("ImageButton") or o:IsA("TextBox")) then
                             overGui = true; break
                         end
                     end
                 end)
                 if overGui then return end
                 dragging = true
                 dragStart = input.Position
                 startPos = panel.Position
                 input.Changed:Connect(function()
                     if input.UserInputState == Enum.UserInputState.End then dragging = false end
                 end)
             end
         end)
         UserInputService.InputChanged:Connect(function(input)
             if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
                 local delta = input.Position - dragStart
                 panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
             end
         end)
 
         screenGui.Parent = player:WaitForChild("PlayerGui")
     end

     -------------------- Break from UI --------------------
 
     local function updateValue(v)
         if not valLabel then return end
         if v == 1000 then
             valLabel.Text = "Power is full"
         elseif v == 0 then
             valLabel.Text = "Power is out"
         else
             valLabel.Text = tostring(v)
         end
     end
 
     local function start()
         if PowerUI.Enabled then return end
         PowerUI.Enabled = true
         createPowerUI()
         local ok, pv = pcall(function()
             local rs = game:GetService("ReplicatedStorage")
             local pvFolder = rs:FindFirstChild("PowerValues")
             return pvFolder and pvFolder:FindFirstChild("PowerLevel")
         end)
         cachedValueInst = ok and pv or nil
         if cachedValueInst and cachedValueInst.Value ~= nil then pcall(updateValue, cachedValueInst.Value) end
         if cachedValueInst then
             if valueConn and valueConn.Disconnect then valueConn:Disconnect() end
             valueConn = cachedValueInst.Changed:Connect(function()
                 pcall(function() updateValue(cachedValueInst.Value) end)
             end)
         end
     end
 
     local function stop()
         if not PowerUI.Enabled then return end
         PowerUI.Enabled = false
         if valueConn and valueConn.Disconnect then valueConn:Disconnect() end
         valueConn = nil
         cachedValueInst = nil
         if screenGui and screenGui.Parent then pcall(function() screenGui:Destroy() end) end
         screenGui = nil
         panel = nil
         valLabel = nil
     end
 
     local api = ToggleAPI[showPowerLevelToggle]
     if api then
         local prev = api.OnToggle
         api.OnToggle = function(s)
             if prev then pcall(prev, s) end
             if s then pcall(start) else pcall(stop) end
         end
         pcall(function() if api.Get() then start() end end)
     end

      -------------------- Break for Unload --------------------
      if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
         _G.TemptUI.RegisterUnload(function()
             pcall(stop)
         end)
     end
 end
 
-- ** Power Level Logic Ends Here ** --

--------------------------------------------------------------------------

-- ** Object Finder Logic ** --

do

    local ScrapFinder = {}
    local entries = {}
    local pending = {}
    local creating = {}
    local addedConn, removedConn
    local renderConn

    local scrapIndex
    for i,v in ipairs(objectListItems or {}) do if type(v)=="string" and v:lower()=="scrap" then scrapIndex=i; break end end
    local trapIndex
    for i,v in ipairs(objectListItems or {}) do if type(v)=="string" and (v:lower():find("trap") or v:lower():find("traps")) then trapIndex=i; break end end
    local flareIndex
    for i,v in ipairs(objectListItems or {}) do if type(v)=="string" and v:lower():find("flare") then flareIndex=i; break end end
    local supplyIndex
    for i,v in ipairs(objectListItems or {}) do if type(v)=="string" and v:lower():find("supply") then supplyIndex=i; break end end

    local objApi = DropdownAPI[objectListDropdown]
    local tApi = ToggleAPI[showObjectFinderToggle]

    local function findDisplayPart(inst)
        if not inst then return nil end
        if inst:IsA("BasePart") then return inst end
        if inst:IsA("Model") then
            if inst.PrimaryPart then return inst.PrimaryPart end
            for _,d in ipairs(inst:GetDescendants()) do if d:IsA("BasePart") then return d end end
        end
        return nil
    end

    local function extractLevel(name)
        if not name then return nil end
        local s = name:match("scrap[^%d]*(%d+)%s*$") or name:match("(%d+)%s*$")
        if s then return tonumber(s) end
        return nil
    end

    local function getDisplayPos(inst)
        local p = findDisplayPart(inst)
        if not p then return nil end
        if not p:IsDescendantOf(Workspace) then return nil end
        return p.Position
    end

    local function isClustered(inst)
        local pos = getDisplayPos(inst)
        if not pos then return false end
        local scrapRoot = Workspace:FindFirstChild("Filter")
        local scrapSpawns = scrapRoot and scrapRoot:FindFirstChild("ScrapSpawns")
        local objs = scrapSpawns and scrapSpawns:GetChildren() or {}
        for _,obj in ipairs(objs) do
            if obj ~= inst and obj:IsA("Model") and (obj.Name or ""):lower():find("scrap") then
                local p2 = findDisplayPart(obj)
                if p2 and p2:IsDescendantOf(Workspace) then
                    local ok, dist = pcall(function() return (p2.Position - pos).Magnitude end)
                    if ok and dist and dist <= 3 then return true end
                end
            end
        end
        return false
    end

    local function isScrapCandidate(inst)
        if not inst or not inst.Parent then return false end
        local n = (inst.Name or ""):lower()
        local compact = n:gsub("[_%s%-%p]", "")
        if compact=="scrapspawn" or compact=="scrapspawns" then return false end
        return n:find("scrap",1,true)~=nil
    end

---------------------------------------------------------------------------

    -- ** ScrapFinder: UI / Visuals **

    local function makeVisual(keyInst, level)
        if not keyInst or entries[keyInst] then return false end
        local part = findDisplayPart(keyInst)
        if not part or not part:IsDescendantOf(Workspace) then return false end
        if not keyInst.Parent then return false end
        local ok, bb = pcall(function()
            local g = Instance.new("BillboardGui")
            g.Name = "Tempt_ScrapBB"
            g.Size = UDim2.new(0,200,0,48)
            g.Adornee = part
            g.AlwaysOnTop = true
            g.StudsOffset = Vector3.new(0,2.4,0)
            g.Parent = gui

            local t = Instance.new("TextLabel")
            t.Name = "Label"
            t.Size = UDim2.new(1,0,1,0)
            t.Position = UDim2.new(0,0,0,0)
            t.BackgroundTransparency = 1
            t.TextXAlignment = Enum.TextXAlignment.Center
            t.Font = Enum.Font.GothamBold
            t.TextSize = 18
            t.TextColor3 = Color3.fromRGB(150,75,0)
            t.Text = level and ("Scrap — Lv "..tostring(level)) or "Scrap"
            t.Parent = g

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(0,0,0)
            stroke.Thickness = 1
            stroke.Parent = t
            return g
        end)
        if not ok or not bb then return false end
        local ok2, hl = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "Tempt_ScrapHL"
            h.Adornee = keyInst
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = Color3.fromRGB(150,75,0)
            h.FillTransparency = 0.35
            h.OutlineColor = Color3.fromRGB(0,0,0)
            h.OutlineTransparency = 0
            h.Parent = keyInst
            return h
        end)
        if ok2 and hl and bb then
            pcall(function()
                local lbl = bb:FindFirstChild("Label")
                if lbl and lbl:IsA("TextLabel") then
                    lbl.TextColor3 = hl.FillColor
                end
            end)
        end
        local strokeRef
        pcall(function()
            local lbl = bb and bb:FindFirstChild("Label")
            if lbl then strokeRef = lbl:FindFirstChildOfClass("UIStroke") end
        end)
        entries[keyInst] = { bb = bb, hl = (ok2 and hl) and hl or nil, stroke = strokeRef }

        pcall(function()
            local cam = Workspace.CurrentCamera
            local lbl = bb and bb:FindFirstChild("Label")
            if cam and lbl and bb and bb.Adornee and bb.Adornee:IsA("BasePart") then
                local okd, dist = pcall(function() return (bb.Adornee.Position - cam.CFrame.Position).Magnitude end)
                local NEAR, FAR = 20, 200
                local alpha = 0
                if okd and dist then alpha = math.clamp((dist - NEAR) / (FAR - NEAR), 0, 1) end
                lbl.TextTransparency = alpha
                local minSize, maxSize = 12, 18
                lbl.TextSize = math.floor(maxSize - (maxSize - minSize) * alpha + 0.5)
                if strokeRef then strokeRef.Transparency = alpha end
            end
        end)

        return true
    end

    ---------------------------------------------------------------------------

    -- ** ScrapFinder Handler ** --

    local function removeVisual(keyInst)
        local v = entries[keyInst]
        if not v then return end
        if pending[keyInst] then
            for _,c in ipairs(pending[keyInst]) do pcall(function() if c and c.Disconnect then c:Disconnect() end end) end
            pending[keyInst] = nil
            creating[keyInst] = nil
        end
        pcall(function() if v.bb then v.bb:Destroy() end end)
        pcall(function() if v.hl then v.hl:Destroy() end end)
        entries[keyInst] = nil
    end

    local function clearPendingForKey(k)
        local p = pending[k]
        if not p then return end
        for _,c in ipairs(p) do pcall(function() if c and c.Disconnect then c:Disconnect() end end) end
        pending[k] = nil
        creating[k] = nil
    end

    local function handleAdded(desc)
        if tApi and tApi.Get and not tApi.Get() then return end
        if not scrapIndex or not objApi or not objApi.IsSelected or not objApi.IsSelected(scrapIndex) then return end
        if not isScrapCandidate(desc) then return end
        local cur = desc
        for i=1,8 do if not cur then break end; if cur:IsA("Model") and (cur.Name or ""):lower():find("scrap") then break end; cur = cur.Parent end
        local key = (cur and cur:IsA("Model") and cur) or desc
        local scrapRoot = Workspace:FindFirstChild("Filter")
        local scrapSpawns = scrapRoot and scrapRoot:FindFirstChild("ScrapSpawns")
        if not scrapSpawns or not key:IsDescendantOf(scrapSpawns) then return end
        if entries[key] then return end
        local lvl = extractLevel((key.Name or ""))
        if not lvl and key:IsA("Model") then
            for _,c in ipairs(key:GetDescendants()) do
                if (c:IsA("NumberValue") or c:IsA("IntValue")) and c.Name and (c.Name:lower():find("level") or c.Name:lower():find("lvl")) then lvl = c.Value; break end
            end
        end
        if isClustered(key) then return end
        if makeVisual(key, lvl) then return end
        if not key or not key:IsA("Model") then return end
        if pending[key] then return end
        pending[key] = {}
        local function attempt()
            if entries[key] then clearPendingForKey(key); return end
            if creating[key] then return end
            creating[key] = true
            local ok = false
            pcall(function() ok = makeVisual(key, lvl) end)
            creating[key] = nil
            if ok then clearPendingForKey(key) end
        end
        if key.DescendantAdded then table.insert(pending[key], key.DescendantAdded:Connect(function() pcall(attempt) end)) end
        if key.GetPropertyChangedSignal then table.insert(pending[key], key:GetPropertyChangedSignal("PrimaryPart"):Connect(function() pcall(attempt) end)) end
        spawn(function()
            wait(0.2); pcall(attempt)
            wait(1); pcall(attempt)
            wait(2); pcall(attempt)
            clearPendingForKey(key)
        end)
    end

    local function handleRemoving(desc)
        local cur = desc
        for i=1,8 do if not cur then break end; if cur:IsA("Model") and (cur.Name or ""):lower():find("scrap") then break end; cur = cur.Parent end
        local key = (cur and cur:IsA("Model") and cur) or desc
        if entries[key] then removeVisual(key) end
    end

    -- ** ScrapFinder Main Functions ** --
    function ScrapFinder.start()
        if addedConn then return end
        local scrapRoot = Workspace:FindFirstChild("Filter")
        local scrapSpawns = scrapRoot and scrapRoot:FindFirstChild("ScrapSpawns")
        if tApi and tApi.Get and tApi.Get() and scrapIndex and objApi and objApi.IsSelected and objApi.IsSelected(scrapIndex) then
            local list = scrapSpawns and scrapSpawns:GetDescendants() or Workspace:GetDescendants()
            local batch = 60
            for i = 1, #list, batch do
                for j = i, math.min(i+batch-1, #list) do pcall(function() handleAdded(list[j]) end) end
                RunService.Heartbeat:Wait()
            end
        end
        if scrapSpawns then
            addedConn = scrapSpawns.DescendantAdded:Connect(function(d) pcall(function() handleAdded(d) end) end)
            removedConn = scrapSpawns.DescendantRemoving:Connect(function(d) pcall(function() handleRemoving(d) end) end)
        else
            addedConn = Workspace.DescendantAdded:Connect(function(d) pcall(function() handleAdded(d) end) end)
            removedConn = Workspace.DescendantRemoving:Connect(function(d) pcall(function() handleRemoving(d) end) end)
        end
        if tApi then local prevT = tApi.OnToggle; tApi.OnToggle = function(state) if prevT then pcall(prevT,state) end; if state then if scrapIndex and objApi and objApi.IsSelected and objApi.IsSelected(scrapIndex) then local list = scrapSpawns and scrapSpawns:GetDescendants() or Workspace:GetDescendants(); local batch = 60; for i = 1, #list, batch do for j = i, math.min(i+batch-1, #list) do pcall(function() handleAdded(list[j]) end) end RunService.Heartbeat:Wait() end end else for k,_ in pairs(entries) do removeVisual(k) end end end end
        if not renderConn then
            renderConn = RunService.RenderStepped:Connect(function()
                local cam = Workspace.CurrentCamera
                if not cam then return end
                local camPos = cam.CFrame.Position
                local NEAR, FAR = 20, 200
                for k,v in pairs(entries) do
                    local bb = v.bb
                    if bb and bb:IsA("BillboardGui") then
                        local lbl = bb:FindFirstChild("Label")
                        local stroke = v.stroke
                        local adornee = bb.Adornee
                        if lbl and adornee and adornee:IsA("BasePart") then
                            local ok, dist = pcall(function() return (adornee.Position - camPos).Magnitude end)
                            local alpha = 0
                            if ok and dist then alpha = math.clamp((dist - NEAR) / (FAR - NEAR), 0, 1) end
                            lbl.TextTransparency = alpha
                            local minSize, maxSize = 12, 18
                            lbl.TextSize = math.floor(maxSize - (maxSize - minSize) * alpha + 0.5)
                            if stroke then stroke.Transparency = alpha end
                        end
                    end
                end
            end)
        end
    end

    function ScrapFinder.unload()
        if addedConn and addedConn.Disconnect then addedConn:Disconnect() end
        if removedConn and removedConn.Disconnect then removedConn:Disconnect() end
        addedConn, removedConn = nil, nil
        for k,_ in pairs(entries) do removeVisual(k) end
        for k,_ in pairs(pending) do clearPendingForKey(k) end
        entries = {}
        if renderConn and renderConn.Disconnect then renderConn:Disconnect() end
        renderConn = nil
        -- ensure FlareFinder visuals cleaned up via central unload
        pcall(function() if FlareFinder and FlareFinder.unload then FlareFinder.unload() end end)
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj and obj.Name == "Tempt_ScrapHL" then pcall(function() obj:Destroy() end) end
            if obj and obj.Name == "Tempt_ScrapBB" then pcall(function() obj:Destroy() end) end
        end
        -- ensure SupplyFinder visuals cleaned up as well
        pcall(function() if SupplyFinder and SupplyFinder.unload then SupplyFinder.unload() end end)
        if gui then
            for _,obj in ipairs(gui:GetDescendants()) do
                if obj and obj.Name == "Tempt_ScrapBB" then pcall(function() obj:Destroy() end) end
            end
        end
    end

-- ** ScrapFinder Ends Here ** --

--------------------------------------------------------------------------

-- ** FlareFinder Starts Here ** --


    local FlareFinder = {}
    local flareEntry = nil
    local flareAddedConn, flareRemConn, workspaceChildConn

    local function createFlareVisual(fgPick, part)
        if not fgPick or not part then return end
        if flareEntry and flareEntry.part and flareEntry.part.Parent then return end
        local ok, hl = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "Tempt_FlareHL"
            h.Adornee = fgPick
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = Color3.fromRGB(255,105,180)
            h.FillTransparency = 0.25
            h.OutlineColor = Color3.fromRGB(0,0,0)
            h.OutlineTransparency = 0
            h.Parent = fgPick
            return h
        end)

        local ok2, bb = pcall(function()
            local g = Instance.new("BillboardGui")
            g.Name = "Tempt_FlareBB"
            g.Size = UDim2.new(0,180,0,32)
            g.Adornee = part
            g.AlwaysOnTop = true
            g.StudsOffset = Vector3.new(0,2.2,0)
            g.Parent = gui

            local t = Instance.new("TextLabel")
            t.Name = "Label"
            t.Size = UDim2.new(1,0,1,0)
            t.BackgroundTransparency = 1
            t.Font = Enum.Font.GothamBold
            t.TextSize = 18
            t.Text = "Flare Gun"
            t.TextColor3 = Color3.fromRGB(255,105,180)
            t.TextXAlignment = Enum.TextXAlignment.Center
            t.Parent = g
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(0,0,0)
            stroke.Thickness = 1
            stroke.Parent = t
            return g
        end)
        if ok2 and bb then
            local strokeRef
            pcall(function()
                local lbl = bb:FindFirstChild("Label")
                if lbl then strokeRef = lbl:FindFirstChildOfClass("UIStroke") end
            end)
            entries[fgPick] = { bb = bb, hl = (ok and hl) and hl or nil, stroke = strokeRef }
            pcall(function()
                local cam = Workspace.CurrentCamera
                local lbl = bb:FindFirstChild("Label")
                if cam and lbl and bb and bb.Adornee and bb.Adornee:IsA("BasePart") then
                    local okd, dist = pcall(function() return (bb.Adornee.Position - cam.CFrame.Position).Magnitude end)
                    local NEAR, FAR = 20, 200
                    local alpha = 0
                    if okd and dist then alpha = math.clamp((dist - NEAR) / (FAR - NEAR), 0, 1) end
                    lbl.TextTransparency = alpha
                    local minSize, maxSize = 12, 18
                    lbl.TextSize = math.floor(maxSize - (maxSize - minSize) * alpha + 0.5)
                    if strokeRef then strokeRef.Transparency = alpha end
                end
            end)
        end

        flareEntry = { part = part, hl = (ok and hl) and hl or nil, bb = (ok2 and bb) and bb or nil }
    end

    function FlareFinder.start()
        if flareAddedConn or workspaceChildConn then return end

        local fgPick = Workspace:FindFirstChild("FlareGunPickUp")
        if fgPick then
            local part = fgPick:FindFirstChild("FlareGun")
            if part and part:IsA("BasePart") then createFlareVisual(fgPick, part) end
            flareAddedConn = fgPick.DescendantAdded:Connect(function(desc)
                if not desc then return end
                if desc.Name == "FlareGun" and desc:IsA("BasePart") then createFlareVisual(fgPick, desc) end
            end)
            flareRemConn = fgPick.DescendantRemoving:Connect(function(desc)
                if not desc then return end
                if desc.Name == "FlareGun" then pcall(function() FlareFinder.unload() end) end
            end)
        end

        workspaceChildConn = Workspace.ChildAdded:Connect(function(child)
            if not child then return end
            if child.Name == "FlareGunPickUp" then
                local part = child:FindFirstChild("FlareGun")
                if part and part:IsA("BasePart") then createFlareVisual(child, part) end
                if not flareAddedConn then
                    flareAddedConn = child.DescendantAdded:Connect(function(desc)
                        if not desc then return end
                        if desc.Name == "FlareGun" and desc:IsA("BasePart") then createFlareVisual(child, desc) end
                    end)
                end
                if not flareRemConn then
                    flareRemConn = child.DescendantRemoving:Connect(function(desc)
                        if not desc then return end
                        if desc.Name == "FlareGun" then pcall(function() FlareFinder.unload() end) end
                    end)
                end
            end
        end)
    end

    function FlareFinder.unload()
        if flareAddedConn and flareAddedConn.Disconnect then flareAddedConn:Disconnect() end
        if flareRemConn and flareRemConn.Disconnect then flareRemConn:Disconnect() end
        if workspaceChildConn and workspaceChildConn.Disconnect then workspaceChildConn:Disconnect() end
        flareAddedConn, flareRemConn, workspaceChildConn = nil, nil, nil
        if flareEntry then
            pcall(function() if flareEntry.bb then flareEntry.bb:Destroy() end end)
            pcall(function() if flareEntry.hl then flareEntry.hl:Destroy() end end)
            local fgPick = flareEntry and flareEntry.part and flareEntry.part.Parent
            if fgPick then entries[fgPick] = nil end
            flareEntry = nil
        end
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj and obj.Name == "Tempt_FlareHL" then pcall(function() obj:Destroy() end) end
            if obj and obj.Name == "Tempt_FlareBB" then pcall(function() obj:Destroy() end) end
        end
        if gui then
            for _,obj in ipairs(gui:GetDescendants()) do
                if obj and obj.Name == "Tempt_FlareBB" then pcall(function() obj:Destroy() end) end
            end
        end
    end

    -- ** FlareFinder ends here ** --

--------------------------------------------------------------------------

    -- ** SupplyDropFinder Starts Here ** --

    local SupplyFinder = {}
    local supplyMap = {} 
    local supplyChildConn, supplyRootConn

    local function findCanonicalSupply(obj)
        if not obj or not obj.Parent then return nil end
        local name = (obj.Name or ""):lower()
        if name == "box" then
            local p = obj.Parent
            for i=1,6 do
                if not p then break end
                local pn = (p.Name or ""):lower()
                if pn:find("supplycrates") or pn:find("supply") or pn:find("debris") then
                    local crate = obj
                    while crate and crate.Parent and crate.Parent ~= p do crate = crate.Parent end
                    return crate
                end
                p = p.Parent
            end
        end
        if obj:IsA("Model") and ((obj.Name or ""):lower():find("supply")) then return obj end
        local cur = obj
        for i=1,8 do
            if not cur then break end
            local n = (cur.Name or ""):lower()
            if n == "supplydrop" or n == "supplycrate" or n:find("supply") then
                if cur:IsA("Model") then return cur end
            end
            cur = cur.Parent
        end
        return nil
    end

    local function makeVisualForSupply(model)
        if not model or not model.Parent then return end
        if supplyMap[model] or entries[model] then return end
        local function findPart(m)
            if not m then return nil end
            local hit = m:FindFirstChild("HitBox")
            if hit and hit:IsA("BasePart") then return hit end
            local b = m:FindFirstChild("Box") or m:FindFirstChild("body")
            if b and b:IsA("BasePart") then return b end
            for _,d in ipairs(m:GetDescendants()) do if d and d:IsA("BasePart") then return d end end
            return nil
        end
        local adornee = findPart(model)
        if not adornee then return end
        local created = { hls = {} }
        for _,d in ipairs(model:GetDescendants()) do
            if d and d:IsA("BasePart") then
                pcall(function()
                    local h = Instance.new("Highlight")
                    h.Name = "Tempt_SupplyHL"
                    h.Adornee = d
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillColor = Color3.fromRGB(0,255,128)
                    h.FillTransparency = 0.2
                    h.OutlineColor = Color3.fromRGB(6,6,6)
                    h.OutlineTransparency = 0
                    h.Parent = Workspace
                    table.insert(created.hls, h)
                end)
            end
        end
        local bb
        pcall(function()
            bb = Instance.new("BillboardGui")
            bb.Name = "Tempt_SupplyBB"
            bb.Adornee = adornee
            bb.Size = UDim2.new(0,200,0,36)
            bb.StudsOffset = Vector3.new(0,2.6,0)
            bb.AlwaysOnTop = true
            bb.Parent = gui
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1,0,1,0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.TextSize = 20
            label.Text = "Supply Drop"
            label.TextColor3 = Color3.fromRGB(0,230,120)
            label.TextXAlignment = Enum.TextXAlignment.Center
            label.Parent = bb
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.new(0,0,0)
            stroke.Thickness = 2
            stroke.Parent = label
        end)
        supplyMap[model] = { bb = bb, hls = created.hls }
        entries[model] = { bb = bb, hl = created.hls, stroke = (bb and bb:FindFirstChild("Label") and bb.Label:FindFirstChildOfClass("UIStroke")) }
        local conn
        conn = model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                pcall(function()
                    local info = supplyMap[model]
                    if info then
                        if info.bb and info.bb.Parent then info.bb:Destroy() end
                        for _,h in ipairs(info.hls or {}) do pcall(function() if h and h.Parent then h:Destroy() end end) end
                        entries[model] = nil
                        supplyMap[model] = nil
                    end
                end)
                if conn and conn.Disconnect then conn:Disconnect() end
            end
        end)
        supplyMap[model].conn = conn
    end

    function SupplyFinder.start()
        if supplyRootConn then return end
        local debris = Workspace:FindFirstChild("Debris")
        local supplyRoot = debris and debris:FindFirstChild("SupplyCrates")
        if supplyRoot then
            spawn(function()
                local kids = supplyRoot:GetChildren()
                local BATCH = 40
                for i = 1, #kids, BATCH do
                    for j = i, math.min(i+BATCH-1, #kids) do
                        local c = kids[j]
                        if c then
                            local canonical = findCanonicalSupply(c) or c
                            pcall(function() makeVisualForSupply(canonical) end)
                        end
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
            supplyChildConn = supplyRoot.ChildAdded:Connect(function(child)
                if not child then return end
                local canonical = findCanonicalSupply(child) or child
                pcall(function()
                    makeVisualForSupply(canonical)
                    if NOTIFICATIONS_ENABLED then
                        pcall(function() makeNotification("Supply Drop spawned!", 3) end)
                    end
                end)
            end)
        end
        supplyRootConn = Workspace.ChildAdded:Connect(function(c)
            if not c then return end
            if c.Name == "Debris" then
                local sr = c:FindFirstChild("SupplyCrates")
                if sr and not supplyChildConn then
                    supplyChildConn = sr.ChildAdded:Connect(function(child)
                        if not child then return end
                        local canonical = findCanonicalSupply(child) or child
                        pcall(function()
                            makeVisualForSupply(canonical)
                            if NOTIFICATIONS_ENABLED then
                                pcall(function() makeNotification("Supply Drop spawned!", 3) end)
                            end
                        end)
                    end)
                end
            end
        end)
    end

    function SupplyFinder.unload()
        if supplyChildConn and supplyChildConn.Disconnect then supplyChildConn:Disconnect() end
        if supplyRootConn and supplyRootConn.Disconnect then supplyRootConn:Disconnect() end
        supplyChildConn, supplyRootConn = nil, nil
        for model,info in pairs(supplyMap) do
            pcall(function() if info.bb and info.bb.Parent then info.bb:Destroy() end end)
            for _,h in ipairs(info.hls or {}) do pcall(function() if h and h.Parent then h:Destroy() end end) end
            if info.conn and info.conn.Disconnect then info.conn:Disconnect() end
            entries[model] = nil
            supplyMap[model] = nil
        end
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj and obj.Name == "Tempt_SupplyHL" then pcall(function() obj:Destroy() end) end
            if obj and obj.Name == "Tempt_SupplyBB" then pcall(function() obj:Destroy() end) end
        end
        if gui then
            for _,obj in ipairs(gui:GetDescendants()) do
                if obj and obj.Name == "Tempt_SupplyBB" then pcall(function() obj:Destroy() end) end
            end
        end
    end

    -- ** SupplyFinder ends here ** --

--------------------------------------------------------------------------

    -- ** TrapsFinder Starts Here ** --

    local TrapsFinder = {}
    local trapMap = {}
    local trapChildConn, trapRootConn

    local function findHitBox(model)
        if not model then return nil end
        for _,d in ipairs(model:GetDescendants()) do
            if d and d:IsA("BasePart") and (d.Name == "HitBox" or d.Name:lower():find("hit")) then return d end
        end
        -- ** fallback to PrimaryPart or any BasePart
        if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then return model.PrimaryPart end
        for _,d in ipairs(model:GetDescendants()) do if d and d:IsA("BasePart") then return d end end
        return nil
    end

    local function detectTrapType(model)
        if not model then return "Unknown" end
        local part = model:FindFirstChild("Close") or model:FindFirstChild("Open")
        if part and part:IsA("BasePart") then
            local mat = part.Material
            if mat == Enum.Material.CorrodedMetal then return "Rusty" end
            if mat == Enum.Material.Plastic then return "Player" end
        end
        -- ** try descendants
        for _,d in ipairs(model:GetDescendants()) do
            if d and d:IsA("BasePart") and (d.Name == "Close" or d.Name == "Open") then
                local mat = d.Material
                if mat == Enum.Material.CorrodedMetal then return "Rusty" end
                if mat == Enum.Material.Plastic then return "Player" end
            end
        end
        return "Unknown"
    end

    local function makeTrapVisual(model)
        if not model or not model.Parent then return end
        if trapMap[model] or entries[model] then return end
        local hit = findHitBox(model)
        if not hit then return end
        local ttype = detectTrapType(model)
        local color
        local labelText
        if ttype == "Rusty" then
            color = Color3.fromRGB(160,48,32)
            labelText = "Rusty Trap"
        elseif ttype == "Player" then
            color = Color3.fromRGB(220,24,24)
            labelText = "Player Trap"
        else
            color = Color3.fromRGB(200,80,30)
            labelText = "Trap"
        end

        local ok, hl = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "Tempt_TrapsHL"
            h.Adornee = model
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = color
            h.FillTransparency = 0.25
            h.OutlineColor = Color3.fromRGB(8,8,8)
            h.OutlineTransparency = 0
            h.Parent = model
            return h
        end)

        local bb
        pcall(function()
            bb = Instance.new("BillboardGui")
            bb.Name = "Tempt_TrapsBB"
            bb.Adornee = hit
            bb.Size = UDim2.new(0,160,0,28)
            bb.StudsOffset = Vector3.new(0,2,0)
            bb.AlwaysOnTop = true
            bb.Parent = gui

            local t = Instance.new("TextLabel")
            t.Name = "Label"
            t.Size = UDim2.new(1,0,1,0)
            t.BackgroundTransparency = 1
            t.Font = Enum.Font.GothamBold
            t.TextSize = 18
            t.Text = labelText
            t.TextColor3 = color
            t.TextXAlignment = Enum.TextXAlignment.Center
            t.Parent = bb

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.new(0,0,0)
            stroke.Thickness = 1.5
            stroke.Parent = t
        end)

        trapMap[model] = { bb = bb, hl = (ok and hl) and hl or nil }
        entries[model] = { bb = bb, hl = (ok and hl) and hl or nil, stroke = (bb and bb:FindFirstChild("Label") and bb.Label:FindFirstChildOfClass("UIStroke")) }

        local conn
        conn = model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                pcall(function()
                    local info = trapMap[model]
                    if info then
                        if info.bb and info.bb.Parent then info.bb:Destroy() end
                        if info.hl and info.hl.Parent then info.hl:Destroy() end
                        entries[model] = nil
                        trapMap[model] = nil
                    end
                end)
                if conn and conn.Disconnect then conn:Disconnect() end
            end
        end)
        trapMap[model].conn = conn
    end

    function TrapsFinder.start()
        if trapRootConn then return end
        local debris = Workspace:FindFirstChild("Debris")
        local trapsRoot = debris and debris:FindFirstChild("Traps")
        if trapsRoot then
            spawn(function()
                local kids = trapsRoot:GetChildren()
                local BATCH = 40
                for i = 1, #kids, BATCH do
                    for j = i, math.min(i+BATCH-1, #kids) do
                        local c = kids[j]
                        if c and c:IsA("Model") then pcall(function() makeTrapVisual(c) end) end
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
            trapChildConn = trapsRoot.ChildAdded:Connect(function(child)
                if not child then return end
                if child:IsA("Model") then pcall(function() makeTrapVisual(child) end) end
            end)
        end
        trapRootConn = Workspace.ChildAdded:Connect(function(c)
            if not c then return end
            if c.Name == "Debris" then
                local tr = c:FindFirstChild("Traps")
                if tr and not trapChildConn then
                    trapChildConn = tr.ChildAdded:Connect(function(child)
                        if not child then return end
                        if child:IsA("Model") then pcall(function() makeTrapVisual(child) end) end
                    end)
                end
            end
        end)
    end

    function TrapsFinder.unload()
        if trapChildConn and trapChildConn.Disconnect then trapChildConn:Disconnect() end
        if trapRootConn and trapRootConn.Disconnect then trapRootConn:Disconnect() end
        trapChildConn, trapRootConn = nil, nil
        for model,info in pairs(trapMap) do
            pcall(function() if info.bb and info.bb.Parent then info.bb:Destroy() end end)
            pcall(function() if info.hl and info.hl.Parent then info.hl:Destroy() end end)
            if info.conn and info.conn.Disconnect then info.conn:Disconnect() end
            entries[model] = nil
            trapMap[model] = nil
        end
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj and obj.Name == "Tempt_TrapsHL" then pcall(function() obj:Destroy() end) end
            if obj and obj.Name == "Tempt_TrapsBB" then pcall(function() obj:Destroy() end) end
        end
        if gui then
            for _,obj in ipairs(gui:GetDescendants()) do
                if obj and obj.Name == "Tempt_TrapsBB" then pcall(function() obj:Destroy() end) end
            end
        end
    end

    -- ** TrapsFinder ends here ** --

--------------------------------------------------------------------------

    -- ** Override object-list dropdown handler to directly start/unload specific finders
    pcall(function()
        local oApi = DropdownAPI[objectListDropdown]
        local tApiLocal = ToggleAPI[showObjectFinderToggle]
        if oApi then
            local prev = oApi.OnSelect
            oApi.OnSelect = function(index, value, selected)
                if prev and type(prev) == "function" then pcall(prev, index, value, selected) end
                local key = (type(value) == "string" and value:lower()) or ""
                SetConfig(objectListConfigKey, (GetConfig(objectListConfigKey) or {}))
                if key:find("trap") or key:find("traps") then
                    if selected == true then
                        if tApiLocal and tApiLocal.Get and tApiLocal.Get() then pcall(function() TrapsFinder.start() end) end
                    else
                        pcall(function() TrapsFinder.unload() end)
                    end
                elseif key:find("scrap") then
                    if selected == true then
                        if tApiLocal and tApiLocal.Get and tApiLocal.Get() then pcall(function() ScrapFinder.start() end) end
                    else
                        pcall(function() ScrapFinder.unload() end)
                    end
                elseif key:find("supply") then
                    if selected == true then
                        if tApiLocal and tApiLocal.Get and tApiLocal.Get() then pcall(function() SupplyFinder.start() end) end
                    else
                        pcall(function() SupplyFinder.unload() end)
                    end
                elseif key:find("flare") or key:find("flaregun") then
                    if selected == true then
                        if tApiLocal and tApiLocal.Get and tApiLocal.Get() then pcall(function() FlareFinder.start() end) end
                    else
                        pcall(function() FlareFinder.unload() end)
                    end
                else
                    if selected then
                        if tApiLocal and tApiLocal.Get and tApiLocal.Get() then pcall(function() ScrapFinder.start() end) end
                    else
                        pcall(function() ScrapFinder.unload() end)
                    end
                end
            end
        end
    end)


    pcall(function()
        local tApi = ToggleAPI[showObjectFinderToggle]
        if tApi then
            local prevT = tApi.OnToggle
            tApi.OnToggle = function(state)
                if prevT then pcall(prevT, state) end
                if state then
                    local stored = GetConfig(objectListConfigKey) or {}
                    for i,v in ipairs(objectListItems or {}) do
                        if stored[i] then
                            local key = (type(v) == "string" and v:lower()) or ""
                            if key:find("trap") or key:find("traps") then pcall(function() TrapsFinder.start() end)
                            elseif key:find("scrap") then pcall(function() ScrapFinder.start() end)
                            elseif key:find("supply") then pcall(function() SupplyFinder.start() end)
                            elseif key:find("flare") or key:find("flaregun") then pcall(function() FlareFinder.start() end)
                            end
                        end
                    end
                else
                    pcall(function() ScrapFinder.unload() end)
                    pcall(function() FlareFinder.unload() end)
                    pcall(function() SupplyFinder.unload() end)
                end
            end
        end
    end)





    -------------------- Break for Unload --------------------

    if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload)=="function" then
        _G.TemptUI.RegisterUnload(function()
            pcall(function() ScrapFinder.unload() end)
            pcall(function() FlareFinder.unload() end)
            pcall(function() SupplyFinder.unload() end)
            pcall(function() TrapsFinder.unload() end)
        end)
    end
    -- ** Start selected toggles
    local function startSelectedFindersIfNeeded()
        local stored = GetConfig(objectListConfigKey) or {}
        local tstate = (tApi and tApi.Get and tApi.Get()) or false
        if not tstate then return end
        if scrapIndex and stored[scrapIndex] then pcall(function() ScrapFinder.start() end) end
        if flareIndex and stored[flareIndex] then pcall(function() if FlareFinder and FlareFinder.start then FlareFinder.start() end end) end
        if trapIndex and stored[trapIndex] then pcall(function() if TrapsFinder and TrapsFinder.start then TrapsFinder.start() end end) end
        if supplyIndex and stored[supplyIndex] then pcall(function() if SupplyFinder and SupplyFinder.start then SupplyFinder.start() end end) end
    end

    pcall(startSelectedFindersIfNeeded)
    spawn(function() wait(0.5); pcall(startSelectedFindersIfNeeded) end)
    spawn(function() wait(1.2); pcall(startSelectedFindersIfNeeded) end)
end


-- ** Object Finder Logic Ends Here ** --

--------------------------------------------------------------------------

-- ** Rake Kill Aura Logic Starts Here ** --      

do
    local bindKeyName = GetConfig("player.rakeKillAuraKey", nil)
    local defaultKey = (type(bindKeyName) == "string" and Enum.KeyCode[bindKeyName]) or Enum.KeyCode.K
    local kbApi = KeybindAPI[kbFrame]
    if kbApi and type(kbApi.Set) == "function" then kbApi.Set(defaultKey) end

    local currentKey = (kbApi and type(kbApi.Get) == "function" and kbApi.Get()) or defaultKey
    if kbApi then
        kbApi.OnBind = function(k)
            if typeof(k) == "EnumItem" then
                currentKey = k
                pcall(function() SetConfig("player.rakeKillAuraKey", k.Name) end)
            end
        end
    end

    local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if not currentKey then return end
        if input.KeyCode == currentKey then
            local api = ToggleAPI[rakeKillAuraToggle]
            if api and type(api.Get) == "function" and type(api.Set) == "function" then
                local on = api.Get()
                pcall(function() api.Set(not on) end)
            end
        end
    end)

    RegisterUnload(function()
        pcall(function() if inputConn then inputConn:Disconnect() inputConn = nil end end)
    end)

    local killConn = nil
    local function startKillAuraLoop()
        if killConn then return end
        killConn = RunService.Heartbeat:Connect(function()
            local tApi = ToggleAPI[rakeKillAuraToggle]
            if not (tApi and type(tApi.Get) == "function" and tApi.Get()) then return end
            local rake = Workspace:FindFirstChild("Rake")
            if not rake then return end
            local hrp = rake:FindFirstChild("HumanoidRootPart")
            local myChar = player and player.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not hrp or not myHrp then return end
            if (hrp.Position - myHrp.Position).Magnitude < 200 then
                local stun = myChar and myChar:FindFirstChild("StunStick")
                local evt = stun and stun:FindFirstChild("Event")
                if evt and evt:IsA("RemoteEvent") then
                    pcall(function()
                        evt:FireServer("S")
                        task.wait(0.05)
                        evt:FireServer("H", hrp)
                    end)
                end
            end
        end)
    end

    local prevOn = ToggleAPI[rakeKillAuraToggle] and ToggleAPI[rakeKillAuraToggle].OnToggle
    ToggleAPI[rakeKillAuraToggle].OnToggle = function(state)
        if prevOn then pcall(prevOn, state) end
        pcall(function()
            if NOTIFICATIONS_ENABLED then
                if state then
                    makeNotification("Rake Kill Aura: ON", 3)
                else
                    makeNotification("Rake Kill Aura: OFF", 3)
                end
            end
        end)
        if state then
            startKillAuraLoop()
        else
            if killConn then killConn:Disconnect() killConn = nil end
        end
    end

    local tApi = ToggleAPI[rakeKillAuraToggle]
    if tApi and type(tApi.Get) == "function" and tApi.Get() then
        startKillAuraLoop()
    end

    RegisterUnload(function()
        pcall(function() if killConn then killConn:Disconnect() killConn = nil end end)
    end)
end

-- ** Rake Kill Aura Logic Ends Here ** --

--------------------------------------------------------------------------

-- ** Bring Scraps to Player Logic Starts Here ** --

do
    local btnFrame = bringScrapsButton
    if btnFrame and btnFrame.Parent then
        local textBtn = btnFrame:FindFirstChildOfClass("TextButton")
        if textBtn then
            textBtn.MouseButton1Click:Connect(function()
                local filter = Workspace:FindFirstChild("Filter")
                local scrapFolder = filter and filter:FindFirstChild("ScrapSpawns")
                local found = {}
                if scrapFolder then
                    for _,obj in ipairs(scrapFolder:GetDescendants()) do
                        if obj and obj:IsA("BasePart") then
                            if string.find(string.lower(obj.Name or ""), "scrap") then
                                table.insert(found, obj)
                            end
                        elseif obj and obj:IsA("Model") then
                            if string.find(string.lower(obj.Name or ""), "scrap") then
                                table.insert(found, obj)
                            end
                        end
                    end
                end

                if #found == 0 then
                    if NOTIFICATIONS_ENABLED ~= false then
                        pcall(function() makeNotification("No scraps to bring! Wait for more to spawn.", 3) end)
                    end
                    return
                end

                local lp = Players.LocalPlayer
                local char = lp and lp.Character
                if not (char and char.Parent) then return end
                local rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
                if not rootPart then return end
                local basePos = rootPart.Position + (rootPart.CFrame.LookVector * 3) - Vector3.new(0, 2, 0)

                for _,entry in ipairs(found) do
                    pcall(function()
                        if entry:IsA("Model") then
                            local primary = entry.PrimaryPart
                            if not primary then
                                for _,d in ipairs(entry:GetDescendants()) do
                                    if d:IsA("BasePart") then
                                        primary = d
                                        break
                                    end
                                end
                            end
                            if primary then
                                local target = CFrame.new(basePos + Vector3.new( math.random(-2,2), 0, math.random(-2,2) ))
                                if entry.PrimaryPart then
                                    entry:SetPrimaryPartCFrame(target)
                                else
                                    local offset = target.Position - primary.Position
                                    for _,p in ipairs(entry:GetDescendants()) do
                                        if p:IsA("BasePart") then
                                            p.CFrame = p.CFrame + offset
                                        end
                                    end
                                end
                            end
                        elseif entry:IsA("BasePart") then
                            entry.CFrame = CFrame.new(basePos + Vector3.new( math.random(-2,2), 0, math.random(-2,2) ))
                        end
                    end)
                end
            end)
        end
    end
end
-- ** Bring Scraps to Player Logic Ends Here ** --

--------------------------------------------------------------------------
-- ** Bypass Safe House Door Logic Starts Here ** --
do
    local toggleFrame = bypassSafeHouseDoorToggle
    local watcherConn

    local function findPrompt()
        local map = Workspace:FindFirstChild("Map")
        if not map then return nil end
        local sh = map:FindFirstChild("SafeHouse")
        if not sh then return nil end
        local door = sh:FindFirstChild("Door")
        if not door then return nil end
        local lever = door:FindFirstChild("DoorLever")
        if not lever then return nil end
        local guiPart = lever:FindFirstChild("DoorGUIPart")
        if not guiPart then return nil end
        for _,d in ipairs(guiPart:GetDescendants()) do
            if d and d:IsA("ProximityPrompt") then return d end
        end
        local direct = guiPart:FindFirstChildOfClass("ProximityPrompt") or guiPart:FindFirstChild("ProximityPrompt")
        return direct
    end

    local function findAllPrompts()
        local res = {}
        local map = Workspace:FindFirstChild("Map")
        if not map then return res end
        local sh = map:FindFirstChild("SafeHouse")
        if not sh then return res end
        local door = sh:FindFirstChild("Door")
        if not door then return res end
        local lever = door:FindFirstChild("DoorLever")
        if not lever then return res end
        local guiPart = lever:FindFirstChild("DoorGUIPart")
        if not guiPart then return res end
        for _,d in ipairs(guiPart:GetDescendants()) do
            if d and d:IsA("ProximityPrompt") then table.insert(res, d) end
        end
        local direct = guiPart:FindFirstChildOfClass("ProximityPrompt") or guiPart:FindFirstChild("ProximityPrompt")
        if direct then table.insert(res, direct) end
        return res
    end

    local function applyToPrompt(prompt, state)
        if not prompt then return end
        if state then
            pcall(function() prompt.RequiresLineOfSight = false end)
            pcall(function() prompt.RequireLineOfSight = false end)
            pcall(function() prompt.MaxActivationDistance = 25 end)
        else
            pcall(function() prompt.RequiresLineOfSight = true end)
            pcall(function() prompt.RequireLineOfSight = true end)
            pcall(function() prompt.MaxActivationDistance = 2.5 end)
        end
    end

    local function startWatcher()
        if watcherConn then return end
        watcherConn = Workspace.DescendantAdded:Connect(function(desc)
            if not desc then return end
            if desc:IsA("ProximityPrompt") then
                local guiAncestor = desc:FindFirstAncestor("DoorGUIPart")
                if guiAncestor then
                    applyToPrompt(desc, true)
                end
            end
        end)
    end

    local function stopWatcher()
        if watcherConn then
            pcall(function() watcherConn:Disconnect() end)
            watcherConn = nil
        end
    end

    local api = ToggleAPI[toggleFrame]
    if api then
        local prev = api.OnToggle
        api.OnToggle = function(s)
            if prev then pcall(prev, s) end
            if s then
                local prompt = findPrompt()
                if prompt then
                    applyToPrompt(prompt, true)
                else
                    startWatcher()
                end
            else
                stopWatcher()
                local prompts = findAllPrompts()
                for _,pr in ipairs(prompts) do applyToPrompt(pr, false) end
            end
        end
        pcall(function() api.Set(api.Get()) end)
    end

    
    -------------------- Break for Unload --------------------
    if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
        _G.TemptUI.RegisterUnload(function()
            stopWatcher()
            local prompt = findPrompt()
            if prompt then applyToPrompt(prompt, false) end
        end)
    end
end
-- ** Bypass Safe House Door Logic Ends Here ** --
--------------------------------------------------------------------------

-- ** Game Timer Display Logic Starts Here ** --
do
    local apiFrame = gameTimerToggle
    local RS = RunService
    local turningToDayVal = RepStorage:FindFirstChild("TurningToDay")
    local nightVal = RepStorage:FindFirstChild("Night")
    local timerVal = RepStorage:FindFirstChild("Timer")

    local guiRef = nil
    local renderConn = nil

    local function fmtTime(t)
        t = math.max(0, math.floor(t))
        if t <= 1 then return "Switching..." end
        local m = math.floor(t / 60)
        local s = t % 60
        return string.format("%d:%02d", m, s)
    end

    local function createUI()
        if guiRef and guiRef.ScreenGui and guiRef.ScreenGui.Parent then return end
        local playerGui = player and player:FindFirstChild("PlayerGui")
        local screen = Instance.new("ScreenGui")
        screen.Name = "Tempt_GameTimer"
        screen.ResetOnSpawn = false
        screen.Parent = playerGui or game:GetService("CoreGui")
        pcall(function() screen.DisplayOrder = 900 end)

        local root = Instance.new("Frame")
        root.Size = UDim2.new(0, 220, 0, 84)
        root.Position = UDim2.new(1, -240, 0, 140) -- ** Below rake meter?
        root.AnchorPoint = Vector2.new(0,0)
        root.BackgroundColor3 = COLORS.panel
        root.Parent = screen
        local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,6) corner.Parent = root

        local header = Instance.new("Frame") header.Size = UDim2.new(1,0,0,28) header.BackgroundColor3 = COLORS.bg header.Parent = root
        local hcorner = Instance.new("UICorner") hcorner.CornerRadius = UDim.new(0,6) hcorner.Parent = header
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -36, 1, 0)
        title.Position = UDim2.new(0, 8, 0, 0)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextColor3 = COLORS.text
        title.Text = "Day/Night Timer"
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = header

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 20, 0, 20)
        closeBtn.Position = UDim2.new(1, -28, 0, 4)
        closeBtn.AnchorPoint = Vector2.new(0,0)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.Text = "X"
        closeBtn.TextColor3 = COLORS.text
        closeBtn.Parent = header
        closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = COLORS.text end)
        closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = COLORS.text end)
        closeBtn.MouseButton1Click:Connect(function()
            local api = ToggleAPI[apiFrame]
            if api and type(api.Set) == "function" then pcall(function() api.Set(false) end) end
        end)

        local body = Instance.new("Frame") body.Size = UDim2.new(1,0,1,-28) body.Position = UDim2.new(0,0,0,28) body.BackgroundTransparency = 1 body.Parent = root

        local stateLabel = Instance.new("TextLabel") stateLabel.Size = UDim2.new(1, -12, 0, 20) stateLabel.Position = UDim2.new(0, 8, 0, 6) stateLabel.BackgroundTransparency = 1 stateLabel.Font = Enum.Font.GothamBold stateLabel.TextSize = 13 stateLabel.TextColor3 = COLORS.textDim stateLabel.Text = "State: --" stateLabel.TextXAlignment = Enum.TextXAlignment.Left stateLabel.Parent = body

        local timerLabel = Instance.new("TextLabel") timerLabel.Size = UDim2.new(1, -12, 0, 30) timerLabel.Position = UDim2.new(0, 8, 0, 30) timerLabel.BackgroundTransparency = 1 timerLabel.Font = Enum.Font.GothamBold timerLabel.TextSize = 16 timerLabel.TextColor3 = COLORS.text timerLabel.Text = "--:--" timerLabel.TextXAlignment = Enum.TextXAlignment.Center timerLabel.Parent = body

        -- * drag thing
        header.Active = true
        local dragging, dragStart, startPos = false, nil, nil
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = root.Position
            end
        end)
        header.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
                local delta = input.Position - dragStart
                root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        guiRef = { ScreenGui = screen, Root = root, State = stateLabel, Timer = timerLabel }
    end

    local function destroyUI()
        if renderConn then renderConn:Disconnect() renderConn = nil end
        if guiRef and guiRef.ScreenGui and guiRef.ScreenGui.Parent then pcall(function() guiRef.ScreenGui:Destroy() end) end
        guiRef = nil
    end

    local function updateOnce()
        if not guiRef then return end
        local t = (timerVal and timerVal.Value) or 0
        local night = (nightVal and nightVal.Value) or false
        local stateText = night and "Night" or "Day"
        guiRef.State.Text = "State: " .. stateText
        local nextText = ""
        if night then
            nextText = "Turns to Day in " .. fmtTime(t)
        else
            nextText = "Turns to Night in " .. fmtTime(t)
        end
        guiRef.Timer.Text = nextText
    end

    local function start()
        if renderConn then return end
        createUI()
        renderConn = RS.RenderStepped:Connect(function()
            pcall(updateOnce)
        end)
    end

    local function stop()
        destroyUI()
    end

    local api = ToggleAPI[apiFrame]
    if api then
        local prev = api.OnToggle
        api.OnToggle = function(s)
            if prev then pcall(prev, s) end
            if s then pcall(start) else pcall(stop) end
        end
        pcall(function() api.Set(api.Get()) end)
    end

    -------------------- Break for Unload --------------------
    if _G and _G.TemptUI and type(_G.TemptUI.RegisterUnload) == "function" then
        _G.TemptUI.RegisterUnload(function() pcall(stop) end)
    end
end
-- ** Game Timer Display Logic Ends Here ** --


-- ────────────────────────────────────────────────────────────────────

-- ** The Very End of Tempt.lua ** --

-- "Like a wise man once said, if I can see it, I can hook it." - Some guy lol

-- ────────────────────────────────────────────────────────────────
