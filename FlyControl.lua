-- Fly + NoClip + Speed + Protect + Fake Helicity Storm (LocalScript)
-- Put this in StarterPlayerScripts (client-side). All effects local to player.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- wait character
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(chr)
	character = chr
	humanoid = chr:WaitForChild("Humanoid")
	hrp = chr:WaitForChild("HumanoidRootPart")
end)

-- state
local flying = false
local flySpeed = 80
local speedModeOn = false
local speedValue = 24 -- default walk speed
local noclipOn = false
local protectedOn = false
local stormOn = false

-- store original collisions for restore
local originalCollisions = {}

-- cleanup old GUIs
if player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("FlyControlGUI") then
	player.PlayerGui.FlyControlGUI:Destroy()
end
if player.PlayerGui:FindFirstChild("FlyRestoreGUI") then
	player.PlayerGui.FlyRestoreGUI:Destroy()
end

-- ---------- GUI (keeps previous style + new buttons) ----------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyControlGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 300, 0, 220)
frame.Position = UDim2.new(0.5, -150, 0.78, -110)
frame.BackgroundColor3 = Color3.fromRGB(18, 24, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(6,150,130)

-- header
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,34)
header.BackgroundTransparency = 1
local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.7, -8, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🕊️ Fly + Tools"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(6,150,130)
title.TextXAlignment = Enum.TextXAlignment.Left

-- control buttons (min/max/close)
local function makeHeaderBtn(txt, xOffset)
	local b = Instance.new("TextButton", header)
	b.Size = UDim2.new(0,28,0,24)
	b.Position = UDim2.new(1, xOffset, 0, 5)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.BackgroundTransparency = 0.15
	b.BackgroundColor3 = Color3.fromRGB(30,30,40)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
	return b
end
local btnMin = makeHeaderBtn("-", -92)
local btnMax = makeHeaderBtn("□", -60)
local btnClose = makeHeaderBtn("X", -32)

-- status labels and inputs
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, -20, 0, 22)
statusLabel.Position = UDim2.new(0, 10, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Fly: OFF"
statusLabel.Font = Enum.Font.GothamSemibold
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- speed box for fly and walk
local flySpeedBox = Instance.new("TextBox", frame)
flySpeedBox.Size = UDim2.new(0, 120, 0, 28)
flySpeedBox.Position = UDim2.new(0, 10, 0, 68)
flySpeedBox.PlaceholderText = "Fly speed (e.g. 80)"
flySpeedBox.ClearTextOnFocus = false
flySpeedBox.Font = Enum.Font.Gotham
flySpeedBox.TextSize = 14
flySpeedBox.BackgroundColor3 = Color3.fromRGB(30,30,36)
Instance.new("UICorner", flySpeedBox).CornerRadius = UDim.new(0,6)

local flySetBtn = Instance.new("TextButton", frame)
flySetBtn.Size = UDim2.new(0, 80, 0, 28)
flySetBtn.Position = UDim2.new(0, 140, 0, 68)
flySetBtn.Text = "Set"
flySetBtn.Font = Enum.Font.GothamBold
flySetBtn.TextSize = 14
flySetBtn.BackgroundColor3 = Color3.fromRGB(10,120,100)
Instance.new("UICorner", flySetBtn).CornerRadius = UDim.new(0,6)

local walkLabel = Instance.new("TextLabel", frame)
walkLabel.Size = UDim2.new(1, -20, 0, 20)
walkLabel.Position = UDim2.new(0, 10, 0, 105)
walkLabel.BackgroundTransparency = 1
walkLabel.Text = "Walk Speed: OFF"
walkLabel.Font = Enum.Font.GothamSemibold
walkLabel.TextSize = 14
walkLabel.TextColor3 = Color3.fromRGB(200,200,200)
walkLabel.TextXAlignment = Enum.TextXAlignment.Left

local walkBox = Instance.new("TextBox", frame)
walkBox.Size = UDim2.new(0, 120, 0, 28)
walkBox.Position = UDim2.new(0, 10, 0, 130)
walkBox.PlaceholderText = "Walk speed (e.g. 24)"
walkBox.ClearTextOnFocus = false
walkBox.Font = Enum.Font.Gotham
walkBox.TextSize = 14
walkBox.BackgroundColor3 = Color3.fromRGB(30,30,36)
Instance.new("UICorner", walkBox).CornerRadius = UDim.new(0,6)

local walkToggle = Instance.new("TextButton", frame)
walkToggle.Size = UDim2.new(0, 80, 0, 28)
walkToggle.Position = UDim2.new(0, 140, 0, 130)
walkToggle.Text = "Toggle"
walkToggle.Font = Enum.Font.GothamBold
walkToggle.TextSize = 14
walkToggle.BackgroundColor3 = Color3.fromRGB(10,120,100)
Instance.new("UICorner", walkToggle).CornerRadius = UDim.new(0,6)

-- action buttons row: Fly Toggle, NoClip, Protect, Storm
local btnRowY = 170
local function makeActionBtn(name, x)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0, 66, 0, 36)
	b.Position = UDim2.new(0, 10 + (x * 74), 0, btnRowY)
	b.Text = name
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.BackgroundColor3 = Color3.fromRGB(45,45,52)
	b.TextColor3 = Color3.fromRGB(230,230,230)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
	return b
end

local flyToggleBtn = makeActionBtn("Fly", 0)
local noclipBtn = makeActionBtn("NoClip", 1)
local protectBtn = makeActionBtn("Protect", 2)
local stormBtn = makeActionBtn("Storm", 3)

-- restore gui when minimized
local restoreGui = Instance.new("ScreenGui")
restoreGui.Name = "FlyRestoreGUI"
restoreGui.ResetOnSpawn = false
restoreGui.Parent = player:WaitForChild("PlayerGui")
local restoreBtn = Instance.new("TextButton", restoreGui)
restoreBtn.Size = UDim2.new(0, 120, 0, 40)
restoreBtn.Position = UDim2.new(0, 10, 1, -80)
restoreBtn.Text = "Show Tools"
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = 14
restoreBtn.BackgroundColor3 = Color3.fromRGB(30,30,36)
Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0,8)
restoreBtn.Visible = false

-- ---------- Helpers & Logic ----------

-- safe pcall wrap
local function safe(fn) local ok, e = pcall(fn) if not ok then warn(e) end end

-- fly implementation: uses BodyVelocity + BodyGyro
local flyBV, flyBG, flyConnection
local function startFly()
	if flying then return end
	flying = true
	statusLabel.Text = "Fly: ON"
	statusLabel.TextColor3 = Color3.fromRGB(120,255,120)
	-- create BV/BG
	flyBV = Instance.new("BodyVelocity")
	flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
	flyBV.Parent = hrp
	flyBG = Instance.new("BodyGyro")
	flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
	flyBG.CFrame = hrp.CFrame
	flyBG.Parent = hrp
	-- connection
	flyConnection = RunService.Heartbeat:Connect(function()
		if not flying then return end
		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += workspace.CurrentCamera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= workspace.CurrentCamera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= workspace.CurrentCamera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += workspace.CurrentCamera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
		if move.Magnitude > 0 then move = move.Unit * flySpeed else move = Vector3.zero end
		if flyBV then flyBV.Velocity = move end
		if flyBG then flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + workspace.CurrentCamera.CFrame.LookVector) end
	end)
end

local function stopFly()
	if not flying then return end
	flying = false
	statusLabel.Text = "Fly: OFF"
	statusLabel.TextColor3 = Color3.fromRGB(255,120,120)
	safe(function()
		if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
		if flyBV and flyBV.Parent then flyBV:Destroy() end
		if flyBG and flyBG.Parent then flyBG:Destroy() end
	end)
end

-- NoClip: set CanCollide=false for character parts, keep connection to maintain
local noclipConnection
local function enableNoClip()
	if noclipOn then return end
	noclipOn = true
	noclipBtn.BackgroundColor3 = Color3.fromRGB(60,120,80)
	-- store original collisions
	originalCollisions = {}
	for _,part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			originalCollisions[part] = part.CanCollide
			part.CanCollide = false
		end
	end
	-- protect against respawn changes
	noclipConnection = RunService.Stepped:Connect(function()
		for _,part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end)
end

local function disableNoClip()
	if not noclipOn then return end
	noclipOn = false
	noclipBtn.BackgroundColor3 = Color3.fromRGB(45,45,52)
	if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
	for part,orig in pairs(originalCollisions) do
		if part and part:IsA("BasePart") then
			pcall(function() part.CanCollide = orig end)
		end
	end
	originalCollisions = {}
end

-- Speed (walk speed) toggle and apply value
local speedConn
local function enableSpeedMode(val)
	speedModeOn = true
	speedValue = val or speedValue
	walkLabel.Text = "Walk Speed: "..tostring(speedValue)
	walkToggle.BackgroundColor3 = Color3.fromRGB(60,120,80)
	-- apply immediately
	pcall(function() humanoid.WalkSpeed = speedValue end)
	-- if wanted, continuously enforce
	speedConn = RunService.Heartbeat:Connect(function()
		if speedModeOn then
			if humanoid and humanoid.Parent then pcall(function() humanoid.WalkSpeed = speedValue end) end
		end
	end)
end

local function disableSpeedMode()
	speedModeOn = false
	walkToggle.BackgroundColor3 = Color3.fromRGB(45,45,52)
	if speedConn then speedConn:Disconnect(); speedConn = nil end
	-- restore default (Roblox default 16)
	pcall(function() humanoid.WalkSpeed = 16 end)
	walkLabel.Text = "Walk Speed: OFF"
end

-- Protect (god-like but local-safe)
local function enableProtect()
	protectedOn = true
	protectBtn.BackgroundColor3 = Color3.fromRGB(60,120,80)
	protectBtn.Text = "Protect ON"
	-- locally prevent death by disabling Dead state and setting huge health
	pcall(function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
	end)
end

local function disableProtect()
	protectedOn = false
	protectBtn.BackgroundColor3 = Color3.fromRGB(45,45,52)
	protectBtn.Text = "Protect OFF"
	pcall(function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
		-- restore reasonable values
		humanoid.MaxHealth = 100
		humanoid.Health = math.min(100, humanoid.Health)
	end)
end

-- Fake Helicity storm (client-only): particles + screen flash + thunder sound
local stormParticlesFolder
local stormHeartbeatConn
local thunderSound
local function startStorm()
	if stormOn then return end
	stormOn = true
	stormBtn.BackgroundColor3 = Color3.fromRGB(60,120,80)
	-- create particle emitter attached to a part above player
	local anchor = Instance.new("Part")
	anchor.Name = "StormAnchor"
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.Anchored = true
	anchor.Size = Vector3.new(1,1,1)
	anchor.CFrame = hrp.CFrame + Vector3.new(0, 30, 0)
	anchor.Parent = workspace -- anchor in workspace but invisible; only client effects used

	stormParticlesFolder = Instance.new("Folder", anchor)

	-- rain particle
	local rain = Instance.new("ParticleEmitter", anchor)
	rain.Name = "Rain"
	rain.Texture = "rbxassetid://2801263" -- simple raindrop-ish
	rain.Rate = 250
	rain.Lifetime = NumberRange.new(0.6, 1.2)
	rain.Speed = NumberRange.new(60, 80)
	rain.VelocitySpread = 20
	rain.Size = NumberSequence.new(0.6)
	rain.Transparency = NumberSequence.new(0.6)
	rain.Parent = anchor

	-- cloud particles (smoke)
	local cloud = Instance.new("ParticleEmitter", anchor)
	cloud.Name = "Cloud"
	cloud.Texture = "rbxassetid://26356449"
	cloud.Rate = 30
	cloud.Lifetime = NumberRange.new(1.2,2.4)
	cloud.Speed = NumberRange.new(4,8)
	cloud.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 20), NumberSequenceKeypoint.new(1, 40)})
	cloud.Color = ColorSequence.new(Color3.fromRGB(40,40,50))
	cloud.Rotation = NumberRange.new(0,360)
	cloud.VelocitySpread = 50
	cloud.Parent = anchor

	-- occasional lightning: create an overlay frame to flash the screen
	local flash = Instance.new("ScreenGui")
	flash.ResetOnSpawn = false
	flash.Name = "StormFlash"
	flash.Parent = player:WaitForChild("PlayerGui")
	local f = Instance.new("Frame", flash)
	f.Size = UDim2.new(1,0,1,0)
	f.BackgroundColor3 = Color3.new(1,1,1)
	f.BackgroundTransparency = 1
	f.ZIndex = 9999

	-- thunder sound (local)
	thunderSound = Instance.new("Sound", player:WaitForChild("PlayerGui"))
	thunderSound.SoundId = "rbxassetid://130791856" -- example thunderish (change if desired)
	thunderSound.Volume = 1

	-- heartbeat to animate anchor follow player and occasional lightning
	stormHeartbeatConn = RunService.Heartbeat:Connect(function(dt)
		if not stormOn then return end
		-- keep anchor above player
		if anchor and anchor.Parent then
			anchor.CFrame = hrp.CFrame + Vector3.new(0, 30, 0)
		end
		-- random lightning event ~ every 2-6 seconds
		if math.random() < (dt * 0.3) then
			-- flash
			TweenService:Create(f, TweenInfo.new(0.06), {BackgroundTransparency = 0}):Play()
			task.delay(0.06, function()
				TweenService:Create(f, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
			end)
			-- play thunder
			pcall(function() thunderSound:Play() end)
		end
	end)
end

local function stopStorm()
	if not stormOn then return end
	stormOn = false
	stormBtn.BackgroundColor3 = Color3.fromRGB(45,45,52)
	-- cleanup
	if stormHeartbeatConn then stormHeartbeatConn:Disconnect(); stormHeartbeatConn = nil end
	if stormParticlesFolder and stormParticlesFolder.Parent then
		pcall(function() stormParticlesFolder.Parent:Destroy() end)
		stormParticlesFolder = nil
	end
	-- remove flash gui & sound
	pcall(function()
		if player.PlayerGui:FindFirstChild("StormFlash") then player.PlayerGui.StormFlash:Destroy() end
		for _,s in pairs(player.PlayerGui:GetChildren()) do
			if s:IsA("Sound") and s.SoundId:match("130791856") then s:Destroy() end
		end
	end)
end

-- ---------- UI events ----------

-- set fly speed
flySetBtn.MouseButton1Click:Connect(function()
	local txt = flySpeedBox.Text
	local n = tonumber(txt)
	if n and n > 0 then
		flySpeed = n
		flySetBtn.Text = "OK"
		task.delay(1, function() pcall(function() flySetBtn.Text = "Set" end) end)
	else
		flySetBtn.Text = "Bad"
		task.delay(1, function() pcall(function() flySetBtn.Text = "Set" end) end)
	end
end)

-- fly toggle button
flyToggleBtn.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

-- header buttons
btnMin.MouseButton1Click:Connect(function()
	frame.Visible = false
	restoreBtn.Visible = true
end)
restoreBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	restoreBtn.Visible = false
end)
btnMax.MouseButton1Click:Connect(function()
	if frame.Size.X.Offset < 500 then
		frame.Size = UDim2.new(0, 520, 0, 380)
	else
		frame.Size = UDim2.new(0, 300, 0, 220)
	end
end)
btnClose.MouseButton1Click:Connect(function()
	-- cleanup all
	stopFly()
	disableNoClip()
	disableSpeedMode()
	disableProtect()
	stopStorm()
	if screenGui and screenGui.Parent then screenGui:Destroy() end
	if restoreGui and restoreGui.Parent then restoreGui:Destroy() end
end)

-- NoClip button
noclipBtn.MouseButton1Click:Connect(function()
	if noclipOn then disableNoClip() else enableNoClip() end
end)

-- Walk speed toggle & set
walkToggle.MouseButton1Click:Connect(function()
	if speedModeOn then disableSpeedMode() else
		local n = tonumber(walkBox.Text) or speedValue
		enableSpeedMode(n)
	end
end)

-- Protect button (local)
protectBtn.MouseButton1Click:Connect(function()
	if protectedOn then disableProtect() else enableProtect() end
end)

-- Storm button
stormBtn.MouseButton1Click:Connect(function()
	if stormOn then stopStorm() else startStorm() end
end)

-- keyboard hotkeys: F toggles fly, N toggles noclip, P toggles protect, K toggles storm
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F then
		if flying then stopFly() else startFly() end
	elseif input.KeyCode == Enum.KeyCode.N then
		if noclipOn then disableNoClip() else enableNoClip() end
	elseif input.KeyCode == Enum.KeyCode.P then
		if protectedOn then disableProtect() else enableProtect() end
	elseif input.KeyCode == Enum.KeyCode.K then
		if stormOn then stopStorm() else startStorm() end
	end
end)

-- ensure humanoid exists on respawn, reapply states if needed
player.CharacterAdded:Connect(function(chr)
	character = chr
	humanoid = chr:WaitForChild("Humanoid")
	hrp = chr:WaitForChild("HumanoidRootPart")
	-- reapply modes that were on (best-effort; NoClip will re-disable collisions)
	if speedModeOn then pcall(function() humanoid.WalkSpeed = speedValue end) end
	if protectedOn then
		pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false) humanoid.MaxHealth = math.huge humanoid.Health = math.huge end)
	end
	if noclipOn then disableNoClip(); enableNoClip() end
end)

-- Initialize labels/colors
statusLabel.Text = "Fly: OFF"
walkLabel.Text = "Walk Speed: OFF"
flyToggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,52)
noclipBtn.BackgroundColor3 = Color3.fromRGB(45,45,52)
protectBtn.BackgroundColor3 = Color3.fromRGB(45,45,52)
stormBtn.BackgroundColor3 = Color3.fromRGB(45,45,52)
flySetBtn.BackgroundColor3 = Color3.fromRGB(6,150,130)
walkToggle.BackgroundColor3 = Color3.fromRGB(6,150,130)

-- End of script
