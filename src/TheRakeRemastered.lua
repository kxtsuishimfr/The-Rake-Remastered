-- Unauthorized sale, redistribution, or removal of attribution from this script
-- constitutes a violation of the applicable license and may result in legal action,
-- including but not limited to DMCA takedown requests. Review the license terms
-- prior to any form of redistribution.
-- READ THE GOD DAMN LICENSE

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Light = game:GetService("Lighting")

function dofullbright()
	Light.Ambient = Color3.new(1, 1, 1)
	Light.ColorShift_Bottom = Color3.new(1, 1, 1)
	Light.ColorShift_Top = Color3.new(1, 1, 1)
end

local _dofullbright_conn = nil
local function enableImprovedLighting()
	if IMPROVED_LIGHTING_ENABLED then return end
	IMPROVED_LIGHTING_ENABLED = true
	pcall(function()
		_prevAmbient = Light.Ambient
		_prevOutdoorAmbient = Light.OutdoorAmbient
		_prevBrightness = Light.Brightness
		_prevGlobalShadows = Light.GlobalShadows
	end)
	dofullbright()
	if not _dofullbright_conn then
		_dofullbright_conn = Light.LightingChanged:Connect(dofullbright)
	end
end

local function disableImprovedLighting()
	if not IMPROVED_LIGHTING_ENABLED then return end
	IMPROVED_LIGHTING_ENABLED = false
	if _dofullbright_conn then
		_dofullbright_conn:Disconnect()
		_dofullbright_conn = nil
	end
	pcall(function()
		if _prevAmbient then Light.Ambient = _prevAmbient end
		if _prevOutdoorAmbient then Light.OutdoorAmbient = _prevOutdoorAmbient end
		if _prevBrightness then Light.Brightness = _prevBrightness end
		if _prevGlobalShadows ~= nil then Light.GlobalShadows = _prevGlobalShadows end
		_prevAmbient = nil
		_prevOutdoorAmbient = nil
		_prevBrightness = nil
		_prevGlobalShadows = nil
	end)
end

local IMPROVED_LIGHTS = {}
local IMPROVED_LIGHTING_ENABLED = false
local _prevOutdoorAmbient = nil
local _prevAmbient = nil
local _prevBrightness = nil
local _prevGlobalShadows = nil
local RAKE_METER = {
	enabled = false,
	conn = nil,
	hudGui = nil,
	label = nil,
	cachedRake = nil,
	lastRakeCheck = 0,
	useBeam = false,
}

local function findRakeModel()
	-- 1) Prefer models already tagged by ESP
	for _, m in ipairs(Workspace:GetDescendants()) do
		if m and m:IsA("Model") then
			local tag = m:FindFirstChild("ESP_Category")
			if tag and tag:IsA("StringValue") and tag.Value == "rake" then
				return m
			end
		end
	end

	-- 2) Fall back to model name containing 'rake'
	for _, inst in ipairs(Workspace:GetDescendants()) do
		if inst and inst:IsA("Model") then
			local ok, iname = pcall(function() return tostring(inst.Name) end)
			if ok and iname and iname:lower():find("rake") then
				return inst
			end
		end
	end

	-- 3) As a last resort, find any model that has a descendant part/name containing 'rake'
	for _, inst in ipairs(Workspace:GetDescendants()) do
		if inst and inst:IsA("Model") then
			for _, d in ipairs(inst:GetDescendants()) do
				local ok, dname = pcall(function() return tostring(d.Name) end)
				if ok and dname and dname:lower():find("rake") then
					return inst
				end
			end
		end
	end

	return nil
end

-- Cached getter to avoid expensive workspace scans every frame
local function getCachedRake(throttle)
	throttle = throttle or 0.25
	local now = tick()
	-- return cached if still valid
	if RAKE_METER.cachedRake and RAKE_METER.cachedRake.Parent then
		return RAKE_METER.cachedRake
	end
	-- throttle repeated searches
	if now - (RAKE_METER.lastRakeCheck or 0) < throttle then
		return nil
	end
	RAKE_METER.lastRakeCheck = now
	local r = findRakeModel()
	RAKE_METER.cachedRake = r
	return r
end

local function formatFriendly(dist)
	if dist < 8 then
		return "Very Close"
	elseif dist < 25 then
		return "Close"
	elseif dist < 80 then
		return "Nearby"
	else
		return "Far"
	end
end

-- Simple optimized proximity GUI and updater (replaces complex beam/hud parts)
local function createRakeProximityGui()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	-- destroy any existing instance to avoid duplicates
	local existing = playerGui:FindFirstChild("RakeProximityGui")
	if existing then existing:Destroy() end

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
	frame.Active = true
	local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,8) corner.Parent = frame

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Parent = frame
	statusLabel.Size = UDim2.new(1, 0, 1, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Initializing..."
	statusLabel.TextColor3 = Color3.new(1,1,1)
	statusLabel.TextScaled = true
	statusLabel.Font = Enum.Font.SourceSansBold

	-- draggable
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
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	RAKE_METER.hudGui = screenGui
	RAKE_METER.label = statusLabel
end

local function destroyRakeProximityGui()
	pcall(function()
		if RAKE_METER.hudGui then RAKE_METER.hudGui:Destroy() end
	end)
	RAKE_METER.hudGui = nil
	RAKE_METER.label = nil
end

local function enableRakeMeter(screen)
	if RAKE_METER.conn then return end
	RAKE_METER.enabled = true
	createRakeProximityGui()

	RAKE_METER.conn = RunService.Heartbeat:Connect(function()
		pcall(function()
			local char = LocalPlayer and LocalPlayer.Character
			local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
			if not hrp then
				if RAKE_METER.label then RAKE_METER.label.Text = "Rake: no character" RAKE_METER.label.TextColor3 = Color3.fromRGB(128,128,128) end
				return
			end

			local rake = getCachedRake(0.25) or findRakeModel()
			if not rake then
				if RAKE_METER.label then RAKE_METER.label.Text = "Rake Not Found" RAKE_METER.label.TextColor3 = Color3.fromRGB(128,128,128) end
				return
			end

			local rakeRoot = rake:FindFirstChild("HumanoidRootPart") or rake.PrimaryPart or rake:FindFirstChildWhichIsA("BasePart")
			if not rakeRoot then return end
			local dist = (rakeRoot.Position - hrp.Position).Magnitude

			-- status and color mapping (kept similar to original formatting)
			local status, color
			if dist <= 50 then
				status = "VERY CLOSE"
				color = Color3.new(1,0,0)
			elseif dist <= 150 then
				status = "CLOSE"
				color = Color3.new(1,0.5,0)
			elseif dist <= 300 then
				status = "FAR"
				color = Color3.new(1,1,0)
			else
				status = "SAFE"
				color = Color3.new(0,1,0)
			end

			if RAKE_METER.label then
				RAKE_METER.label.Text = string.format("%s — %.1fm", status, dist)
				RAKE_METER.label.TextColor3 = color
			end
		end)
	end)
end

local function disableRakeMeter()
	RAKE_METER.enabled = false
	if RAKE_METER.conn then
		RAKE_METER.conn:Disconnect()
		RAKE_METER.conn = nil
	end
	destroyRakeProximityGui()
end

-- Player handling
-- ESP settings
local ESP_SETTINGS = {
	showRake = true,
	showPlayers = true,
	showNPCs = true,
}

local function createESP(model)
	if not model then return end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not root then return end

	local player = Players:GetPlayerFromCharacter(model)
	if player == LocalPlayer then
		local h = model:FindFirstChild("ESP_Highlight")
		if h then h:Destroy() end
		local ng = model:FindFirstChild("ESP_Name")
		if ng then ng:Destroy() end
		local cat = model:FindFirstChild("ESP_Category")
		if cat then cat:Destroy() end
		return
	end

	local lname = (model.Name or ""):lower()
	local isRake = lname:find("rake") ~= nil
	local isNPC = (humanoid ~= nil) and (player == nil)

	if player and not ESP_SETTINGS.showPlayers then return end
	if isRake and not ESP_SETTINGS.showRake then return end
	if isNPC and not ESP_SETTINGS.showNPCs then return end

	local desiredCat = player and "player" or (isRake and "rake" or "npc")

	local existingHighlight = model:FindFirstChild("ESP_Highlight")
	local existingCat = model:FindFirstChild("ESP_Category") and model:FindFirstChild("ESP_Category").Value
	if existingHighlight then
		if existingCat == desiredCat then
			return
		else
			existingHighlight:Destroy()
			local ev = model:FindFirstChild("ESP_Name")
			if ev then ev:Destroy() end
			local ec = model:FindFirstChild("ESP_Category")
			if ec then ec:Destroy() end
		end
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight"
	highlight.Parent = model
	highlight.FillTransparency = 0.75
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	if player then
		highlight.FillColor = Color3.fromRGB(60, 160, 255)
	elseif isRake then
		highlight.FillColor = Color3.fromRGB(255, 60, 60)
	else
		highlight.FillColor = Color3.fromRGB(255, 165, 60)
	end
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP_Name"
	billboard.Parent = model
	billboard.Adornee = root
	billboard.Size = UDim2.fromScale(4, 1)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true

	local text = Instance.new("TextLabel")
	text.Parent = billboard
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.TextStrokeTransparency = 0
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.Text = player and player.Name or model.Name

	local catTag = Instance.new("StringValue")
	catTag.Name = "ESP_Category"
	catTag.Value = desiredCat
	catTag.Parent = model
end

local function refreshAllHighlights()
	for _, obj in pairs(Workspace:GetChildren()) do
		if obj and obj:IsA("Model") then
			local humanoid = obj:FindFirstChildOfClass("Humanoid")
			local player = Players:GetPlayerFromCharacter(obj)
			if player == LocalPlayer then
				local h = obj:FindFirstChild("ESP_Highlight")
				if h then h:Destroy() end
			else
				local lname = (obj.Name or ""):lower()
				local isRake = lname:find("rake") ~= nil
				local isNPC = humanoid and (player == nil)

				local shouldHave = (player ~= nil and ESP_SETTINGS.showPlayers) or (isRake and ESP_SETTINGS.showRake) or (isNPC and ESP_SETTINGS.showNPCs)

				local existing = obj:FindFirstChild("ESP_Highlight")
				if shouldHave and not existing then
					pcall(function() createESP(obj) end)
				elseif (not shouldHave) and existing then
					existing:Destroy()
					local nameGui = obj:FindFirstChild("ESP_Name")
					if nameGui then nameGui:Destroy() end
					local cat = obj:FindFirstChild("ESP_Category")
					if cat then cat:Destroy() end
				end
			end
		end
	end
end
-- Building highlight settings (persisted)
local BUILDING_SETTINGS = {
	["Tower"] = false,
	["Base Camp"] = false,
	["Safe House"] = false,
	["Shop"] = false,
	["Power Station"] = false,
}

-- Location marker system
local LOCATIONS = {
	{ name = "Power Station", pos = Vector3.new(-295.83, 20.00, -201.65) },
	{ name = "Safe House",    pos = Vector3.new(-363.56, 16.48, 74.48) },
	{ name = "Shop",          pos = Vector3.new(-24.29, 16.24, -254.70) },
	{ name = "Tower",         pos = Vector3.new(64.43, 13.49, -55.44) },
	{ name = "Base Camp",     pos = Vector3.new(-43.67, 17.61, 202.36) },
}

local LOCATION_MARKERS = {}
local locationUpdateConn = nil
local LOCATION_SETTINGS = {}
for _, l in ipairs(LOCATIONS) do
	LOCATION_SETTINGS[l.name] = true
end

local function createLocationMarkerUI(screen, loc)
	if not screen or not loc then return end
	local container = Instance.new("Frame")
	container.Name = ("Loc_%s"):format(loc.name:gsub("%s+",""))
	container.Size = UDim2.new(0, 200, 0, 48)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = false
	container.Parent = screen

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 0, 24)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 0.4
	label.BackgroundColor3 = Color3.fromRGB(30,30,30)
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.GothamBold
	label.Text = loc.name
	label.TextSize = 14
	label.TextWrapped = true
	label.Parent = container

	local shape = Instance.new("Frame")
	shape.Name = "Dot"
	shape.Size = UDim2.new(0, 12, 0, 12)
	shape.Position = UDim2.new(0.5, -6, 0, 30)
	shape.AnchorPoint = Vector2.new(0.5, 0)
	shape.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = shape
	shape.Parent = container

	return { container = container, label = label, shape = shape }
end

local function updateLocationMarkers(screen)
	if not screen then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local maxDist = 2000
	for _, loc in ipairs(LOCATIONS) do
		local entry = LOCATION_MARKERS[loc.name]
		if LOCATION_SETTINGS[loc.name] == false then
			if entry and entry.container then
				entry.container.Visible = false
			end
		else
			if not entry then
				entry = createLocationMarkerUI(screen, loc)
				LOCATION_MARKERS[loc.name] = entry
			end
			if entry then
				local worldPos = loc.pos
				local viewportPoint = cam:WorldToViewportPoint(worldPos)
				local onScreen = viewportPoint.Z > 0
				local screenX, screenY = viewportPoint.X, viewportPoint.Y
				local dist = (cam.CFrame.Position - worldPos).Magnitude
				local visible = onScreen and dist < maxDist
				entry.container.Visible = visible
				if visible then
					entry.container.Position = UDim2.fromOffset(math.floor(screenX - (entry.container.Size.X.Offset/2)), math.floor(screenY - 24))
					local scale = math.clamp(1.5 - (dist / 200), 0.6, 2.2)
					entry.label.TextSize = math.clamp(14 * scale, 10, 36)
					local dotSize = math.clamp(math.floor(12 * (1.2 - (dist / 800))), 6, 20)
					entry.shape.Size = UDim2.new(0, dotSize, 0, dotSize)
					entry.shape.Position = UDim2.new(0.5, -dotSize/2, 0, 30)
				end
			end
		end
	end
end

local function enableLocationMarkers(screen)
	if locationUpdateConn then return end
	for _, loc in ipairs(LOCATIONS) do
		local entry = LOCATION_MARKERS[loc.name]
		if not entry then
			entry = {}
			LOCATION_MARKERS[loc.name] = entry
		end
		if not entry.worldPart then
			local part = Instance.new("Part")
			part.Name = ("LocPart_%s"):format(loc.name:gsub("%s+",""))
			part.Size = Vector3.new(0.6, 0.6, 0.6)
			part.Position = loc.pos
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 0
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(80, 255, 120)
			part.Parent = Workspace

			local bp = Instance.new("BillboardGui")
			bp.Size = UDim2.new(0, 120, 0, 28)
			bp.Adornee = part
			bp.AlwaysOnTop = true
			bp.StudsOffset = Vector3.new(0, 1.2, 0)
			bp.Parent = part

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, 0, 1, 0)
			lbl.BackgroundTransparency = 0.4
			lbl.BackgroundColor3 = Color3.fromRGB(30,30,30)
			lbl.TextColor3 = Color3.fromRGB(255,255,255)
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.Text = loc.name
			lbl.Parent = bp

			entry.worldPart = part
		end
	end

	locationUpdateConn = RunService.RenderStepped:Connect(function()
		pcall(function() updateLocationMarkers(screen) end)
		for _, loc in ipairs(LOCATIONS) do
			local e = LOCATION_MARKERS[loc.name]
			if e and e.worldPart then
				local enabled = (LOCATION_SETTINGS[loc.name] ~= false)
				e.worldPart.Position = loc.pos
				e.worldPart.Transparency = enabled and 0 or 1
				-- ensure attached BillboardGui / label are shown/hidden as well
				pcall(function()
					local bp = e.worldPart:FindFirstChildOfClass("BillboardGui")
					if bp then
						pcall(function() bp.Enabled = enabled end)
						local lbl = bp:FindFirstChildWhichIsA("TextLabel")
						if lbl then
							lbl.Visible = enabled
						end
					end
				end)
			end
		end
	end)
end

local function disableLocationMarkers()
	if locationUpdateConn then
		locationUpdateConn:Disconnect()
		locationUpdateConn = nil
	end
	for _, entry in pairs(LOCATION_MARKERS) do
		pcall(function()
			if entry.container then entry.container:Destroy() end
			if entry.worldPart then entry.worldPart:Destroy() end
		end)
	end
	LOCATION_MARKERS = {}
end

local function onPlayer(player)
	if player == LocalPlayer then return end
	player.CharacterAdded:Connect(function(char)
		task.wait(0.2)
		if char then
			local h = char:FindFirstChild("ESP_Highlight")
			if h then h:Destroy() end
			local nameGui = char:FindFirstChild("ESP_Name")
			if nameGui then nameGui:Destroy() end
			local cat = char:FindFirstChild("ESP_Category")
			if cat then cat:Destroy() end
		end
		createESP(char)
	end)
	if player.Character then
		local char = player.Character
		local h = char:FindFirstChild("ESP_Highlight")
		if h then h:Destroy() end
		local nameGui = char:FindFirstChild("ESP_Name")
		if nameGui then nameGui:Destroy() end
		local cat = char:FindFirstChild("ESP_Category")
		if cat then cat:Destroy() end
		createESP(player.Character)
	end
end

for _, player in pairs(Players:GetPlayers()) do
	onPlayer(player)
end
Players.PlayerAdded:Connect(onPlayer)

-- Global NPC highlighting
local function isPlayerCharacter(model)
	return Players:GetPlayerFromCharacter(model) ~= nil
end

local function onModelAdded(model)
	if not model or not model:IsA("Model") then return end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		task.spawn(function()
			task.wait(0.2)
			if not isPlayerCharacter(model) then
				createESP(model)
			else
				local player = Players:GetPlayerFromCharacter(model)
				if player and player ~= LocalPlayer then
					local h = model:FindFirstChild("ESP_Highlight")
					if h then h:Destroy() end
					local ng = model:FindFirstChild("ESP_Name")
					if ng then ng:Destroy() end
					local cat = model:FindFirstChild("ESP_Category")
					if cat then cat:Destroy() end
					createESP(model)
				end
			end
		end)
	end
end
Workspace.ChildAdded:Connect(onModelAdded)
for _, child in pairs(Workspace:GetChildren()) do
	onModelAdded(child)
end

-- Also watch descendants so models/humanoids added deep in the hierarchy are caught
Workspace.DescendantAdded:Connect(function(desc)
	if not desc then return end
	-- if a Humanoid appears, try to ESP its model parent
	if desc:IsA("Humanoid") and desc.Parent and desc.Parent:IsA("Model") then
		task.defer(function()
			if not isPlayerCharacter(desc.Parent) then
				pcall(function() createESP(desc.Parent) end)
			else
				local player = Players:GetPlayerFromCharacter(desc.Parent)
				if player and player ~= LocalPlayer then
					pcall(function()
						local h = desc.Parent:FindFirstChild("ESP_Highlight")
						if h then h:Destroy() end
						local ng = desc.Parent:FindFirstChild("ESP_Name")
						if ng then ng:Destroy() end
						local cat = desc.Parent:FindFirstChild("ESP_Category")
						if cat then cat:Destroy() end
						createESP(desc.Parent)
					end)
				end
			end
		end)
	elseif desc:IsA("Model") then
		task.defer(function() pcall(function() onModelAdded(desc) end) end)
	end
end)

Workspace.DescendantRemoving:Connect(function(desc)
	if not desc then return end
	local model = nil
	if desc:IsA("Model") then
		model = desc
	elseif desc:IsA("Humanoid") and desc.Parent and desc.Parent:IsA("Model") then
		model = desc.Parent
	end
	if model then
		local h = model:FindFirstChild("ESP_Highlight")
		if h then h:Destroy() end
		local ng = model:FindFirstChild("ESP_Name")
		if ng then ng:Destroy() end
		local cat = model:FindFirstChild("ESP_Category")
		if cat then cat:Destroy() end
	end
end)

-- GUI START
local function createESPGui()
	if not LocalPlayer then
		warn("RakeRemastered: LocalPlayer nil — GUI requires a LocalScript (StarterPlayerScripts).")
		return
	end

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local screen = Instance.new("ScreenGui")
	screen.Name = "RakeRemasteredUI"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.IgnoreGuiInset = true
	screen.Parent = playerGui

	SCREEN_GUI = screen

	local SETTINGS_FILE = "rake_settings.json"

	local loadedSettings = nil

	-- Persist settings (try writefile/readfile, fallback to Player attributes)
	local function saveSettings(settings)
		local data = settings or {
			esp = ESP_SETTINGS,
			fov = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70,
			pov = LocalPlayer:GetAttribute("Rake_POV") or "Default",
			playerSpeed = LocalPlayer:GetAttribute("Rake_PlayerSpeed") or 16,
			playerSpeedEnabled = LocalPlayer:GetAttribute("Rake_PlayerSpeedEnabled") or false,
			buildingSettings = BUILDING_SETTINGS,
            locationSettings = LOCATION_SETTINGS,
			rakeMeterEnabled = RAKE_METER.enabled or false,
			useBeamMeter = RAKE_METER.useBeam or false,
			improvedLighting = IMPROVED_LIGHTING_ENABLED or false,
			-- improvedLightingIntensity removed
		}
		local encoded = HttpService:JSONEncode(data)
		local ok, err = pcall(function()
			if writefile then
				writefile(SETTINGS_FILE, encoded)
			end
		end)
		-- always set attribute fallback
		pcall(function()
			LocalPlayer:SetAttribute("RakeSettings", encoded)
		end)
	end

	local function loadSettings()
		local loaded = nil
		local ok = false
		pcall(function()
			if isfile and isfile(SETTINGS_FILE) then
				local txt = readfile(SETTINGS_FILE)
				loaded = HttpService:JSONDecode(txt)
				ok = true
			end
		end)
		if not ok then
			-- try attribute fallback
			pcall(function()
				local attr = LocalPlayer:GetAttribute("RakeSettings")
				if attr then
					loaded = HttpService:JSONDecode(attr)
				end
			end)
		end
		return loaded
	end

	local DEFAULT_WALK_SPEED = 16
	local playerSpeed = LocalPlayer:GetAttribute("Rake_PlayerSpeed") or DEFAULT_WALK_SPEED
	local playerSpeedEnabled = LocalPlayer:GetAttribute("Rake_PlayerSpeedEnabled") or false

	local RunService = game:GetService("RunService")

	-- Speed enforcement connections
	local speedEnforceHumConn = nil
	local speedEnforceHeartbeat = nil
	local speedEnforceRenderConn = nil
	local function stopSpeedEnforce()
		if speedEnforceHumConn then
			speedEnforceHumConn:Disconnect()
			speedEnforceHumConn = nil
		end
		if speedEnforceHeartbeat then
			speedEnforceHeartbeat:Disconnect()
			speedEnforceHeartbeat = nil
		end
		if speedEnforceRenderConn then
			speedEnforceRenderConn:Disconnect()
			speedEnforceRenderConn = nil
		end
	end

	local function enforceHumanoid(hum)
		stopSpeedEnforce()
		if not hum then return end
		-- immediately set
		pcall(function() hum.WalkSpeed = playerSpeed end)
		-- reapply if something else changes it
		speedEnforceHumConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if not hum or not hum.Parent then
				stopSpeedEnforce()
				return
			end
			if hum.WalkSpeed ~= playerSpeed then
				pcall(function() hum.WalkSpeed = playerSpeed end)
			end
		end)
		-- heartbeat backup: set every frame in case other systems override frequently
		speedEnforceHeartbeat = RunService.Heartbeat:Connect(function(dt)
			if not hum or not hum.Parent then
				stopSpeedEnforce()
				return
			end
			-- ensure WalkSpeed
			if hum.WalkSpeed ~= playerSpeed then
				pcall(function() hum.WalkSpeed = playerSpeed end)
			end
			-- try to maintain movement velocity to avoid server rectification
			local hrp = hum.Parent:FindFirstChild("HumanoidRootPart")
			if hrp then
				local moveDir = hum.MoveDirection or Vector3.new(0,0,0)
				if moveDir.Magnitude > 0.001 then
					local desiredVel = moveDir.Unit * playerSpeed
					-- set assembly velocity to desired (preserve vertical velocity)
					pcall(function()
						local av = hrp.AssemblyLinearVelocity
						hrp.AssemblyLinearVelocity = Vector3.new(desiredVel.X, av.Y, desiredVel.Z)
					end)
					-- simple prediction and correction for large rollback
					local predicted = hrp.Position + desiredVel * math.clamp(dt, 0, 0.1)
					local rollbackDist = (hrp.Position - predicted).Magnitude
					if rollbackDist > 2 then
						pcall(function()
							hrp.CFrame = CFrame.new(predicted, predicted + hrp.CFrame.LookVector)
						end)
					end
				else
					-- stationary: reduce horizontal velocity
					pcall(function()
						local av = hrp.AssemblyLinearVelocity
						if av then
							hrp.AssemblyLinearVelocity = Vector3.new(0, av.Y, 0)
						end
					end)
				end
			end
		end)

		-- stronger enforcement on RenderStepped to try to avoid quick server rectification
		speedEnforceRenderConn = RunService.RenderStepped:Connect(function(dt)
			if not hum or not hum.Parent then
				stopSpeedEnforce()
				return
			end
			local hrp = hum.Parent:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			local moveDir = hum.MoveDirection or Vector3.new(0,0,0)
			if moveDir.Magnitude > 0.001 then
				local desiredVel = moveDir.Unit * playerSpeed
				pcall(function()
					local av = hrp.AssemblyLinearVelocity
					hrp.AssemblyLinearVelocity = Vector3.new(desiredVel.X, av and av.Y or 0, desiredVel.Z)
				end)
				-- immediate small-step teleport toward predicted position to fight rectification
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


	local cameraLoopConn, mouseConn = nil, nil
	local shiftConnB, shiftConnE = nil, nil
	local shiftLockActive = false
	local prevAutoRotate = nil
	local function stopCameraLoop()
		if cameraLoopConn then
			cameraLoopConn:Disconnect()
			cameraLoopConn = nil
		end
		if mouseConn then
			mouseConn:Disconnect()
			mouseConn = nil
		end
		if shiftConnB then
			shiftConnB:Disconnect()
			shiftConnB = nil
		end
		if shiftConnE then
			shiftConnE:Disconnect()
			shiftConnE = nil
		end
		shiftLockActive = false
		prevAutoRotate = nil
		pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
	end

	local lastHumanoid = nil
	local lastHumanoidOffset = nil
	local function restoreHumanoidOffset()
		if lastHumanoid and lastHumanoid.Parent and lastHumanoid:IsA("Humanoid") then
			pcall(function()
				local target = lastHumanoidOffset or Vector3.new(0,0,0)
				local ok, tween = pcall(function()
					return TweenService:Create(lastHumanoid, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CameraOffset = target})
				end)
				if ok and tween then pcall(function() tween:Play() end) end
			end)
		end
		lastHumanoid = nil
		lastHumanoidOffset = nil
	end

	local function applyPOV(opt)
		if not opt then return end
		pcall(function() LocalPlayer:SetAttribute("Rake_POV", opt) end)
		stopCameraLoop()

		local cam = workspace.CurrentCamera
		if not cam then return end

		local char = LocalPlayer.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")

		if opt == "Third" then
			pcall(function() LocalPlayer.CameraMode = Enum.CameraMode.Classic end)
			cam.CameraType = Enum.CameraType.Scriptable
			restoreHumanoidOffset()

			local yaw = 0
			local pitch = 0
			local sensitivity = 0.12
			local distance = 6
			local height = 2.5

			mouseConn = UserInputService.InputChanged:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseMovement then
					yaw = yaw - inp.Delta.X * sensitivity
					pitch = math.clamp(pitch - inp.Delta.Y * sensitivity, -60, 60)
				end
			end)

			shiftConnB = UserInputService.InputBegan:Connect(function(input, gproc)
				if gproc then return end
				if input.KeyCode == Enum.KeyCode.LeftShift then
					shiftLockActive = true
					local ch = LocalPlayer.Character
					local hum = ch and ch:FindFirstChildOfClass("Humanoid")
					if hum then
						prevAutoRotate = hum.AutoRotate
						pcall(function() hum.AutoRotate = false end)
					end
					pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter end)
				end
			end)
			shiftConnE = UserInputService.InputEnded:Connect(function(input, gproc)
				if gproc then return end
				if input.KeyCode == Enum.KeyCode.LeftShift then
					shiftLockActive = false
					local ch = LocalPlayer.Character
					local hum = ch and ch:FindFirstChildOfClass("Humanoid")
					if hum and prevAutoRotate ~= nil then
						pcall(function() hum.AutoRotate = prevAutoRotate end)
					end
					prevAutoRotate = nil
					pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
				end
			end)

			cameraLoopConn = RunService.RenderStepped:Connect(function()
				local ch = LocalPlayer.Character
				if not ch or not ch:FindFirstChild("HumanoidRootPart") then return end
				local hrp = ch.HumanoidRootPart
				local target = hrp.Position + Vector3.new(0, height, 0)

				local baseDir = -hrp.CFrame.LookVector
				local baseOffset = baseDir * distance
				local rotated = (CFrame.Angles(0, math.rad(yaw), 0) * baseOffset)
				local camPos = target + rotated + Vector3.new(0, pitch * 0.03, 0)
				cam.CFrame = CFrame.new(camPos, target + Vector3.new(0, pitch * 0.03, 0))

				local look = (cam.CFrame.LookVector)
				local lookH = Vector3.new(look.X, 0, look.Z)
				if lookH.Magnitude > 0.001 then
					local desired = CFrame.new(hrp.Position, hrp.Position + lookH)
					if shiftLockActive then
						hrp.CFrame = desired
					else
						hrp.CFrame = hrp.CFrame:Lerp(desired, 0.15)
					end
				end
			end)

		else
			pcall(function() LocalPlayer.CameraMode = Enum.CameraMode.Classic end)
			cam.CameraType = Enum.CameraType.Custom
			if humanoid then
				cam.CameraSubject = humanoid
			end
			restoreHumanoidOffset()
		end
	end

	-- Load saved settings
	do
		local s = loadSettings()
		loadedSettings = s
		if s then
			if s.esp then
				ESP_SETTINGS = s.esp
			end
			if s.fov and workspace.CurrentCamera then
				pcall(function() workspace.CurrentCamera.FieldOfView = s.fov end)
			end
			if s.pov then
				pcall(function() LocalPlayer:SetAttribute("Rake_POV", s.pov) end)
			end
			if s.playerSpeed then
				playerSpeed = s.playerSpeed
				pcall(function() LocalPlayer:SetAttribute("Rake_PlayerSpeed", s.playerSpeed) end)
			end
			if s.buildingSettings then
				for k,v in pairs(s.buildingSettings) do
					BUILDING_SETTINGS[k] = v
				end
			end
				if s.rakeMeterEnabled then
					-- start rake meter after UI created
					RAKE_METER.enabled = s.rakeMeterEnabled
				end
				if s.useBeamMeter ~= nil then
					RAKE_METER.useBeam = s.useBeamMeter
				end
				if s.improvedLighting ~= nil then
					IMPROVED_LIGHTING_ENABLED = s.improvedLighting
				end
				-- improvedLightingIntensity removed from config
			if s.locationSettings then
				for k,v in pairs(s.locationSettings) do
					LOCATION_SETTINGS[k] = v
				end
			end
		end
	end

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 900, 0, 600)
	mainFrame.Position = UDim2.new(0.5, -450, 0.06, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
	mainFrame.BackgroundTransparency = 0.06
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screen

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 10)
	mainCorner.Parent = mainFrame

	local mainGrad = Instance.new("UIGradient")
	mainGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(245,245,245)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(210,210,215)),
	}
	mainGrad.Rotation = 45
	mainGrad.Parent = mainFrame

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(160,160,165)
	mainStroke.Transparency = 0.25
	mainStroke.Thickness = 2
	mainStroke.Parent = mainFrame

	-- Make the panel draggable
	mainFrame.Active = true
	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	mainFrame.InputBegan:Connect(function(input)
		if not isDragable then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	mainFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	-- Top bar
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 36)
	topBar.BackgroundTransparency = 0.12
	topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	topBar.Parent = mainFrame

	local homeBtn = Instance.new("TextButton")
	homeBtn.Name = "HomeButton"
	homeBtn.Size = UDim2.new(0, 100, 1, 0)
	homeBtn.Position = UDim2.new(0, 8, 0, 0)
	homeBtn.BackgroundTransparency = 0
	homeBtn.BackgroundColor3 = Color3.fromRGB(38,38,45)
	homeBtn.AutoButtonColor = false
	homeBtn.Text = "Home"
	homeBtn.TextColor3 = Color3.fromRGB(230,230,235)
	homeBtn.Font = Enum.Font.GothamBold
	homeBtn.TextSize = 18
	homeBtn.TextStrokeTransparency = 1
	homeBtn.Parent = topBar

	local visualsBtn = Instance.new("TextButton")
	visualsBtn.Name = "VisualsButton"
	visualsBtn.Size = UDim2.new(0, 100, 1, 0)
	visualsBtn.Position = UDim2.new(0, 116, 0, 0)
	visualsBtn.BackgroundTransparency = 0
	visualsBtn.BackgroundColor3 = Color3.fromRGB(38,38,45)
	visualsBtn.AutoButtonColor = false
	visualsBtn.Text = "Visuals"
	visualsBtn.TextColor3 = Color3.fromRGB(230,230,235)
	visualsBtn.Font = Enum.Font.GothamBold
	visualsBtn.TextSize = 18
	visualsBtn.TextStrokeTransparency = 1
	visualsBtn.Parent = topBar

	local playerBtn = Instance.new("TextButton")
	playerBtn.Name = "PlayerButton"
	playerBtn.Size = UDim2.new(0, 100, 1, 0)
	playerBtn.Position = UDim2.new(0, 224, 0, 0)
	playerBtn.BackgroundTransparency = 0
	playerBtn.BackgroundColor3 = Color3.fromRGB(38,38,45)
	playerBtn.AutoButtonColor = false
	playerBtn.Text = "Player"
	playerBtn.TextColor3 = Color3.fromRGB(230,230,235)
	playerBtn.Font = Enum.Font.GothamBold
	playerBtn.TextSize = 18
	playerBtn.TextStrokeTransparency = 1
	playerBtn.Parent = topBar

	local hbCorner = Instance.new("UICorner")
	hbCorner.Parent = homeBtn
	local vbCorner = Instance.new("UICorner")
	vbCorner.Parent = visualsBtn
	local pbCorner = Instance.new("UICorner")
	pbCorner.Parent = playerBtn

	-- Add subtle strokes to tabs
	local function addTabStroke(b)
		local s = Instance.new("UIStroke")
		s.Parent = b
		s.Color = Color3.fromRGB(64,64,70)
		s.Transparency = 0.6
		s.Thickness = 1
	end
	addTabStroke(homeBtn)
	addTabStroke(visualsBtn)
	addTabStroke(playerBtn)

	-- Tab indicator (underlines active tab)
	local tabIndicator = Instance.new("Frame")
	tabIndicator.Name = "TabIndicator"
	tabIndicator.Size = UDim2.new(0, 96, 0, 3)
	tabIndicator.Position = UDim2.new(0, homeBtn.Position.X.Offset, 1, -3)
	tabIndicator.AnchorPoint = Vector2.new(0,0)
	tabIndicator.BackgroundColor3 = Color3.fromRGB(150,8,8)
	tabIndicator.Parent = topBar

	local tabIndicatorCorner = Instance.new("UICorner")
	tabIndicatorCorner.CornerRadius = UDim.new(0, 4)
	tabIndicatorCorner.Parent = tabIndicator

	-- bring tabs above indicator
	homeBtn.ZIndex = 2
	visualsBtn.ZIndex = 2
	playerBtn.ZIndex = 2
	tabIndicator.ZIndex = 1

	-- Content
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, 0, 1, -36)
	content.Position = UDim2.new(0, 0, 0, 36)
	content.BackgroundTransparency = 1
	content.Parent = mainFrame

	-- Home
	local homeSection = Instance.new("Frame")
	homeSection.Name = "HomeSection"
	homeSection.Size = UDim2.new(1, 0, 1, 0)
	homeSection.Parent = content

	local homeCard = Instance.new("Frame")
	homeCard.Name = "HomeCard"
	homeCard.Size = UDim2.new(1, -24, 0, 260)
	homeCard.Position = UDim2.new(0, 12, 0, 8)
	homeCard.BackgroundColor3 = Color3.fromRGB(30,30,36)
	homeCard.BackgroundTransparency = 0
	homeCard.Parent = homeSection

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent = homeCard

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = Color3.fromRGB(50,50,60)
	cardStroke.Transparency = 0.5
	cardStroke.Thickness = 1
	cardStroke.Parent = homeCard

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -24, 0, 30)
	title.Position = UDim2.new(0, 12, 0, 8)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Text = "Welcome"
	title.TextColor3 = Color3.fromRGB(245,245,245)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = homeCard

	local body = Instance.new("TextLabel")
	body.Size = UDim2.new(1, -24, 0, 120)
	body.Position = UDim2.new(0, 12, 0, 44)
	body.BackgroundTransparency = 1
	body.Font = Enum.Font.Gotham
	body.TextSize = 14
	body.TextWrapped = true
	body.Text = "Hii there! First of all, I hope you'll have a nice time using my script and that you'll not face any issues while using it (Close and open this window with Insert button). Before you start, please read the tips and notes below to learn how to use this script and some notes on some issues.\n\nNotes: the FOV might not work in this game now, but I'll sure try to fix it later. The third pov might be a bit buggy now, but it works, so be careful about how you use it!\n\nHope you have a nice time!!"
	body.TextColor3 = Color3.fromRGB(220,220,225)
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.Parent = homeCard

	-- Tips list
	local tips = {
		"Tip 1. If Player speed is enabled, keep it down to 12-14 so the system doesn't think your movement is bugged and teleports you back.",
		"Tip 2. Use the location markers to find important locations across the map.",
		"Tip 3. Use the highlights (ESP) to find out where Rake and other players are.",
		"Tip 4. Join my Discord server for updates on this script, and other useful apps. Press the button below to get invited."
	}


	for i, t in ipairs(tips) do
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.new(1, -56, 0, 20)
		tl.Position = UDim2.new(0, 28, 0, 168 + (i-1) * 22)
		tl.BackgroundTransparency = 1
		tl.Font = Enum.Font.Gotham
		tl.TextSize = 13
		tl.Text = "• " .. t
		tl.TextColor3 = Color3.fromRGB(200,200,205)
		tl.TextXAlignment = Enum.TextXAlignment.Left
		tl.Parent = homeCard
	end

	-- reposition homeCard to fit tips + button
	local tipsCount = #tips
	local cardHeight = 44 + 120 + tipsCount * 22 + 72
	homeCard.Size = UDim2.new(1, -24, 0, cardHeight)

	-- Discord invite button (round, bluish)
	local discordBtn = Instance.new("TextButton")
	discordBtn.Name = "DiscordInvite"
	discordBtn.Size = UDim2.new(0, 200, 0, 36)
	discordBtn.Position = UDim2.new(0, 18, 0, 168 + tipsCount * 22 + 16)
	discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	discordBtn.TextColor3 = Color3.fromRGB(255,255,255)
	discordBtn.Font = Enum.Font.GothamBold
	discordBtn.TextSize = 16
	discordBtn.Text = "Join Discord"
	discordBtn.AutoButtonColor = false
	discordBtn.Active = true
	discordBtn.ZIndex = 5
	discordBtn.Parent = homeCard

	local dCorner = Instance.new("UICorner")
	dCorner.CornerRadius = UDim.new(0, 18)
	dCorner.Parent = discordBtn

	local dStroke = Instance.new("UIStroke")
	dStroke.Color = Color3.fromRGB(70,80,220)
	dStroke.Transparency = 0.2
	dStroke.Parent = discordBtn

	local dGrad = Instance.new("UIGradient")
	dGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(96,110,248)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(72,86,238)),
	})
	dGrad.Rotation = 90
	dGrad.Parent = discordBtn

	-- hover animation
	local okT, _ = pcall(function() return TweenService end)
	local hoverTween = nil
	discordBtn.MouseEnter:Connect(function()
		pcall(function()
			if okT and TweenService then
				if hoverTween then hoverTween:Cancel() end
				hoverTween = TweenService:Create(discordBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(104,119,252)})
				hoverTween:Play()
			else
				discordBtn.BackgroundColor3 = Color3.fromRGB(104,119,252)
			end
		end)
	end)
	discordBtn.MouseLeave:Connect(function()
		pcall(function()
			if okT and TweenService then
				if hoverTween then hoverTween:Cancel() end
				hoverTween = TweenService:Create(discordBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(88,101,242)})
				hoverTween:Play()
			else
				discordBtn.BackgroundColor3 = Color3.fromRGB(88,101,242)
			end
		end)
	end)

	-- confirmation label
	local conf = Instance.new("TextLabel")
	conf.Size = UDim2.new(0, 260, 0, 28)
	conf.Position = UDim2.new(0, 230, 0, discordBtn.Position.Y.Offset - 4)
	conf.BackgroundTransparency = 1
	conf.Font = Enum.Font.Gotham
	conf.TextSize = 14
	conf.TextColor3 = Color3.fromRGB(200,200,200)
	conf.Text = ""
	conf.TextXAlignment = Enum.TextXAlignment.Left
	conf.Visible = false
	conf.Parent = homeCard

	discordBtn.MouseButton1Click:Connect(function()
		local url = "https://discord.gg/8At8X7YuKC"
		local ok2, GuiService = pcall(function() return game:GetService("GuiService") end)
		local opened = false
		if ok2 and GuiService and GuiService.OpenBrowserWindow then
			local ok3 = pcall(function() GuiService:OpenBrowserWindow(url) end)
			opened = ok3
		end
		if opened then
			conf.Text = "Invite opened in your browser"
			conf.Visible = true
			task.delay(2, function() pcall(function() conf.Visible = false end) end)
			return
		end
		-- fallback: show link panel with copy / retry open
		local panel = homeCard:FindFirstChild("InvitePanel")
		if panel then panel:Destroy() end
		panel = Instance.new("Frame")
		panel.Name = "InvitePanel"
		panel.Size = UDim2.new(0, 380, 0, 56)
		-- position the panel directly below the Discord button inside the card
		local btnY = discordBtn.Position.Y.Offset
		local btnH = discordBtn.Size.Y.Offset
		panel.Position = UDim2.new(0, 18, 0, btnY + btnH + 8)
		panel.BackgroundColor3 = Color3.fromRGB(24,24,28)
		panel.ZIndex = (homeCard.ZIndex or 1) + 5
		panel.Parent = homeCard

		local pCorner = Instance.new("UICorner") pCorner.CornerRadius = UDim.new(0,6) pCorner.Parent = panel
		local pStroke = Instance.new("UIStroke") pStroke.Color = Color3.fromRGB(40,40,48) pStroke.Transparency = 0.6 pStroke.Parent = panel

		local tb = Instance.new("TextBox")
		tb.Size = UDim2.new(1, -220, 1, -12)
		tb.Position = UDim2.new(0, 8, 0, 6)
		tb.Text = url
		tb.ClearTextOnFocus = false
		tb.TextEditable = false
		tb.Font = Enum.Font.Gotham
		tb.TextSize = 14
		tb.TextColor3 = Color3.fromRGB(220,220,220)
		tb.BackgroundTransparency = 1
		tb.Parent = panel

		local copyBtn = Instance.new("TextButton")
		copyBtn.Size = UDim2.new(0, 80, 0, 36)
		copyBtn.Position = UDim2.new(1, -198, 0, 10)
		copyBtn.Text = "Copy"
		copyBtn.Font = Enum.Font.GothamBold
		copyBtn.TextSize = 14
		copyBtn.BackgroundColor3 = Color3.fromRGB(80,80,88)
		copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
		copyBtn.Parent = panel
		local cbCorner = Instance.new("UICorner") cbCorner.CornerRadius = UDim.new(0,6) cbCorner.Parent = copyBtn

		local openBtn = Instance.new("TextButton")
		openBtn.Size = UDim2.new(0, 100, 0, 36)
		openBtn.Position = UDim2.new(1, -104, 0, 10)
		openBtn.Text = "Open"
		openBtn.Font = Enum.Font.GothamBold
		openBtn.TextSize = 14
		openBtn.BackgroundColor3 = Color3.fromRGB(60,60,68)
		openBtn.TextColor3 = Color3.fromRGB(255,255,255)
		openBtn.Parent = panel
		local obCorner = Instance.new("UICorner") obCorner.CornerRadius = UDim.new(0,6) obCorner.Parent = openBtn

		local function tryCopy()
			local okc, err = pcall(function() setclipboard(url) end)
			conf.Text = okc and "Link copied to clipboard" or "Could not copy link"
			conf.Visible = true
			task.delay(2, function() pcall(function() conf.Visible = false end) end)
		end

		copyBtn.MouseButton1Click:Connect(tryCopy)
		openBtn.MouseButton1Click:Connect(function()
			local ok3, GuiService2 = pcall(function() return game:GetService("GuiService") end)
			if ok3 and GuiService2 and GuiService2.OpenBrowserWindow then
				local ok4 = pcall(function() GuiService2:OpenBrowserWindow(url) end)
				if ok4 then
					conf.Text = "Invite opened in your browser"
					conf.Visible = true
					task.delay(2, function() pcall(function() conf.Visible = false end) end)
					panel:Destroy()
					return
				end
			end
			tryCopy()
		end)

		-- allow clicking outside to close (clicking the button again toggles)
		discordBtn.MouseButton1Click:Wait()
	end)

	-- Visuals (split layout)
	local visualsSection = Instance.new("Frame")
	visualsSection.Name = "VisualsSection"
	visualsSection.Size = UDim2.new(1, 0, 1, 0)
	visualsSection.Visible = false
	visualsSection.BackgroundTransparency = 1
	visualsSection.Parent = content

	-- Player section
	local playerSection = Instance.new("Frame")
	playerSection.Name = "PlayerSection"
	playerSection.Size = UDim2.new(1, 0, 1, 0)
	playerSection.Visible = false
	playerSection.BackgroundTransparency = 1
	playerSection.Parent = content

	local speedLabel = Instance.new("TextLabel")
	speedLabel.Size = UDim2.new(1, 0, 0, 24)
	speedLabel.Position = UDim2.new(0, 8, 0, 8)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Font = Enum.Font.GothamBold
	speedLabel.TextSize = 14
	speedLabel.Text = "Player Speed"
	speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
	speedLabel.Parent = playerSection

	local speedSlider = Instance.new("Frame")
	speedSlider.Size = UDim2.new(1, -16, 0, 24)
	speedSlider.Position = UDim2.new(0, 8, 0, 36)
	speedSlider.BackgroundTransparency = 1
	speedSlider.Parent = playerSection

	local speedBarBg = Instance.new("Frame")
	speedBarBg.Size = UDim2.new(1, 0, 1, 0)
	speedBarBg.BackgroundColor3 = Color3.fromRGB(120,120,120)
	speedBarBg.BackgroundTransparency = 0.4
	speedBarBg.Parent = speedSlider

	local speedFill = Instance.new("Frame")
	speedFill.Size = UDim2.new(0.16, 0, 1, 0)
	speedFill.BackgroundColor3 = Color3.fromRGB(200,200,200)
	speedFill.Parent = speedBarBg

	local speedValueLabel = Instance.new("TextLabel")
	speedValueLabel.Size = UDim2.new(0, 48, 1, 0)
	speedValueLabel.Position = UDim2.new(1, -56, 0, 0)
	speedValueLabel.BackgroundTransparency = 1
	speedValueLabel.Font = Enum.Font.GothamBold
	speedValueLabel.TextSize = 14
	speedValueLabel.TextColor3 = Color3.fromRGB(255,255,255)
	speedValueLabel.Text = tostring(playerSpeed)
	speedValueLabel.Parent = speedSlider

	local _fracSpeed = math.clamp((playerSpeed - 8) / (100 - 8), 0, 1)
	speedFill.Size = UDim2.new(_fracSpeed, 0, 1, 0)

	-- (More Stamina feature removed)

	local leftCol = Instance.new("Frame")
	leftCol.Name = "LeftCol"
	leftCol.Size = UDim2.new(0.55, -8, 1, -8)
	leftCol.Position = UDim2.new(0, 8, 0, 8)
	leftCol.BackgroundTransparency = 1
	leftCol.Parent = visualsSection

	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.Size = UDim2.new(0, 2, 1, -16)
	divider.Position = UDim2.new(0.55, 0, 0, 8)
	divider.BackgroundColor3 = Color3.fromRGB(170,170,170)
	divider.BackgroundTransparency = 0.25
	divider.Parent = visualsSection

	local rightCol = Instance.new("Frame")
	rightCol.Name = "RightCol"
	rightCol.Size = UDim2.new(0.43, -8, 1, -8)
	rightCol.Position = UDim2.new(0.57, 0, 0, 8)
	rightCol.BackgroundTransparency = 1
	rightCol.Parent = visualsSection

	-- Toggle helper
	local function makeToggle(parent, title, initial, onChange)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, -16, 0, 40)
		frame.Position = UDim2.new(0, 8, 0, 0)
		frame.BackgroundTransparency = 1
		frame.Parent = parent

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.66, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = title
		label.Font = Enum.Font.GothamBold
		label.TextSize = 16
		label.TextColor3 = Color3.fromRGB(245, 245, 245)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = frame

		local btnBg = Instance.new("Frame")
		btnBg.Size = UDim2.new(0.28, 0, 0.7, 0)
		btnBg.Position = UDim2.new(0.72, 0, 0.15, 0)
		btnBg.BackgroundColor3 = initial and Color3.fromRGB(140,160,180) or Color3.fromRGB(60,60,66)
		btnBg.BackgroundTransparency = 0.12
		local btnCorner = Instance.new("UICorner") btnCorner.Parent = btnBg
		btnBg.Parent = frame

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -8, 1, -6)
		btn.Position = UDim2.new(0, 4, 0, 3)
		btn.BackgroundTransparency = 1
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.TextStrokeTransparency = 0
		btn.AutoButtonColor = false
		btn.Parent = btnBg

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Parent = btnBg

		local okT, _ = pcall(function() return TweenService end)
		local hoverTween
		btnBg.MouseEnter:Connect(function()
			pcall(function()
				if okT and TweenService then
					if hoverTween then hoverTween:Cancel() end
					hoverTween = TweenService:Create(btnBg, TweenInfo.new(0.12), {BackgroundTransparency = 0.05})
					hoverTween:Play()
				else
					btnBg.BackgroundTransparency = 0.05
				end
			end)
		end)
		btnBg.MouseLeave:Connect(function()
			pcall(function()
				if okT and TweenService then
					if hoverTween then hoverTween:Cancel() end
					hoverTween = TweenService:Create(btnBg, TweenInfo.new(0.12), {BackgroundTransparency = 0.12})
					hoverTween:Play()
				else
					btnBg.BackgroundTransparency = 0.12
				end
			end)
		end)

		local function applyToggleVisual(state)
			btn.Text = state and "ON" or "OFF"
			if state then
				btn.TextColor3 = Color3.fromRGB(255,255,255)
				stroke.Color = Color3.fromRGB(100,120,140)
				btnBg.BackgroundColor3 = Color3.fromRGB(140,160,180)
			else
				btn.TextColor3 = Color3.fromRGB(220,220,220)
				stroke.Color = Color3.fromRGB(60,60,66)
				btnBg.BackgroundColor3 = Color3.fromRGB(60,60,66)
			end
		end

		applyToggleVisual(initial)

		btn.MouseButton1Click:Connect(function()
			initial = not initial
			applyToggleVisual(initial)
			pcall(onChange, initial)
		end)

		return frame
	end

	if playerSection then
		-- Speed enable toggle
		local speedEnableToggle = makeToggle(playerSection, "Enable Speed", playerSpeedEnabled, function(v)
			playerSpeedEnabled = v
			pcall(function() LocalPlayer:SetAttribute("Rake_PlayerSpeedEnabled", v) end)
			if v then
				local ch = LocalPlayer.Character
				local hum = ch and ch:FindFirstChildOfClass("Humanoid")
				if hum then
					pcall(function() hum.WalkSpeed = playerSpeed end)
					enforceHumanoid(hum)
				end
			else
				-- stop enforcing and restore default walk speed
				stopSpeedEnforce()
				local ch = LocalPlayer.Character
				local hum = ch and ch:FindFirstChildOfClass("Humanoid")
				if hum then
					pcall(function() hum.WalkSpeed = DEFAULT_WALK_SPEED end)
				end
			end
			saveSettings()
		end)
		speedEnableToggle.Position = UDim2.new(0, 8, 0, 68)
	end

	-- Right column: Camera settings (FOV slider + POV radio)
	local fovLabel = Instance.new("TextLabel")
	fovLabel.Size = UDim2.new(1, 0, 0, 24)
	fovLabel.Position = UDim2.new(0, 8, 0, 8)
	fovLabel.BackgroundTransparency = 1
	fovLabel.Font = Enum.Font.GothamBold
	fovLabel.TextSize = 14
	fovLabel.Text = "FOV"
	fovLabel.TextColor3 = Color3.fromRGB(255,255,255)
	fovLabel.Parent = rightCol

	local fovSlider = Instance.new("Frame")
	fovSlider.Size = UDim2.new(1, -16, 0, 24)
	fovSlider.Position = UDim2.new(0, 8, 0, 36)
	fovSlider.BackgroundTransparency = 1
	fovSlider.Parent = rightCol

	local fovBarBg = Instance.new("Frame")
	fovBarBg.Size = UDim2.new(1, 0, 1, 0)
	fovBarBg.BackgroundColor3 = Color3.fromRGB(120,120,120)
	fovBarBg.BackgroundTransparency = 0.4
	fovBarBg.Parent = fovSlider

	local fovFill = Instance.new("Frame")
	fovFill.Size = UDim2.new(0.5, 0, 1, 0)
	fovFill.BackgroundColor3 = Color3.fromRGB(200,200,200)
	fovFill.Parent = fovBarBg

	local fovValueLabel = Instance.new("TextLabel")
	fovValueLabel.Size = UDim2.new(0, 48, 1, 0)
	fovValueLabel.Position = UDim2.new(1, -56, 0, 0)
	fovValueLabel.BackgroundTransparency = 1
	fovValueLabel.Font = Enum.Font.GothamBold
	fovValueLabel.TextSize = 14
	fovValueLabel.TextColor3 = Color3.fromRGB(255,255,255)
	fovValueLabel.Text = tostring(math.floor(workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70))
	fovValueLabel.Parent = fovSlider
	local currentFov = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70
	local _fracInit = math.clamp((currentFov - 30) / 70, 0, 1)
	fovFill.Size = UDim2.new(_fracInit, 0, 1, 0)

	local fovEnforceConn = nil
	local function stopFovEnforce()
		if fovEnforceConn then
			fovEnforceConn:Disconnect()
			fovEnforceConn = nil
		end
	end
	local function startFovEnforce()
		stopFovEnforce()
		fovEnforceConn = RunService.RenderStepped:Connect(function()
			local cam = workspace.CurrentCamera
			if cam and currentFov then
				if cam.FieldOfView ~= currentFov then
					pcall(function() cam.FieldOfView = currentFov end)
				end
			end
		end)
	end

	if loadedSettings and loadedSettings.fov then
		currentFov = loadedSettings.fov
		fovValueLabel.Text = tostring(math.floor(currentFov))
		local frac = math.clamp((currentFov - 30) / 70, 0, 1)
		fovFill.Size = UDim2.new(frac, 0, 1, 0)
		startFovEnforce()
	end

	-- POV radio options
	local povLabel = Instance.new("TextLabel")
	povLabel.Size = UDim2.new(1, 0, 0, 24)
	povLabel.Position = UDim2.new(0, 8, 0, 72)
	povLabel.BackgroundTransparency = 1
	povLabel.Font = Enum.Font.GothamBold
	povLabel.TextSize = 14
	povLabel.Text = "POV"
	povLabel.TextColor3 = Color3.fromRGB(255,255,255)
	povLabel.Parent = rightCol

	local povOptions = { "Default", "Third" }
	-- Dropdown for POV selection
	local povDropdown = Instance.new("TextButton")
	povDropdown.Size = UDim2.new(1, -16, 0, 32)
	povDropdown.Position = UDim2.new(0, 8, 0, 72)
	povDropdown.BackgroundColor3 = Color3.fromRGB(60,60,60)
	povDropdown.Font = Enum.Font.Gotham
	povDropdown.TextColor3 = Color3.fromRGB(255,255,255)
	povDropdown.Text = LocalPlayer:GetAttribute("Rake_POV") or "Default"
	povDropdown.Active = true
	povDropdown.ZIndex = 60
	povDropdown.Parent = rightCol

	local dropdownList = Instance.new("Frame")
	dropdownList.Size = UDim2.new(1, -16, 0, #povOptions * 30)
	dropdownList.Position = UDim2.new(0, 8, 0, 72 + 36)
	dropdownList.BackgroundColor3 = Color3.fromRGB(45,45,45)
	dropdownList.BackgroundTransparency = 0
	dropdownList.Visible = false
	dropdownList.Active = true
	dropdownList.ZIndex = 59
	dropdownList.Parent = rightCol

	local povOptionButtons = {}
	for i, opt in ipairs(povOptions) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, 0, 0, 28)
		b.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
		b.BackgroundTransparency = 0
		b.BackgroundColor3 = Color3.fromRGB(45,45,45)
		b.Font = Enum.Font.Gotham
		b.TextColor3 = Color3.fromRGB(200,200,200)
		b.Text = opt
		b.ZIndex = 61
		b.Parent = dropdownList
		table.insert(povOptionButtons, b)

		b.MouseButton1Click:Connect(function()
			applyPOV(opt)
			saveSettings()
			povDropdown.Text = opt
			for _, btn in ipairs(povOptionButtons) do
				btn.TextColor3 = Color3.fromRGB(200,200,200)
			end
			b.TextColor3 = Color3.fromRGB(255,255,255)
			dropdownList.Visible = false
		end)
	end

	-- Initialize visual state: highlight the currently selected POV
	local initPOV = povDropdown.Text or "Default"
	for _, btn in ipairs(povOptionButtons) do
		if btn.Text == initPOV then
			btn.TextColor3 = Color3.fromRGB(255,255,255)
		else
			btn.TextColor3 = Color3.fromRGB(200,200,200)
		end
	end

	povDropdown.MouseButton1Click:Connect(function()
		local newVis = not dropdownList.Visible
		dropdownList.Visible = newVis
		-- disable dragging while dropdown open to ensure clicks register
		isDragable = not newVis
	end)

	-- Player section speed dragging input
	local draggingSpeed = false
	speedBarBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSpeed = true
			isDragable = false
		end
	end)
	speedBarBg.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSpeed = false
			isDragable = true
			saveSettings()
		end
	end)
	speedBarBg.InputChanged:Connect(function(input)
		if draggingSpeed and input.UserInputType == Enum.UserInputType.MouseMovement then
			local absX = input.Position.X - speedBarBg.AbsolutePosition.X
			local frac = math.clamp(absX / speedBarBg.AbsoluteSize.X, 0, 1)
			speedFill.Size = UDim2.new(frac, 0, 1, 0)
			local spd = 8 + math.floor(frac * (100 - 8))
			playerSpeed = spd
			speedValueLabel.Text = tostring(spd)
			local ch = LocalPlayer.Character
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			if hum then
				if playerSpeedEnabled then
					pcall(function() hum.WalkSpeed = spd end)
					enforceHumanoid(hum)
				end
			end
			pcall(function() LocalPlayer:SetAttribute("Rake_PlayerSpeed", spd) end)
			pcall(function() saveSettings() end)
		end
	end)

	-- ensure speed applies on character spawn
	LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.15)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			if playerSpeedEnabled then
				pcall(function() hum.WalkSpeed = playerSpeed end)
				enforceHumanoid(hum)
			else
				pcall(function() hum.WalkSpeed = DEFAULT_WALK_SPEED end)
				stopSpeedEnforce()
			end
		else
			stopSpeedEnforce()
		end
	end)

	-- apply immediately if character already present
	do
		local ch = LocalPlayer.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum then
			if playerSpeedEnabled then
				pcall(function() hum.WalkSpeed = playerSpeed end)
				enforceHumanoid(hum)
			else
				pcall(function() hum.WalkSpeed = DEFAULT_WALK_SPEED end)
			end
		end
	end

	-- FOV dragging input
	local draggingFOV = false
	fovBarBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingFOV = true
			isDragable = false
		end
	end)
	fovBarBg.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingFOV = false
			isDragable = true
			-- persist and start enforcement
			pcall(function() saveSettings() end)
			startFovEnforce()
		end
	end)
	fovBarBg.InputChanged:Connect(function(input)
		if draggingFOV and input.UserInputType == Enum.UserInputType.MouseMovement then
			local absX = input.Position.X - fovBarBg.AbsolutePosition.X
			local frac = math.clamp(absX / fovBarBg.AbsoluteSize.X, 0, 1)
			fovFill.Size = UDim2.new(frac, 0, 1, 0)
			local fov = 30 + math.floor(frac * 70)
			currentFov = fov
			if workspace.CurrentCamera then pcall(function() workspace.CurrentCamera.FieldOfView = fov end) end
			fovValueLabel.Text = tostring(fov)
		end
	end)

	-- left column toggles
	local yOffset = 0
	local rakeToggle = makeToggle(leftCol, "The Rake", ESP_SETTINGS.showRake, function(v)
		ESP_SETTINGS.showRake = v
		refreshAllHighlights()
		saveSettings()
	end)
	rakeToggle.Position = UDim2.new(0, 8, 0, yOffset)
	yOffset = yOffset + 44

	local playerToggle = makeToggle(leftCol, "Players", ESP_SETTINGS.showPlayers, function(v)
		ESP_SETTINGS.showPlayers = v
		refreshAllHighlights()
		saveSettings()
	end)
	playerToggle.Position = UDim2.new(0, 8, 0, yOffset)
	yOffset = yOffset + 44

	local npcToggle = makeToggle(leftCol, "Other NPC's", ESP_SETTINGS.showNPCs, function(v)
		ESP_SETTINGS.showNPCs = v
		refreshAllHighlights()
		saveSettings()
	end)
	npcToggle.Position = UDim2.new(0, 8, 0, yOffset)

	yOffset = yOffset + 44

	local showLocations = true
	local locToggle = makeToggle(leftCol, "Show Locations", showLocations, function(v)
		showLocations = v
		if v then
			pcall(function() enableLocationMarkers(screen) end)
		else
			pcall(function() disableLocationMarkers() end)
		end
		-- no persistence necessary but still save settings blob
		saveSettings()
	end)
	locToggle.Position = UDim2.new(0, 8, 0, yOffset)
	yOffset = yOffset + 44



	-- Dropdown to choose which locations to show (placed after Improved Lighting)
	local chooseBtn = Instance.new("TextButton")
	chooseBtn.Size = UDim2.new(1, -16, 0, 28)
	chooseBtn.Position = UDim2.new(0, 8, 0, yOffset)
	chooseBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
	chooseBtn.Font = Enum.Font.Gotham
	chooseBtn.TextColor3 = Color3.fromRGB(255,255,255)
	chooseBtn.Text = "Choose Locations"
	chooseBtn.ZIndex = 200
	chooseBtn.Active = true
	chooseBtn.Parent = leftCol

	local chooseList = Instance.new("Frame")
	chooseList.Size = UDim2.new(1, -16, 0, #LOCATIONS * 44)
	chooseList.Position = UDim2.new(0, 8, 0, yOffset + 30)
	chooseList.BackgroundColor3 = Color3.fromRGB(45,45,45)
	chooseList.BackgroundTransparency = 0
	chooseList.Visible = false
	chooseList.Active = true
	chooseList.ZIndex = 205
	chooseList.Parent = leftCol

	yOffset = yOffset + 12

	-- if settings requested rake meter enabled, start it now
	if RAKE_METER.enabled then
		pcall(function() enableRakeMeter(screen) end)
	end

	-- if settings requested improved lighting, enable it now
	if IMPROVED_LIGHTING_ENABLED then
		pcall(function() enableImprovedLighting() end)
	end



	local locToggles = {}
	for i, loc in ipairs(LOCATIONS) do
		local initial = LOCATION_SETTINGS[loc.name] ~= false
		local t = makeToggle(chooseList, loc.name, initial, function(v)
			LOCATION_SETTINGS[loc.name] = v
			-- immediately update markers visibility (UI containers)
			pcall(function() updateLocationMarkers(screen) end)
			-- also update any existing world-part marker transparency immediately
			pcall(function()
				local entry = LOCATION_MARKERS[loc.name]
				if entry and entry.worldPart then
					local enabled = v
					entry.worldPart.Transparency = enabled and 0 or 1
					local bp = entry.worldPart:FindFirstChildOfClass("BillboardGui")
					if bp then
						pcall(function() bp.Enabled = enabled end)
						local lbl = bp:FindFirstChildWhichIsA("TextLabel")
						if lbl then lbl.Visible = enabled end
					end
				end
			end)
			saveSettings()
		end)
		t.Position = UDim2.new(0, 8, 0, (i - 1) * 44)
		table.insert(locToggles, t)
		-- ensure the toggle and its children render above nearby UI (like lightning labels)
		pcall(function()
			t.ZIndex = 206
			for _, d in ipairs(t:GetDescendants()) do
				if pcall(function() return d.ZIndex end) then
					d.ZIndex = 206
				end
			end
		end)
	end

	chooseBtn.MouseButton1Click:Connect(function()
		local newVis = not chooseList.Visible
		chooseList.Visible = newVis
		isDragable = not newVis
	end)

	-- Splitting horizontal line and label for lighting-related controls (placed below chooseList)
	local baseY = yOffset + 22

	local lightningDivider = Instance.new("Frame")
	lightningDivider.Name = "LightningDivider"
	lightningDivider.Size = UDim2.new(1, -16, 0, 2)
	lightningDivider.Position = UDim2.new(0, 8, 0, baseY)
	lightningDivider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	lightningDivider.BackgroundTransparency = 0.35
	lightningDivider.ZIndex = 201
	lightningDivider.Parent = leftCol

	-- Section label for lighting controls
	local lightningLabel = Instance.new("TextLabel")
	lightningLabel.Name = "LightningLabel"
	lightningLabel.Size = UDim2.new(1, -16, 0, 22)
	lightningLabel.Position = UDim2.new(0, 8, 0, baseY + 12)
	lightningLabel.BackgroundTransparency = 1
	lightningLabel.Font = Enum.Font.GothamBold
	lightningLabel.TextSize = 16
	lightningLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	lightningLabel.Text = "Lighting Related"
	lightningLabel.TextXAlignment = Enum.TextXAlignment.Left
	lightningLabel.ZIndex = 202
	lightningLabel.Parent = leftCol

	-- Improved Lighting toggle (placed just under the label)
	local improvedToggle = makeToggle(leftCol, "Improved Lighting", IMPROVED_LIGHTING_ENABLED, function(v)
		IMPROVED_LIGHTING_ENABLED = v
		if v then
			pcall(function() enableImprovedLighting() end)
		else
			pcall(function() disableImprovedLighting() end)
		end
		saveSettings()
	end)
	improvedToggle.Position = UDim2.new(0, 8, 0, baseY + 36)
	yOffset = baseY + 36 + 44



	-- start markers if enabled
	if showLocations then
		pcall(function() enableLocationMarkers(screen) end)
	end

	-- Rake controls group (moved out of left column so it's grouped with other visuals)
	local rakeGroup = Instance.new("Frame")
	rakeGroup.Name = "RakeGroup"
	rakeGroup.Size = UDim2.new(1, -16, 0, 96)
	rakeGroup.Position = UDim2.new(0, 8, 0, 140)
	rakeGroup.BackgroundTransparency = 1
	rakeGroup.Parent = rightCol

	local rakeMeterToggle = makeToggle(rakeGroup, "Rake Meter", RAKE_METER.enabled, function(v)
		RAKE_METER.enabled = v
		if v then
			pcall(function() enableRakeMeter(screen) end)
		else
			pcall(function() disableRakeMeter() end)
		end
		saveSettings()
	end)
	rakeMeterToggle.Position = UDim2.new(0, 8, 0, 8)

	local beamToggle = makeToggle(rakeGroup, "Use Beam", RAKE_METER.useBeam, function(v)
		RAKE_METER.useBeam = v
		if RAKE_METER.beam then
			RAKE_METER.beam.Enabled = v
		end
		saveSettings()
	end)
	beamToggle.Position = UDim2.new(0, 8, 0, 52)

	-- Active section handling: move button up and change text color
	local homeDefaultPos = homeBtn.Position
	local visualsDefaultPos = visualsBtn.Position
	local playerDefaultPos = playerBtn.Position
	local homeActivePos = UDim2.new(homeDefaultPos.X.Scale, homeDefaultPos.X.Offset, homeDefaultPos.Y.Scale, homeDefaultPos.Y.Offset - 6)
	local visualsActivePos = UDim2.new(visualsDefaultPos.X.Scale, visualsDefaultPos.X.Offset, visualsDefaultPos.Y.Scale, visualsDefaultPos.Y.Offset - 6)
	local playerActivePos = UDim2.new(playerDefaultPos.X.Scale, playerDefaultPos.X.Offset, playerDefaultPos.Y.Scale, playerDefaultPos.Y.Offset - 6)
	local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function setActiveSection(name)
		if name == "Home" then
			TweenService:Create(homeBtn, tweenInfo, {Position = homeActivePos, TextColor3 = Color3.fromRGB(150,8,8)}):Play()
			TweenService:Create(visualsBtn, tweenInfo, {Position = visualsDefaultPos, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			TweenService:Create(playerBtn, tweenInfo, {Position = playerDefaultPos, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			-- animate backgrounds
			TweenService:Create(homeBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60,60,70)}):Play()
			TweenService:Create(visualsBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(38,38,45)}):Play()
			TweenService:Create(playerBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(38,38,45)}):Play()
			-- move tab indicator
			if tabIndicator then
				local tgt = UDim2.new(0, homeDefaultPos.X.Offset, 1, -3)
				TweenService:Create(tabIndicator, tweenInfo, {Position = tgt}):Play()
			end
			homeSection.Visible = true
			visualsSection.Visible = false
			playerSection.Visible = false
		elseif name == "Visuals" then
			TweenService:Create(visualsBtn, tweenInfo, {Position = visualsActivePos, TextColor3 = Color3.fromRGB(150,8,8)}):Play()
			TweenService:Create(homeBtn, tweenInfo, {Position = homeDefaultPos, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			TweenService:Create(playerBtn, tweenInfo, {Position = playerDefaultPos, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			-- animate backgrounds
			TweenService:Create(visualsBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60,60,70)}):Play()
			TweenService:Create(homeBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(38,38,45)}):Play()
			TweenService:Create(playerBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(38,38,45)}):Play()
			-- move tab indicator
			if tabIndicator then
				local tgt = UDim2.new(0, visualsDefaultPos.X.Offset, 1, -3)
				TweenService:Create(tabIndicator, tweenInfo, {Position = tgt}):Play()
			end
			homeSection.Visible = false
			visualsSection.Visible = true
			playerSection.Visible = false
		else
			TweenService:Create(playerBtn, tweenInfo, {Position = playerActivePos, TextColor3 = Color3.fromRGB(150,8,8)}):Play()
			TweenService:Create(homeBtn, tweenInfo, {Position = homeDefaultPos, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			TweenService:Create(visualsBtn, tweenInfo, {Position = visualsDefaultPos, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			-- animate backgrounds
			TweenService:Create(playerBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60,60,70)}):Play()
			TweenService:Create(homeBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(38,38,45)}):Play()
			TweenService:Create(visualsBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(38,38,45)}):Play()
			-- move tab indicator
			if tabIndicator then
				local tgt = UDim2.new(0, playerDefaultPos.X.Offset, 1, -3)
				TweenService:Create(tabIndicator, tweenInfo, {Position = tgt}):Play()
			end
			homeSection.Visible = false
			visualsSection.Visible = false
			playerSection.Visible = true
		end
	end

	homeBtn.MouseButton1Click:Connect(function()
		setActiveSection("Home")
	end)
	visualsBtn.MouseButton1Click:Connect(function()
		setActiveSection("Visuals")
	end)
	playerBtn.MouseButton1Click:Connect(function()
		setActiveSection("Player")
	end)

	setActiveSection("Home")
end

-- Create GUI and attempt to keep on top
createESPGui()
if SCREEN_GUI then
	local ok = false
	pcall(function()
		SCREEN_GUI.DisplayOrder = 1000
		SCREEN_GUI.Parent = game:GetService("CoreGui")
		ok = true
	end)
	if not ok then
		SCREEN_GUI.Parent = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") or SCREEN_GUI.Parent
		SCREEN_GUI.DisplayOrder = 1000
	end
	SCREEN_GUI.Enabled = true
end

local function setMouseVisible(visible)
	if visible then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
	end
end

local mouseVisible = false
setMouseVisible(false)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		if not SCREEN_GUI then
			createESPGui()
		end
		if SCREEN_GUI then
			mouseVisible = not SCREEN_GUI.Enabled
			SCREEN_GUI.Enabled = mouseVisible
			setMouseVisible(mouseVisible)
		else
			mouseVisible = not mouseVisible
			setMouseVisible(mouseVisible)
		end
	end
end)

-- GUI END


