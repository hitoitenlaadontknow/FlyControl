-- 🕊️ Fly Control + God Mode GUI (Mobile + PC)
-- Put in StarterPlayerScripts (LocalScript)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Character Handling
local character = player.Character or player.CharacterAdded:Wait()
local function getRoot()
	character = player.Character or player.CharacterAdded:Wait()
	return character:WaitForChild("HumanoidRootPart")
end

local humanoidRootPart = getRoot()
player.CharacterAdded:Connect(function(char)
	character = char
	humanoidRootPart = getRoot()
end)

-- State
local flying = false
local flySpeed = 80
local minSpeed, maxSpeed = 10, 500
local disabled = false
local isMaximized = false
local isMinimized = false

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyControlGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 260, 0, 140)
frame.Position = UDim2.new(0.5, -130, 0.75, -55)
frame.BackgroundColor3 = Color3.fromRGB(34,34,46)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner"); uiCorner.CornerRadius = UDim.new(0,10); uiCorner.Parent = frame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,28)
header.BackgroundTransparency = 1
header.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, -8, 1, 0)
title.Position = UDim2.new(0,6,0,0)
title.BackgroundTransparency = 1
title.Text = "🕊️ Fly Control"
title.Font = Enum.Font.SourceSansSemibold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(230,230,230)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Buttons
local function makeBtn(txt, offset)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0,28,0,20)
	b.Position = UDim2.new(1, offset, 0, 4)
	b.Text = txt
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 16
	b.BackgroundTransparency = 0.15
	b.BackgroundColor3 = Color3.fromRGB(60,60,70)
	local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0,5)
	b.Parent = header
	return b
end

local btnMin = makeBtn("-", -92)
local btnMax = makeBtn("□", -60)
local btnClose = makeBtn("X", -32)

-- Labels
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,-12,0,28)
statusLabel.Position = UDim2.new(0,6,0,36)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Trạng thái: Đang Tắt"
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.fromRGB(255,180,180)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1,-12,0,18)
speedLabel.Position = UDim2.new(0,6,0,66)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Tốc độ: "..tostring(flySpeed)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 14
speedLabel.TextColor3 = Color3.fromRGB(200,200,200)
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = frame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 120, 0, 24)
speedBox.Position = UDim2.new(1, -132, 0, 66)
speedBox.BackgroundColor3 = Color3.fromRGB(20,20,25)
speedBox.TextColor3 = Color3.fromRGB(220,220,220)
speedBox.PlaceholderText = "Nhập tốc độ (10-500)"
speedBox.ClearTextOnFocus = false
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 14
speedBox.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -12, 0, 18)
infoLabel.Position = UDim2.new(0,6,0,94)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Nhấn F để bật/tắt. Enter để lưu tốc độ."
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 12
infoLabel.TextColor3 = Color3.fromRGB(160,160,160)
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = frame

-- Restore GUI
local restoreGui = Instance.new("ScreenGui")
restoreGui.Name = "FlyRestoreGUI"
restoreGui.ResetOnSpawn = false
restoreGui.Parent = player:WaitForChild("PlayerGui")

local restoreBtn = Instance.new("TextButton")
restoreBtn.Size = UDim2.new(0, 120, 0, 36)
restoreBtn.Position = UDim2.new(0.02, 0, 0.02, 0)
restoreBtn.Text = "Fly - Show"
restoreBtn.Font = Enum.Font.SourceSansBold
restoreBtn.TextSize = 16
restoreBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
restoreBtn.TextColor3 = Color3.fromRGB(230,230,230)
restoreBtn.Visible = false
restoreBtn.Parent = restoreGui
Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0,8)

-- 🛡️ God Mode Button
local protectButton = Instance.new("TextButton")
protectButton.Size = UDim2.new(0, 130, 0, 34)
protectButton.Position = UDim2.new(0.5, -65, 1, -45)
protectButton.AnchorPoint = Vector2.new(0.5, 1)
protectButton.Text = "🛡️ Bảo vệ: TẮT"
protectButton.Font = Enum.Font.SourceSansBold
protectButton.TextSize = 16
protectButton.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
protectButton.TextColor3 = Color3.fromRGB(255, 200, 200)
protectButton.Parent = frame
Instance.new("UICorner", protectButton).CornerRadius = UDim.new(0,8)

local protectOn = false
local glow = Instance.new("UIStroke")
glow.Thickness = 1.5
glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
glow.Color = Color3.fromRGB(255,100,100)
glow.Parent = protectButton

local function updateProtectButton()
	if protectOn then
		protectButton.BackgroundColor3 = Color3.fromRGB(50, 90, 50)
		protectButton.TextColor3 = Color3.fromRGB(180, 255, 180)
		protectButton.Text = "🟢 Bảo vệ: BẬT"
		glow.Color = Color3.fromRGB(120,255,120)
	else
		protectButton.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
		protectButton.TextColor3 = Color3.fromRGB(255, 200, 200)
		protectButton.Text = "🔴 Bảo vệ: TẮT"
		glow.Color = Color3.fromRGB(255,100,100)
	end
end

protectButton.MouseButton1Click:Connect(function()
	protectOn = not protectOn
	updateProtectButton()
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if protectOn then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
	else
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
		humanoid.MaxHealth = 100
		humanoid.Health = 100
	end
end)
updateProtectButton()

-- Functions
local function setStatus(isFlying)
	if isFlying then
		statusLabel.Text = "Trạng thái: Đang Bật"
		statusLabel.TextColor3 = Color3.fromRGB(120,255,120)
	else
		statusLabel.Text = "Trạng thái: Đang Tắt"
		statusLabel.TextColor3 = Color3.fromRGB(255,180,180)
	end
end
local function setSpeedLabel(v)
	speedLabel.Text = "Tốc độ: "..tostring(v)
end

-- Fly Logic
local bv, bg
local function startFlying()
	if disabled or flying then return end
	flying = true
	setStatus(true)

	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5,1e5,1e5)
	bv.Velocity = Vector3.zero
	bv.Parent = humanoidRootPart

	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
	bg.CFrame = humanoidRootPart.CFrame
	bg.Parent = humanoidRootPart

	task.spawn(function()
		while flying do
			task.wait()
			local move = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += workspace.CurrentCamera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= workspace.CurrentCamera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= workspace.CurrentCamera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += workspace.CurrentCamera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
			if move.Magnitude > 0 then move = move.Unit * flySpeed end
			bv.Velocity = move
			bg.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + workspace.CurrentCamera.CFrame.LookVector)
		end
	end)
end

local function stopFlying()
	flying = false
	setStatus(false)
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
end

-- GUI Controls
local function minimize()
	isMinimized = true
	frame.Size = UDim2.new(0, 140, 0, 34)
	for _,v in pairs(frame:GetChildren()) do
		if v ~= header then v.Visible = false end
	end
	restoreBtn.Visible = true
end

local function restore()
	isMinimized = false
	frame.Size = isMaximized and UDim2.new(0, 520, 0, 220) or UDim2.new(0, 260, 0, 140)
	for _,v in pairs(frame:GetChildren()) do
		v.Visible = true
	end
	restoreBtn.Visible = false
end

local function maximize()
	isMaximized = not isMaximized
	frame.Size = isMaximized and UDim2.new(0, 520, 0, 220) or UDim2.new(0, 260, 0, 140)
end

local function closeAll()
	stopFlying()
	screenGui:Destroy()
	restoreGui:Destroy()
end

btnMin.MouseButton1Click:Connect(minimize)
restoreBtn.MouseButton1Click:Connect(restore)
btnMax.MouseButton1Click:Connect(maximize)
btnClose.MouseButton1Click:Connect(closeAll)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or disabled then return end
	if input.KeyCode == Enum.KeyCode.F then
		if flying then stopFlying() else startFlying() end
	end
end)

-- Speed Box
speedBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed or disabled then return end
	local num = tonumber(speedBox.Text)
	if not num then
		infoLabel.Text = "Giá trị không hợp lệ!"
		task.delay(2, function() infoLabel.Text = "Nhấn F để bật/tắt. Enter để lưu tốc độ." end)
		return
	end
	num = math.clamp(math.floor(num), minSpeed, maxSpeed)
	flySpeed = num
	setSpeedLabel(flySpeed)
	infoLabel.Text = "Đã cập nhật tốc độ: "..tostring(flySpeed)
	task.delay(2, function() infoLabel.Text = "Nhấn F để bật/tắt. Enter để lưu tốc độ." end)
end)

setStatus(false)
setSpeedLabel(flySpeed)
