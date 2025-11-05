--//===[ Power Control GUI: Fly + Speed + Noclip + God + ESP Advanced ]===--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

--// GUI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "PowerControlUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 350)
Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

--// Top buttons (-, 🔍, x)
local function CreateTopButton(text, pos)
	local btn = Instance.new("TextButton", Frame)
	btn.Text = text
	btn.Size = UDim2.new(0, 30, 0, 25)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	Instance.new("UICorner", btn)
	btn.AutoButtonColor = true
	return btn
end

local HideBtn = CreateTopButton("-", UDim2.new(0, 5, 0, 5))
local ResizeBtn = CreateTopButton("🔍", UDim2.new(0, 40, 0, 5))
local CloseBtn = CreateTopButton("x", UDim2.new(0, 75, 0, 5))

HideBtn.MouseButton1Click:Connect(function() Frame.Visible = false end)
ResizeBtn.MouseButton1Click:Connect(function()
	if Frame.Size == UDim2.new(0,220,0,350) then
		Frame.Size = UDim2.new(0,110,0,175)
	else
		Frame.Size = UDim2.new(0,220,0,350)
	end
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Title = Instance.new("TextLabel", Frame)
Title.Text = "⚡ Power Control ⚡"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0,0,0,30)
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Frame)
UIList.Padding = UDim.new(0, 10)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.VerticalAlignment = Enum.VerticalAlignment.Top
UIList.FillDirection = Enum.FillDirection.Vertical
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)

--// Helper for buttons
local function CreateButton(name, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 35)
	btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 16
	btn.Text = name
	btn.Parent = Frame
	Instance.new("UICorner", btn)
	btn.AutoButtonColor = true
	return btn
end

--// Variables
local flying, noclip, god, espEnabled = false, false, false, false
local BodyGyro, BodyVel
local flyVelocity = Vector3.new(0,0,0)
local acceleration = 3
local flySpeed = 50
local keys = {W=false,A=false,S=false,D=false,Space=false,Shift=false}
local espBoxes = {}

--// Input
UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.W then keys.W = true end
	if input.KeyCode == Enum.KeyCode.A then keys.A = true end
	if input.KeyCode == Enum.KeyCode.S then keys.S = true end
	if input.KeyCode == Enum.KeyCode.D then keys.D = true end
	if input.KeyCode == Enum.KeyCode.Space then keys.Space = true end
	if input.KeyCode == Enum.KeyCode.LeftShift then keys.Shift = true end
end)
UIS.InputEnded:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.W then keys.W = false end
	if input.KeyCode == Enum.KeyCode.A then keys.A = false end
	if input.KeyCode == Enum.KeyCode.S then keys.S = false end
	if input.KeyCode == Enum.KeyCode.D then keys.D = false end
	if input.KeyCode == Enum.KeyCode.Space then keys.Space = false end
	if input.KeyCode == Enum.KeyCode.LeftShift then keys.Shift = false end
end)

--// Fly
local FlyBtn = CreateButton("Fly: OFF", Color3.fromRGB(55,55,55))
local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(0.9,0,0,30)
SpeedBox.PlaceholderText = "Fly Speed: 50"
SpeedBox.ClearTextOnFocus = false
SpeedBox.Text = ""
SpeedBox.TextColor3 = Color3.fromRGB(255,255,255)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.TextSize = 16
Instance.new("UICorner", SpeedBox)

FlyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	FlyBtn.Text = flying and "Fly: ON" or "Fly: OFF"
	FlyBtn.BackgroundColor3 = flying and Color3.fromRGB(0,170,255) or Color3.fromRGB(55,55,55)
	if flying then
		BodyGyro = Instance.new("BodyGyro", hrp)
		BodyVel = Instance.new("BodyVelocity", hrp)
		BodyGyro.P = 9e4
		BodyGyro.MaxTorque = Vector3.new(9e4,9e4,9e4)
		BodyVel.MaxForce = Vector3.new(9e4,9e4,9e4)
	else
		if BodyGyro then BodyGyro:Destroy() end
		if BodyVel then BodyVel:Destroy() end
		flyVelocity = Vector3.new(0,0,0)
	end
end)

SpeedBox.FocusLost:Connect(function(enter)
	local val = tonumber(SpeedBox.Text)
	if val then
		flySpeed = val
		SpeedBox.PlaceholderText = "Fly Speed: "..flySpeed
	end
	SpeedBox.Text = ""
end)

--// WalkSpeed
local SpeedBtn = CreateButton("Speed: OFF", Color3.fromRGB(55,55,55))
SpeedBtn.MouseButton1Click:Connect(function()
	if hum.WalkSpeed < 1000 then
		hum.WalkSpeed = 1000
		SpeedBtn.Text = "Speed: 1000"
		SpeedBtn.BackgroundColor3 = Color3.fromRGB(0,255,127)
	else
		hum.WalkSpeed = 16
		SpeedBtn.Text = "Speed: OFF"
		SpeedBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
	end
end)

--// Noclip
local NoclipBtn = CreateButton("Noclip: OFF", Color3.fromRGB(55,55,55))
RS.Stepped:Connect(function()
	if noclip and char then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
end)
NoclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	NoclipBtn.Text = noclip and "Noclip: ON" or "Noclip: OFF"
	NoclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(255,170,0) or Color3.fromRGB(55,55,55)
end)

--// God Mode
local GodBtn = CreateButton("God Mode: OFF", Color3.fromRGB(55,55,55))
GodBtn.MouseButton1Click:Connect(function()
	god = not god
	GodBtn.Text = god and "God Mode: ON" or "God Mode: OFF"
	GodBtn.BackgroundColor3 = god and Color3.fromRGB(255,0,85) or Color3.fromRGB(55,55,55)
	if god then
		task.spawn(function()
			while god do
				hum.Health = math.huge
				task.wait(0.2)
			end
		end)
	end
end)

--// ESP Advanced
local ESPBtn = CreateButton("ESP: OFF", Color3.fromRGB(55,55,55))
ESPBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	ESPBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
	ESPBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(255,255,0) or Color3.fromRGB(55,55,55)

	if not espEnabled then
		for _, info in pairs(espBoxes) do
			if info.Box then info.Box:Destroy() end
			if info.Text then info.Text.Parent:Destroy() end
		end
		espBoxes = {}
	end
end)

local function createESP(targetChar)
	if espBoxes[targetChar] then return espBoxes[targetChar] end
	local part = targetChar:FindFirstChild("HumanoidRootPart")
	if not part then return end

	-- Box
	local box = Instance.new("BoxHandleAdornment")
	box.Adornee = part
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Size = Vector3.new(2,5,1)
	box.Transparency = 0.5
	box.Color3 = targetChar:FindFirstChildOfClass("Humanoid") and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
	box.Parent = targetChar

	-- BillboardGui: tên + khoảng cách
	local bill = Instance.new("BillboardGui", part)
	bill.Adornee = part
	bill.AlwaysOnTop = true
	bill.Size = UDim2.new(0,100,0,50)
	bill.StudsOffset = Vector3.new(0,3,0)
	local txt = Instance.new("TextLabel", bill)
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.fromRGB(255,255,0)
	txt.Font = Enum.Font.GothamBold
	txt.TextSize = 14
	txt.Text = targetChar.Name

	espBoxes[targetChar] = {Box = box, Text = txt}
	return espBoxes[targetChar]
end

--// Main loop
RS.RenderStepped:Connect(function(delta)
	-- Fly
	if flying and BodyGyro and BodyVel then
		local camCFrame = workspace.CurrentCamera.CFrame
		BodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camCFrame.LookVector)
		local move = Vector3.new(0,0,0)
		if keys.W then move = move + camCFrame.LookVector end
		if keys.S then move = move - camCFrame.LookVector end
		if keys.A then move = move - camCFrame.RightVector end
		if keys.D then move = move + camCFrame.RightVector end
		if keys.Space then move = move + Vector3.new(0,1,0) end
		if keys.Shift then move = move - Vector3.new(0,1,0) end
		move = move.Unit
		if move ~= move then move = Vector3.new(0,0,0) end
		flyVelocity = flyVelocity:Lerp(move * flySpeed, acceleration * delta)
		BodyVel.Velocity = flyVelocity
	end

	-- ESP
	if espEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local info = createESP(plr.Character)
				if info and info.Text then
					local dist = math.floor((hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude)
					info.Text.Text = plr.Name.." | "..dist.." studs"
					local teamColor = plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255,255,0)
					info.Box.Color3 = teamColor
					info.Text.TextColor3 = teamColor
				end
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if espBoxes[plr.Character] then
		if espBoxes[plr.Character].Box then espBoxes[plr.Character].Box:Destroy() end
		if espBoxes[plr.Character].Text then espBoxes[plr.Character].Text.Parent:Destroy() end
		espBoxes[plr.Character] = nil
	end
end)

print("⚡ PowerControl GUI Full Loaded Successfully!")
