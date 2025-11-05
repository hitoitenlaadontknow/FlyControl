--// ✦ Fly + Bảo Vệ + Speed GUI by hiMN_016 ✦
-- Hợp pháp – không bypass, không chỉnh server, chỉ dùng trong game của bạn.

-- Xóa GUI cũ nếu có
local player = game.Players.LocalPlayer
if player:WaitForChild("PlayerGui"):FindFirstChild("FlySystem") then
	player.PlayerGui.FlySystem:Destroy()
end

-- Tạo GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FlySystem"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Khung chính
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 260)
frame.Position = UDim2.new(0.5, -150, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Hiệu ứng GUI
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 15)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 200)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local shadow = Instance.new("ImageLabel", frame)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 255, 200)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Size = UDim2.new(1, 15, 1, 15)
shadow.Position = UDim2.new(0, -8, 0, -8)
shadow.ZIndex = -1

-- Tiêu đề
local title = Instance.new("TextLabel", frame)
title.Text = "🌌 Fly Control System"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

-- Nút thu nhỏ
local minimize = Instance.new("TextButton", frame)
minimize.Text = "-"
minimize.Size = UDim2.new(0, 35, 0, 35)
minimize.Position = UDim2.new(1, -40, 0, 0)
minimize.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 22
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 8)

-- Ô nhập tốc độ
local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Nhập tốc độ bay..."
speedBox.Text = ""
speedBox.Size = UDim2.new(1, -40, 0, 35)
speedBox.Position = UDim2.new(0, 20, 0, 50)
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 16
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

-- Nút cập nhật tốc độ
local setSpeed = Instance.new("TextButton", frame)
setSpeed.Text = "⚙️ Cập nhật tốc độ"
setSpeed.Size = UDim2.new(1, -40, 0, 35)
setSpeed.Position = UDim2.new(0, 20, 0, 95)
setSpeed.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
setSpeed.TextColor3 = Color3.new(1, 1, 1)
setSpeed.Font = Enum.Font.GothamBold
setSpeed.TextSize = 17
Instance.new("UICorner", setSpeed).CornerRadius = UDim.new(0, 8)

-- Nút Fly
local flyButton = Instance.new("TextButton", frame)
flyButton.Text = "✈️ Fly: OFF"
flyButton.Size = UDim2.new(1, -40, 0, 40)
flyButton.Position = UDim2.new(0, 20, 0, 140)
flyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.Font = Enum.Font.GothamBold
flyButton.TextSize = 18
Instance.new("UICorner", flyButton).CornerRadius = UDim.new(0, 8)

-- Nút bảo vệ
local protectButton = Instance.new("TextButton", frame)
protectButton.Text = "🛡️ Bảo vệ: TẮT"
protectButton.Size = UDim2.new(1, -40, 0, 40)
protectButton.Position = UDim2.new(0, 20, 0, 190)
protectButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
protectButton.TextColor3 = Color3.new(1, 1, 1)
protectButton.Font = Enum.Font.GothamBold
protectButton.TextSize = 18
Instance.new("UICorner", protectButton).CornerRadius = UDim.new(0, 8)

-- Nút hiển thị lại GUI
local showButton = Instance.new("TextButton", gui)
showButton.Text = "🌌 Mở lại GUI"
showButton.Size = UDim2.new(0, 150, 0, 40)
showButton.Position = UDim2.new(0, 30, 1, -70)
showButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
showButton.TextColor3 = Color3.fromRGB(0, 255, 200)
showButton.Font = Enum.Font.GothamBold
showButton.TextSize = 16
Instance.new("UICorner", showButton).CornerRadius = UDim.new(0, 10)
showButton.Visible = false

-- Biến
local flying = false
local protect = false
local speed = 60
local hum = player.Character:WaitForChild("Humanoid")
local hrp = player.Character:WaitForChild("HumanoidRootPart")

-- Tốc độ
setSpeed.MouseButton1Click:Connect(function()
	local val = tonumber(speedBox.Text)
	if val then
		speed = val
		setSpeed.Text = "✅ Tốc độ: " .. speed
		task.wait(1.5)
		setSpeed.Text = "⚙️ Cập nhật tốc độ"
	else
		setSpeed.Text = "❌ Không hợp lệ"
		task.wait(1)
		setSpeed.Text = "⚙️ Cập nhật tốc độ"
	end
end)

-- Fly toggle
flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		flyButton.Text = "✈️ Fly: ON"
		flyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
		local bv = Instance.new("BodyVelocity", hrp)
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		game:GetService("RunService").Heartbeat:Connect(function()
			if flying then
				local move = Vector3.new()
				local uis = game:GetService("UserInputService")
				if uis:IsKeyDown(Enum.KeyCode.W) then move += workspace.CurrentCamera.CFrame.LookVector end
				if uis:IsKeyDown(Enum.KeyCode.S) then move -= workspace.CurrentCamera.CFrame.LookVector end
				if uis:IsKeyDown(Enum.KeyCode.A) then move -= workspace.CurrentCamera.CFrame.RightVector end
				if uis:IsKeyDown(Enum.KeyCode.D) then move += workspace.CurrentCamera.CFrame.RightVector end
				bv.Velocity = move * speed
			else
				bv:Destroy()
			end
		end)
	else
		flyButton.Text = "✈️ Fly: OFF"
		flyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	end
end)

-- Bảo vệ toggle
protectButton.MouseButton1Click:Connect(function()
	protect = not protect
	if protect then
		protectButton.Text = "🛡️ Bảo vệ: BẬT"
		protectButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		hum.Health = hum.MaxHealth
	else
		protectButton.Text = "🛡️ Bảo vệ: TẮT"
		protectButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
	end
end)

-- Ẩn / hiện GUI
minimize.MouseButton1Click:Connect(function()
	frame.Visible = false
	showButton.Visible = true
end)
showButton.MouseButton1Click:Connect(function()
	frame.Visible = true
	showButton.Visible = false
end)
