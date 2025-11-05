-- Fly Control with minimize, restore bar, maximize and close (LocalScript)
-- Put in StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- character handling
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

-- state
local flying = false
local flySpeed = 80
local minSpeed, maxSpeed = 10, -1
local disabled = false -- when true, script stops and GUI removed
local isMaximized = false
local isMinimized = false

-- create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyControlGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- main frame
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 260, 0, 110)
frame.Position = UDim2.new(0.5, -130, 0.78, -55)
frame.BackgroundColor3 = Color3.fromRGB(34,34,46)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner"); uiCorner.CornerRadius = UDim.new(0,10); uiCorner.Parent = frame

-- header (title + control buttons)
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,28)
header.Position = UDim2.new(0,0,0,0)
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

-- minimize button "-"
local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 28, 0, 20)
btnMin.Position = UDim2.new(1, -92, 0, 4)
btnMin.AnchorPoint = Vector2.new(0,0)
btnMin.Text = "-"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 18
btnMin.BackgroundTransparency = 0.15
btnMin.Parent = header

-- maximize button "□"
local btnMax = Instance.new("TextButton")
btnMax.Size = UDim2.new(0, 28, 0, 20)
btnMax.Position = UDim2.new(1, -60, 0, 4)
btnMax.Text = "□"
btnMax.Font = Enum.Font.SourceSansBold
btnMax.TextSize = 14
btnMax.BackgroundTransparency = 0.15
btnMax.Parent = header

-- close button "X" (disable script)
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 28, 0, 20)
btnClose.Position = UDim2.new(1, -32, 0, 4)
btnClose.Text = "X"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 14
btnClose.BackgroundTransparency = 0.15
btnClose.Parent = header

-- status & speed labels and input (body)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -12, 0, 28)
statusLabel.Position = UDim2.new(0,6,0,36)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Trạng thái: Đang Tắt"
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.fromRGB(255,180,180)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -12, 0, 18)
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
infoLabel.Position = UDim2.new(0,6,0,86)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Nhấn F để bật/tắt. Enter để lưu tốc độ."
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 12
infoLabel.TextColor3 = Color3.fromRGB(160,160,160)
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = frame

-- small restore GUI (shown when minimized)
local restoreGui = Instance.new("ScreenGui")
restoreGui.Name = "FlyRestoreGUI"
restoreGui.ResetOnSpawn = false
restoreGui.Parent = player:WaitForChild("PlayerGui")

local restoreBtn = Instance.new("TextButton")
restoreBtn.Name = "RestoreButton"
restoreBtn.Size = UDim2.new(0, 120, 0, 36)
restoreBtn.Position = UDim2.new(0.02, 0, 0.02, 0)
restoreBtn.AnchorPoint = Vector2.new(0,0)
restoreBtn.Text = "Fly - Show"
restoreBtn.Font = Enum.Font.SourceSansBold
restoreBtn.TextSize = 16
restoreBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
restoreBtn.TextColor3 = Color3.fromRGB(230,230,230)
restoreBtn.Visible = false -- start hidden
restoreBtn.Parent = restoreGui

local restoreCorner = Instance.new("UICorner"); restoreCorner.CornerRadius = UDim.new(0,8); restoreCorner.Parent = restoreBtn

-- helper functions
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

-- fly logic
local bv, bg -- will hold instances when flying
local function startFlying()
    if disabled then return end
    if flying then return end
    flying = true
    setStatus(true)

    if not humanoidRootPart or not humanoidRootPart.Parent then
        humanoidRootPart = getRoot()
    end

    bv = Instance.new("BodyVelocity")
    bv.Name = "FlyVelocity"
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = humanoidRootPart

    bg = Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bg.CFrame = humanoidRootPart.CFrame
    bg.Parent = humanoidRootPart

    task.spawn(function()
        while flying and bv and bg and bv.Parent and bg.Parent do
            task.wait()
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

            if move.Magnitude > 0 then
                move = move.Unit * flySpeed
            else
                move = Vector3.zero
            end

            if bv then bv.Velocity = move end
            if bg then
                local camCf = workspace.CurrentCamera.CFrame
                bg.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + camCf.LookVector)
            end
        end
    end)
end

local function stopFlying()
    if not flying then return end
    flying = false
    setStatus(false)
    if bv and bv.Parent then bv:Destroy() end
    if bg and bg.Parent then bg:Destroy() end
    bv, bg = nil, nil
end

-- minimize / restore behavior
local function minimize()
    if isMinimized then return end
    isMinimized = true
    -- hide content except header -> reduce frame height
    frame.Size = UDim2.new(0, 140, 0, 34)
    -- hide body children (status, labels, speedBox, info)
    statusLabel.Visible = false
    speedLabel.Visible = false
    speedBox.Visible = false
    infoLabel.Visible = false
    -- show restore button GUI
    restoreBtn.Visible = true
end

local function restore()
    if not isMinimized then return end
    isMinimized = false
    frame.Size = isMaximized and UDim2.new(0, 520, 0, 220) or UDim2.new(0, 260, 0, 110)
    statusLabel.Visible = true
    speedLabel.Visible = true
    speedBox.Visible = true
    infoLabel.Visible = true
    restoreBtn.Visible = false
end

-- maximize / unmaximize
local function maximize()
    if isMaximized then
        -- unmaximize
        isMaximized = false
        frame.Size = UDim2.new(0, 260, 0, 110)
        -- adjust font sizes (optional)
        title.TextSize = 16
        statusLabel.TextSize = 14
        speedLabel.TextSize = 14
    else
        -- maximize
        isMaximized = true
        frame.Size = UDim2.new(0, 520, 0, 220)
        title.TextSize = 20
        statusLabel.TextSize = 18
        speedLabel.TextSize = 18
    end
end

-- disable/close script
local function closeAll()
    -- stop flying if active
    stopFlying()
    disabled = true
    -- destroy GUIs
    if screenGui and screenGui.Parent then screenGui:Destroy() end
    if restoreGui and restoreGui.Parent then restoreGui:Destroy() end
    -- unbind any state if needed (we won't disconnect InputBegan listener here because it's local and lightweight;
    --  but disabled flag prevents further action)
end

-- connect UI buttons
btnMin.MouseButton1Click:Connect(function()
    minimize()
end)
restoreBtn.MouseButton1Click:Connect(function()
    restore()
end)
btnMax.MouseButton1Click:Connect(function()
    maximize()
end)
btnClose.MouseButton1Click:Connect(function()
    closeAll()
end)

-- toggle by F key
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or disabled then return end
    if input.KeyCode == Enum.KeyCode.F then
        if flying then
            stopFlying()
        else
            startFlying()
        end
    end
end)

-- speed input handling
speedBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed or disabled then return end
    local txt = speedBox.Text or ""
    local num = tonumber(txt)
    if not num then
        infoLabel.Text = "Giá trị không hợp lệ. Nhập số."
        task.delay(2, function() if infoLabel then infoLabel.Text = "Nhấn F để bật/tắt. Enter để lưu tốc độ." end end)
        return
    end
    num = math.clamp(math.floor(num), minSpeed, maxSpeed)
    flySpeed = num
    setSpeedLabel(flySpeed)
    infoLabel.Text = "Đã cập nhật tốc độ: "..tostring(flySpeed)
    task.delay(2, function() if infoLabel then infoLabel.Text = "Nhấn F để bật/tắt. Enter để lưu tốc độ." end end)
end)

-- initialize labels
setStatus(false)
setSpeedLabel(flySpeed)

-- cleanup safety: if player leaves or script disabled, ensure objects removed
player.AncestryChanged:Connect(function(_, parent)
    if not parent then
        closeAll()
    end
end)
