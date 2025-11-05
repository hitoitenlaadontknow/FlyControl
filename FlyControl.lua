--//===[ FlyControl + Noclip + Speed + GodMode + FakeStorm GUI ]===--

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
Frame.Size = UDim2.new(0, 220, 0, 260)
Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

local Title = Instance.new("TextLabel", Frame)
Title.Text = "⚡ Power Control ⚡"
Title.Size = UDim2.new(1, 0, 0, 40)
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
local flying = false
local speed = 50
local noclip = false
local god = false
local fakeStormOn = false
local BodyGyro, BodyVel

--// Fly toggle
local FlyBtn = CreateButton("Fly: OFF", Color3.fromRGB(55, 55, 55))
FlyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	FlyBtn.Text = flying and "Fly: ON" or "Fly: OFF"
	FlyBtn.BackgroundColor3 = flying and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(55, 55, 55)
	if flying then
		BodyGyro = Instance.new("BodyGyro", hrp)
		BodyVel = Instance.new("BodyVelocity", hrp)
		BodyGyro.P = 9e4
		BodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
		BodyVel.MaxForce = Vector3.new(9e4, 9e4, 9e4)
	else
		if BodyGyro then BodyGyro:Destroy() end
		if BodyVel then BodyVel:Destroy() end
	end
end)

RS.RenderStepped:Connect(function()
	if flying and BodyGyro and BodyVel then
		BodyGyro.CFrame = workspace.CurrentCamera.CFrame
		BodyVel.Velocity = workspace.CurrentCamera.CFrame.LookVector * speed
	end
end)

--// Speed toggle
local SpeedBtn = CreateButton("Speed: OFF", Color3.fromRGB(55, 55, 55))
SpeedBtn.MouseButton1Click:Connect(function()
	if hum.WalkSpeed < 1000 then
		hum.WalkSpeed = 1000
		SpeedBtn.Text = "Speed: 1000"
		SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
	else
		hum.WalkSpeed = 16
		SpeedBtn.Text = "Speed: OFF"
		SpeedBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	end
end)

--// Noclip toggle
local NoclipBtn = CreateButton("Noclip: OFF", Color3.fromRGB(55, 55, 55))
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
	NoclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(55, 55, 55)
end)

--// God Mode toggle
local GodBtn = CreateButton("God Mode: OFF", Color3.fromRGB(55, 55, 55))
GodBtn.MouseButton1Click:Connect(function()
	god = not god
	GodBtn.Text = god and "God Mode: ON" or "God Mode: OFF"
	GodBtn.BackgroundColor3 = god and Color3.fromRGB(255, 0, 85) or Color3.fromRGB(55, 55, 55)
	if god then
		task.spawn(function()
			while god do
				hum.Health = math.huge
				task.wait(0.2)
			end
		end)
	end
end)

--// Fake Storm (visual only)
local StormBtn = CreateButton("Fake Storm: OFF", Color3.fromRGB(55, 55, 55))
StormBtn.MouseButton1Click:Connect(function()
	fakeStormOn = not fakeStormOn
	StormBtn.Text = fakeStormOn and "Fake Storm: ON" or "Fake Storm: OFF"
	StormBtn.BackgroundColor3 = fakeStormOn and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(55, 55, 55)

	if fakeStormOn then
		local emitter = Instance.new("ParticleEmitter", hrp)
		emitter.Texture = "rbxassetid://241837157" -- hiệu ứng gió/lá bay
		emitter.Rate = 80
		emitter.Speed = NumberRange.new(15, 30)
		emitter.Size = NumberSequence.new(0.5)
		emitter.Lifetime = NumberRange.new(2, 4)
		emitter.VelocitySpread = 360
		emitter.Color = ColorSequence.new(Color3.fromRGB(180, 200, 255))
		task.spawn(function()
			while fakeStormOn do
				wait(0.5)
			end
			emitter.Enabled = false
			task.wait(1)
			emitter:Destroy()
		end)
	end
end)

print("⚡ FlyControl+Noclip+Speed+GodMode+FakeStorm Loaded Successfully!")
