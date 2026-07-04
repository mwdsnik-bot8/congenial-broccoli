-- Скрипт для Delta Executor Mobile
-- С автоматическим телепортом по интервалу в миллисекундах
-- + Автоматическая скорость 200, Noclip, Infinite Jump
-- + GUI не пропадает после смерти
-- + ЧЕРНЫЙ ФОН + ручной ввод интервала
-- + ВСЕ В ОДНУ СТРОКУ (горизонтальный интерфейс)
-- + Orca Hub, Infinite Yield, SP Hub (Brookhaven RP)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local savedPosition = nil
local guiEnabled = true
local autoTeleportActive = false
local autoTeleportInterval = 5000
local autoTeleportCoroutine = nil

-- NOCLIP И INFINITE JUMP
local noclipEnabled = true
local infiniteJumpEnabled = true
local walkSpeed = 200

local function setNoclip(state)
    noclipEnabled = state
    print(state and "✅ Noclip ВКЛЮЧЕН" or "❌ Noclip ВЫКЛЮЧЕН")
end

local function setInfiniteJump(state)
    infiniteJumpEnabled = state
    print(state and "✅ Infinite Jump ВКЛЮЧЕН" or "❌ Infinite Jump ВЫКЛЮЧЕН")
end

local function setWalkSpeed(speed)
    walkSpeed = speed
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = speed end
    end
    print("✅ Скорость установлена на " .. speed)
end

local noclipConnection
local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        local char = player.Character
        if not char then return end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function setupInfiniteJump()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    humanoid.WalkSpeed = walkSpeed
    if char:GetAttribute("JumpConnection") then
        local oldConn = char:GetAttribute("JumpConnection")
        if oldConn then pcall(function() oldConn:Disconnect() end) end
    end
    local jumpConnection = humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
        if humanoid.Jump and infiniteJumpEnabled then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Velocity = Vector3.new(rootPart.Velocity.X, 50, rootPart.Velocity.Z)
            end
        end
    end)
    char:SetAttribute("JumpConnection", jumpConnection)
end

-- ===== ФУНКЦИИ ЭМУЛЯЦИИ КЛАВИШ =====
local function pressKey(key)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end

-- ===== ORCA HUB =====
local orcaVisible = true
local orcaGui = nil

local function toggleOrca()
    if not orcaGui then
        for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
            if gui.Name == "Orca" or gui.Name == "OrcaHub" then
                orcaGui = gui
                break
            end
        end
        if not orcaGui then
            for _, gui in pairs(player.PlayerGui:GetChildren()) do
                if gui.Name == "Orca" or gui.Name == "OrcaHub" then
                    orcaGui = gui
                    break
                end
            end
        end
    end
    
    if orcaGui then
        orcaVisible = not orcaVisible
        orcaGui.Enabled = orcaVisible
        print(orcaVisible and "✅ Orca Hub показан" or "❌ Orca Hub скрыт")
        if orcaVisible then
            animateButton(orcaButton, Color3.fromRGB(0, 200, 100))
            orcaButton.Text = "🐚 ON"
        else
            animateButton(orcaButton, Color3.fromRGB(255, 50, 50))
            orcaButton.Text = "🐚 OFF"
        end
    else
        print("⚠️ Orca Hub не найден")
        animateButton(orcaButton, Color3.fromRGB(255, 200, 0))
        orcaButton.Text = "🐚 !"
        task.wait(1)
        animateButton(orcaButton, Color3.fromRGB(0, 200, 255))
        orcaButton.Text = "🐚 Orca"
    end
end

-- ===== INFINITE YIELD =====
local iyVisible = true
local iyGui = nil

local function toggleIY()
    if not iyGui then
        for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
            if gui.Name == "InfiniteYield" or gui:FindFirstChild("Main") then
                iyGui = gui
                break
            end
        end
        if not iyGui then
            for _, gui in pairs(player.PlayerGui:GetChildren()) do
                if gui.Name == "InfiniteYield" or gui:FindFirstChild("Main") then
                    iyGui = gui
                    break
                end
            end
        end
    end
    
    if iyGui then
        iyVisible = not iyVisible
        iyGui.Enabled = iyVisible
        print(iyVisible and "✅ Infinite Yield показан" or "❌ Infinite Yield скрыт")
        if iyVisible then
            animateButton(iyButton, Color3.fromRGB(0, 200, 100))
            iyButton.Text = "⚡ ON"
        else
            animateButton(iyButton, Color3.fromRGB(255, 50, 50))
            iyButton.Text = "⚡ OFF"
        end
    else
        print("⚠️ Infinite Yield не найден")
        animateButton(iyButton, Color3.fromRGB(255, 200, 0))
        iyButton.Text = "⚡ !"
        task.wait(1)
        animateButton(iyButton, Color3.fromRGB(255, 69, 0))
        iyButton.Text = "⚡ IY"
    end
end

-- ===== SP HUB (BROOKHAVEN) =====
local spVisible = true
local spGui = nil

local function toggleSP()
    if not spGui then
        for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
            if gui.Name == "SPHub" or gui:FindFirstChild("SPHub") then
                spGui = gui
                break
            end
        end
        if not spGui then
            for _, gui in pairs(player.PlayerGui:GetChildren()) do
                if gui.Name == "SPHub" or gui:FindFirstChild("SPHub") then
                    spGui = gui
                    break
                end
            end
        end
    end
    
    if spGui then
        spVisible = not spVisible
        spGui.Enabled = spVisible
        print(spVisible and "✅ SP Hub показан" or "❌ SP Hub скрыт")
        if spVisible then
            animateButton(spButton, Color3.fromRGB(0, 200, 100))
            spButton.Text = "🎮 ON"
        else
            animateButton(spButton, Color3.fromRGB(255, 50, 50))
            spButton.Text = "🎮 OFF"
        end
    else
        -- Если SP Hub не найден, эмулируем нажатие K (способ открытия SP Hub)
        print("⚠️ SP Hub не найден, эмулируем нажатие K")
        pressKey(Enum.KeyCode.K)
        animateButton(spButton, Color3.fromRGB(255, 200, 0))
        spButton.Text = "🎮 K"
        task.wait(1)
        animateButton(spButton, Color3.fromRGB(255, 0, 255))
        spButton.Text = "🎮 SP"
    end
end

-- СОЗДАНИЕ GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaTeleport"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local success, err = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)

if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- ОСНОВНОЙ ФРЕЙМ - ЧЕРНЫЙ ФОН
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 850, 0, 50)
mainFrame.Position = UDim2.new(0.5, -425, 0.85, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 150, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.3
stroke.Parent = mainFrame

-- ВСЕ КНОПКИ В ОДНОЙ ПАНЕЛИ
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(1, 0, 1, 0)
mainPanel.Position = UDim2.new(0, 0, 0, 0)
mainPanel.BackgroundTransparency = 1
mainPanel.Parent = mainFrame

-- SWP
local saveButton = Instance.new("TextButton")
saveButton.Size = UDim2.new(0, 45, 0, 35)
saveButton.Position = UDim2.new(0, 5, 0.5, -17.5)
saveButton.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
saveButton.Text = "SWP"
saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveButton.TextSize = 10
saveButton.Font = Enum.Font.GothamBold
saveButton.AutoButtonColor = false
saveButton.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
Instance.new("UICorner").Parent = saveButton

-- TWP
local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 45, 0, 35)
teleportButton.Position = UDim2.new(0, 55, 0.5, -17.5)
teleportButton.BackgroundColor3 = Color3.fromRGB(255, 69, 0)
teleportButton.Text = "TWP"
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.TextSize = 10
teleportButton.Font = Enum.Font.GothamBold
teleportButton.AutoButtonColor = false
teleportButton.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
Instance.new("UICorner").Parent = teleportButton

-- ATP
local autoButton = Instance.new("TextButton")
autoButton.Size = UDim2.new(0, 45, 0, 35)
autoButton.Position = UDim2.new(0, 105, 0.5, -17.5)
autoButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
autoButton.Text = "ATP"
autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoButton.TextSize = 10
autoButton.Font = Enum.Font.GothamBold
autoButton.AutoButtonColor = false
autoButton.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
Instance.new("UICorner").Parent = autoButton

-- NC
local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(0, 35, 0, 35)
noclipButton.Position = UDim2.new(0, 155, 0.5, -17.5)
noclipButton.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
noclipButton.Text = "NC"
noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipButton.TextSize = 10
noclipButton.Font = Enum.Font.GothamBold
noclipButton.AutoButtonColor = false
noclipButton.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
Instance.new("UICorner").Parent = noclipButton

-- IJ
local jumpButton = Instance.new("TextButton")
jumpButton.Size = UDim2.new(0, 30, 0, 35)
jumpButton.Position = UDim2.new(0, 195, 0.5, -17.5)
jumpButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
jumpButton.Text = "IJ"
jumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpButton.TextSize = 10
jumpButton.Font = Enum.Font.GothamBold
jumpButton.AutoButtonColor = false
jumpButton.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
Instance.new("UICorner").Parent = jumpButton

-- Speed
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0, 35, 0, 35)
speedButton.Position = UDim2.new(0, 230, 0.5, -17.5)
speedButton.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
speedButton.Text = "200"
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.TextSize = 10
speedButton.Font = Enum.Font.GothamBold
speedButton.AutoButtonColor = false
speedButton.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
Instance.new("UICorner").Parent = speedButton

-- Кнопка Orca Hub
local orcaButton = Instance.new("TextButton")
orcaButton.Size = UDim2.new(0, 45, 0, 35)
orcaButton.Position = UDim2.new(0, 270, 0.5, -17.5)
orcaButton.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
orcaButton.Text = "🐚 Orca"
orcaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
orcaButton.TextSize = 9
orcaButton.Font = Enum.Font.GothamBold
orcaButton.AutoButtonColor = false
orcaButton.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
Instance.new("UICorner").Parent = orcaButton

-- Кнопка Infinite Yield
local iyButton = Instance.new("TextButton")
iyButton.Size = UDim2.new(0, 40, 0, 35)
iyButton.Position = UDim2.new(0, 320, 0.5, -17.5)
iyButton.BackgroundColor3 = Color3.fromRGB(255, 69, 0)
iyButton.Text = "⚡ IY"
iyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
iyButton.TextSize = 10
iyButton.Font = Enum.Font.GothamBold
iyButton.AutoButtonColor = false
iyButton.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
Instance.new("UICorner").Parent = iyButton

-- Кнопка SP HUB
local spButton = Instance.new("TextButton")
spButton.Size = UDim2.new(0, 40, 0, 35)
spButton.Position = UDim2.new(0, 365, 0.5, -17.5)
spButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
spButton.Text = "🎮 SP"
spButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spButton.TextSize = 10
spButton.Font = Enum.Font.GothamBold
spButton.AutoButtonColor = false
spButton.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
Instance.new("UICorner").Parent = spButton

-- Разделитель
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 0, 30)
divider.Position = UDim2.new(0, 410, 0.5, -15)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.5
divider.Parent = mainPanel

-- -1s
local minus1000Button = Instance.new("TextButton")
minus1000Button.Size = UDim2.new(0, 28, 0, 28)
minus1000Button.Position = UDim2.new(0, 417, 0.5, -14)
minus1000Button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minus1000Button.Text = "-1s"
minus1000Button.TextColor3 = Color3.fromRGB(255, 255, 255)
minus1000Button.TextSize = 9
minus1000Button.Font = Enum.Font.GothamBold
minus1000Button.AutoButtonColor = false
minus1000Button.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 5)
Instance.new("UICorner").Parent = minus1000Button

-- -100
local minus100Button = Instance.new("TextButton")
minus100Button.Size = UDim2.new(0, 28, 0, 28)
minus100Button.Position = UDim2.new(0, 449, 0.5, -14)
minus100Button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minus100Button.Text = "-100"
minus100Button.TextColor3 = Color3.fromRGB(255, 255, 255)
minus100Button.TextSize = 8
minus100Button.Font = Enum.Font.GothamBold
minus100Button.AutoButtonColor = false
minus100Button.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 5)
Instance.new("UICorner").Parent = minus100Button

-- Поле ввода
local intervalBox = Instance.new("TextBox")
intervalBox.Size = UDim2.new(0, 55, 0, 28)
intervalBox.Position = UDim2.new(0, 481, 0.5, -14)
intervalBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
intervalBox.Text = "5000"
intervalBox.TextColor3 = Color3.fromRGB(255, 255, 255)
intervalBox.TextSize = 12
intervalBox.Font = Enum.Font.GothamBold
intervalBox.PlaceholderText = "мс"
intervalBox.ClearTextOnFocus = false
intervalBox.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 5)
Instance.new("UICorner").Parent = intervalBox

-- OK
local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(0, 32, 0, 28)
applyButton.Position = UDim2.new(0, 540, 0.5, -14)
applyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
applyButton.Text = "OK"
applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applyButton.TextSize = 10
applyButton.Font = Enum.Font.GothamBold
applyButton.AutoButtonColor = false
applyButton.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 5)
Instance.new("UICorner").Parent = applyButton

-- +100
local plus100Button = Instance.new("TextButton")
plus100Button.Size = UDim2.new(0, 28, 0, 28)
plus100Button.Position = UDim2.new(0, 576, 0.5, -14)
plus100Button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
plus100Button.Text = "+100"
plus100Button.TextColor3 = Color3.fromRGB(255, 255, 255)
plus100Button.TextSize = 8
plus100Button.Font = Enum.Font.GothamBold
plus100Button.AutoButtonColor = false
plus100Button.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 5)
Instance.new("UICorner").Parent = plus100Button

-- +1s
local plus1000Button = Instance.new("TextButton")
plus1000Button.Size = UDim2.new(0, 28, 0, 28)
plus1000Button.Position = UDim2.new(0, 608, 0.5, -14)
plus1000Button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
plus1000Button.Text = "+1s"
plus1000Button.TextColor3 = Color3.fromRGB(255, 255, 255)
plus1000Button.TextSize = 9
plus1000Button.Font = Enum.Font.GothamBold
plus1000Button.AutoButtonColor = false
plus1000Button.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(0, 5)
Instance.new("UICorner").Parent = plus1000Button

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0.5, -12.5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.BackgroundTransparency = 0.8
closeButton.Parent = mainPanel
Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
Instance.new("UICorner").Parent = closeButton

-- ФУНКЦИИ
local function updateIntervalDisplay()
    intervalBox.Text = tostring(autoTeleportInterval)
end

local function setIntervalFromInput()
    local text = intervalBox.Text:gsub("%s+", "")
    local num = tonumber(text)
    if num and num >= 100 and num <= 60000 then
        autoTeleportInterval = math.floor(num / 100) * 100
        updateIntervalDisplay()
        print("⏱ Интервал установлен на " .. autoTeleportInterval .. "мс")
        if autoTeleportActive then
            stopAutoTeleport()
            task.wait(0.5)
            startAutoTeleport()
        end
        local tween = TweenService:Create(applyButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 200, 100)})
        tween:Play()
        task.wait(0.3)
        tween = TweenService:Create(applyButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)})
        tween:Play()
    else
        local tween = TweenService:Create(applyButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)})
        tween:Play()
        intervalBox.Text = tostring(autoTeleportInterval)
        task.wait(0.5)
        tween = TweenService:Create(applyButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)})
        tween:Play()
        print("❌ Введите число от 100 до 60000 мс")
    end
end

local function animateButton(button, color)
    local tween = TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = color
    })
    tween:Play()
    return tween
end

local function getCharacter()
    local char = player.Character
    if not char or not char.Parent then
        char = player.CharacterAdded:Wait()
    end
    return char
end

local function teleportToSaved()
    if not savedPosition then
        return false, "Нет сохраненной позиции"
    end
    local char = getCharacter()
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not rootPart then
        return false, "HumanoidRootPart не найден"
    end
    if not humanoid or humanoid.Health <= 0 then
        return false, "Персонаж мертв"
    end
    rootPart.CFrame = CFrame.new(savedPosition)
    rootPart.Velocity = Vector3.new(0, 0, 0)
    return true, "Телепорт выполнен"
end

local function startAutoTeleport()
    if autoTeleportCoroutine then
        coroutine.close(autoTeleportCoroutine)
        autoTeleportCoroutine = nil
    end
    autoTeleportActive = true
    autoButton.Text = "ON"
    animateButton(autoButton, Color3.fromRGB(255, 50, 50))
    autoTeleportCoroutine = coroutine.create(function()
        while autoTeleportActive do
            if savedPosition then
                local success, message = teleportToSaved()
                if success then
                    print("✅ Авто-телепорт: " .. message)
                    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(0, 30, 20)
                    })
                    tween:Play()
                    task.wait(0.2)
                    tween = TweenService:Create(mainFrame, TweenInfo.new(0.3), {
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    })
                    tween:Play()
                else
                    print("❌ Авто-телепорт: " .. message)
                end
            else
                print("⚠️ Нет сохраненной позиции для авто-телепорта")
            end
            local waitTime = autoTeleportInterval / 1000
            local steps = math.min(waitTime, 10)
            local stepTime = waitTime / steps
            for i = 1, steps do
                if not autoTeleportActive then break end
                local remaining = math.floor((waitTime - (i - 1) * stepTime) * 10) / 10
                autoButton.Text = string.format("%.1f", remaining) .. "с"
                task.wait(stepTime)
            end
        end
        autoButton.Text = "ATP"
        animateButton(autoButton, Color3.fromRGB(0, 200, 100))
    end)
    coroutine.resume(autoTeleportCoroutine)
end

local function stopAutoTeleport()
    autoTeleportActive = false
    if autoTeleportCoroutine then
        coroutine.close(autoTeleportCoroutine)
        autoTeleportCoroutine = nil
    end
    autoButton.Text = "ATP"
    animateButton(autoButton, Color3.fromRGB(0, 200, 100))
end

-- ===== ЗАГРУЗКА ВСЕХ СКРИПТОВ =====

-- 1. ORCA HUB
local orcaLoaded, orcaError = pcall(function()
    loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/richie0866/orca/master/public/latest.lua"))()
end)

if orcaLoaded then
    print("✅ Orca Hub загружен! Нажмите кнопку Orca или K")
    task.wait(1.5)
    toggleOrca()
else
    print("❌ Ошибка загрузки Orca Hub: " .. tostring(orcaError))
    orcaButton.Text = "🐚 ERR"
    animateButton(orcaButton, Color3.fromRGB(255, 50, 50))
end

-- 2. INFINITE YIELD
local iyLoaded, iyError = pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

if iyLoaded then
    print("✅ Infinite Yield загружен! Нажмите кнопку IY")
    task.wait(1.5)
    toggleIY()
else
    print("❌ Ошибка загрузки Infinite Yield: " .. tostring(iyError))
    iyButton.Text = "⚡ ERR"
    animateButton(iyButton, Color3.fromRGB(255, 50, 50))
end

-- 3. SP HUB (BROOKHAVEN RP)
local spLoaded, spError = pcall(function()
    loadstring(game:HttpGet("https://pastebin.com/raw/E2rnJA1p"))()
end)

if spLoaded then
    print("✅ SP Hub загружен! Нажмите кнопку SP или K")
    task.wait(1.5)
    toggleSP()
else
    print("❌ Ошибка загрузки SP Hub: " .. tostring(spError))
    spButton.Text = "🎮 ERR"
    animateButton(spButton, Color3.fromRGB(255, 50, 50))
end

-- ОБРАБОТЧИКИ
saveButton.MouseButton1Click:Connect(function()
    local char = getCharacter()
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if rootPart then
        savedPosition = rootPart.Position
        print("✅ Позиция сохранена: " .. tostring(savedPosition))
        animateButton(saveButton, Color3.fromRGB(0, 200, 100))
        saveButton.Text = "OK"
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 30, 20)})
        tween:Play()
        task.wait(0.2)
        tween = TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)})
        tween:Play()
        task.wait(1.5)
        animateButton(saveButton, Color3.fromRGB(30, 144, 255))
        saveButton.Text = "SWP"
    else
        animateButton(saveButton, Color3.fromRGB(255, 50, 50))
        saveButton.Text = "ERR"
        task.wait(1)
        animateButton(saveButton, Color3.fromRGB(30, 144, 255))
        saveButton.Text = "SWP"
    end
end)

teleportButton.MouseButton1Click:Connect(function()
    if not savedPosition then
        animateButton(teleportButton, Color3.fromRGB(255, 200, 0))
        teleportButton.Text = "! МЕТКА"
        task.wait(1.5)
        animateButton(teleportButton, Color3.fromRGB(255, 69, 0))
        teleportButton.Text = "TWP"
        return
    end
    local success, message = teleportToSaved()
    if success then
        animateButton(teleportButton, Color3.fromRGB(0, 200, 100))
        teleportButton.Text = "OK"
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 30, 20)})
        tween:Play()
        task.wait(0.2)
        tween = TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)})
        tween:Play()
        task.wait(1.5)
        animateButton(teleportButton, Color3.fromRGB(255, 69, 0))
        teleportButton.Text = "TWP"
    else
        animateButton(teleportButton, Color3.fromRGB(255, 50, 50))
        teleportButton.Text = "ERR"
        task.wait(1.5)
        animateButton(teleportButton, Color3.fromRGB(255, 69, 0))
        teleportButton.Text = "TWP"
    end
end)

autoButton.MouseButton1Click:Connect(function()
    if autoTeleportActive then
        stopAutoTeleport()
        print("🔄 Авто-телепорт ОСТАНОВЛЕН")
    else
        if not savedPosition then
            animateButton(autoButton, Color3.fromRGB(255, 200, 0))
            autoButton.Text = "! МЕТКА"
            task.wait(1.5)
            animateButton(autoButton, Color3.fromRGB(0, 200, 100))
            autoButton.Text = "ATP"
            return
        end
        startAutoTeleport()
        print("🔄 Авто-телепорт ЗАПУЩЕН с интервалом " .. autoTeleportInterval .. "мс")
    end
end)

minus1000Button.MouseButton1Click:Connect(function()
    if autoTeleportInterval > 1000 then
        autoTeleportInterval = autoTeleportInterval - 1000
        updateIntervalDisplay()
        print("⏱ Интервал уменьшен до " .. autoTeleportInterval .. "мс")
        if autoTeleportActive then
            stopAutoTeleport()
            task.wait(0.5)
            startAutoTeleport()
        end
    end
end)

minus100Button.MouseButton1Click:Connect(function()
    if autoTeleportInterval > 100 then
        autoTeleportInterval = autoTeleportInterval - 100
        updateIntervalDisplay()
        print("⏱ Интервал уменьшен до " .. autoTeleportInterval .. "мс")
        if autoTeleportActive then
            stopAutoTeleport()
            task.wait(0.5)
            startAutoTeleport()
        end
    end
end)

plus100Button.MouseButton1Click:Connect(function()
    if autoTeleportInterval < 60000 then
        autoTeleportInterval = autoTeleportInterval + 100
        updateIntervalDisplay()
        print("⏱ Интервал увеличен до " .. autoTeleportInterval .. "мс")
        if autoTeleportActive then
            stopAutoTeleport()
            task.wait(0.5)
            startAutoTeleport()
        end
    end
end)

plus1000Button.MouseButton1Click:Connect(function()
    if autoTeleportInterval < 60000 then
        autoTeleportInterval = autoTeleportInterval + 1000
        updateIntervalDisplay()
        print("⏱ Интервал увеличен до " .. autoTeleportInterval .. "мс")
        if autoTeleportActive then
            stopAutoTeleport()
            task.wait(0.5)
            startAutoTeleport()
        end
    end
end)

applyButton.MouseButton1Click:Connect(setIntervalFromInput)
intervalBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then setIntervalFromInput() end
end)

-- Кнопки хабов
orcaButton.MouseButton1Click:Connect(toggleOrca)
iyButton.MouseButton1Click:Connect(toggleIY)
spButton.MouseButton1Click:Connect(toggleSP)

noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        animateButton(noclipButton, Color3.fromRGB(0, 200, 100))
        noclipButton.Text = "NC✅"
        print("✅ Noclip ВКЛЮЧЕН")
    else
        animateButton(noclipButton, Color3.fromRGB(255, 50, 50))
        noclipButton.Text = "NC❌"
        print("❌ Noclip ВЫКЛЮЧЕН")
    end
end)

jumpButton.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    if infiniteJumpEnabled then
        animateButton(jumpButton, Color3.fromRGB(0, 200, 100))
        jumpButton.Text = "IJ✅"
        print("✅ Infinite Jump ВКЛЮЧЕН")
    else
        animateButton(jumpButton, Color3.fromRGB(255, 50, 50))
        jumpButton.Text = "IJ❌"
        print("❌ Infinite Jump ВЫКЛЮЧЕН")
    end
end)

speedButton.MouseButton1Click:Connect(function()
    local speeds = {200, 300, 400, 500, 100, 50}
    local currentIndex = 1
    for i, v in ipairs(speeds) do
        if v == walkSpeed then
            currentIndex = i
            break
        end
    end
    currentIndex = currentIndex % #speeds + 1
    local newSpeed = speeds[currentIndex]
    setWalkSpeed(newSpeed)
    speedButton.Text = tostring(newSpeed)
    animateButton(speedButton, Color3.fromRGB(0, 200, 100))
    task.wait(0.3)
    animateButton(speedButton, Color3.fromRGB(150, 50, 200))
end)

closeButton.MouseButton1Click:Connect(function()
    guiEnabled = not guiEnabled
    mainFrame.Visible = guiEnabled
    if not guiEnabled and autoTeleportActive then
        stopAutoTeleport()
    end
end)

-- ГОРЯЧИЕ КЛАВИШИ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.S then saveButton:TriggerClick()
    elseif input.KeyCode == Enum.KeyCode.T then teleportButton:TriggerClick()
    elseif input.KeyCode == Enum.KeyCode.A then autoButton:TriggerClick()
    elseif input.KeyCode == Enum.KeyCode.N then noclipButton:TriggerClick()
    elseif input.KeyCode == Enum.KeyCode.J then jumpButton:TriggerClick()
    elseif input.KeyCode == Enum.KeyCode.V then speedButton:TriggerClick()
    elseif input.KeyCode == Enum.KeyCode.H then closeButton:TriggerClick()
    elseif input.KeyCode == Enum.KeyCode.K then
        -- Клавиша K открывает Orca Hub
        orcaButton:TriggerClick()
    elseif input.KeyCode == Enum.KeyCode.I then iyButton:TriggerClick()
    elseif input.KeyCode == Enum.KeyCode.P then spButton:TriggerClick()
    elseif input.KeyCode == Enum.KeyCode.Return and intervalBox:IsFocused() then setIntervalFromInput()
    end
end)

-- ОБНОВЛЕНИЕ ПЕРСОНАЖА
player.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    getCharacter()
    setupInfiniteJump()
    startNoclip()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = walkSpeed end
end)

-- АНИМАЦИЯ ПОЯВЛЕНИЯ
mainFrame.BackgroundTransparency = 1
mainFrame.Position = UDim2.new(0.5, -425, 1, 0)
local appearTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -425, 0.85, 0),
    BackgroundTransparency = 0.1
})
appearTween:Play()

-- ЗАПУСК
task.wait(1)
startNoclip()
setupInfiniteJump()
setWalkSpeed(200)

-- КОМАНДЫ
_G.teleport = {
    save = function() saveButton:TriggerClick() end,
    tp = function() teleportButton:TriggerClick() end,
    auto = function() autoButton:TriggerClick() end,
    setInterval = function(ms)
        if ms >= 100 and ms <= 60000 then
            autoTeleportInterval = math.floor(ms / 100) * 100
            updateIntervalDisplay()
            if autoTeleportActive then
                stopAutoTeleport()
                task.wait(0.5)
                startAutoTeleport()
            end
            print("✅ Интервал установлен на " .. autoTeleportInterval .. "мс")
        else
            print("❌ Интервал должен быть от 100 до 60000 мс")
        end
    end,
    noclip = function(state)
        setNoclip(state)
        if state then
            noclipButton.Text = "NC✅"
            animateButton(noclipButton, Color3.fromRGB(0, 200, 100))
        else
            noclipButton.Text = "NC❌"
            animateButton(noclipButton, Color3.fromRGB(255, 50, 50))
        end
    end,
    jump = function(state)
        setInfiniteJump(state)
        if state then
            jumpButton.Text = "IJ✅"
            animateButton(jumpButton, Color3.fromRGB(0, 200, 100))
        else
            jumpButton.Text = "IJ❌"
            animateButton(jumpButton, Color3.fromRGB(255, 50, 50))
        end
    end,
    speed = function(value)
        setWalkSpeed(value)
        speedButton.Text = tostring(value)
    end,
    orca = function()
        toggleOrca()
    end,
    iy = function()
        toggleIY()
    end,
    sp = function()
        toggleSP()
    end,
    getStatus = function()
        print("📊 Статус:")
        print("  Сохраненная позиция: " .. (savedPosition and tostring(savedPosition) or "Нет"))
        print("  Авто-телепорт: " .. (autoTeleportActive and "ВКЛ" or "ВЫКЛ"))
        print("  Интервал: " .. autoTeleportInterval .. "мс")
        print("  Noclip: " .. (noclipEnabled and "ВКЛ" or "ВЫКЛ"))
        print("  Infinite Jump: " .. (infiniteJumpEnabled and "ВКЛ" or "ВЫКЛ"))
        print("  Скорость: " .. walkSpeed)
    end
}

print("✅ Delta Teleport Script загружен!")
print("📌 SWP - Сохранить | 🚀 TWP - Телепорт | 🔄 ATP - Авто")
print("🚫 NC - Noclip | ⬆ IJ - Jump | ⚡ Speed")
print("🐚 Orca - Orca Hub | ⚡ IY - Infinite Yield | 🎮 SP - SP Hub (Brookhaven)")
print("⏱ Введите задержку и нажмите OK или Enter")
print("⌨️ S - SWP | T - TWP | A - ATP | N - NC | J - IJ | V - Speed | K - Orca | I - IY | P - SP | H - Скрыть")
