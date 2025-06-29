local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Создаем ScreenGui
local gui = Instance.new("ScreenGui")
gui.Parent = PlayerGui

-- Создаем основное окно
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 450)
frame.Position = UDim2.new(0.5, -150, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Parent = gui
frame.Active = true -- Для перетаскивания
frame.Draggable = true -- Включаем перетаскивание

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "Mob Attack Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextScaled = true
title.Parent = frame

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Parent = frame

-- Прокручиваемый фрейм для списка мобов
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -170)
scrollFrame.Position = UDim2.new(0, 5, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.Parent = scrollFrame

-- Ползунок для интервала атаки
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(1, -10, 0, 50)
sliderFrame.Position = UDim2.new(0, 5, 1, -110)
sliderFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
sliderFrame.Parent = frame

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0, 20)
sliderLabel.Text = "Attack Interval: 1.0s"
sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextScaled = true
sliderLabel.Parent = sliderFrame

local slider = Instance.new("TextButton")
slider.Size = UDim2.new(1, -10, 0, 20)
slider.Position = UDim2.new(0, 5, 0, 25)
slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
slider.Text = ""
slider.Parent = sliderFrame

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 10, 1, 0)
sliderKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
sliderKnob.Parent = slider

-- Кнопка для непрерывной атаки
local autoAttackButton = Instance.new("TextButton")
autoAttackButton.Size = UDim2.new(1, -10, 0, 50)
autoAttackButton.Position = UDim2.new(0, 5, 1, -60)
autoAttackButton.Text = "Start Auto Attack"
autoAttackButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
autoAttackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoAttackButton.TextScaled = true
autoAttackButton.Parent = frame

-- Таблица для хранения выбранных мобов и интервал атаки
local selectedMobs = {}
local isAutoAttacking = false
local attackInterval = 1

-- Логика ползунка
local isDragging = false
slider.MouseButton1Down:Connect(function()
    isDragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local sliderX = slider.AbsolutePosition.X
        local sliderWidth = slider.AbsoluteSize.X
        local relativeX = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        attackInterval = relativeX * 30 -- От 0 до 30 секунд
        sliderKnob.Position = UDim2.new(relativeX, -5, 0, 0)
        sliderLabel.Text = string.format("Attack Interval: %.1fs", attackInterval)
    end
end)

-- Функция для парсинга мобов из Workspace.Mobs
local function parseMobs()
    local mobs = {}
    local mobFolder = game:GetService("Workspace"):FindFirstChild("Mobs")
    if mobFolder then
        for _, mob in pairs(mobFolder:GetChildren()) do
            if mob:IsA("Model") and mob:FindFirstChild("Humanoid") then
                mobs[mob.Name] = mob
            end
        end
    else
        warn("Mobs folder not found in Workspace!")
    end
    return mobs
end

-- Функция создания кнопки для моба
local function createMobButton(mobName, mob)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Text = mobName
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Parent = scrollFrame

    button.MouseButton1Click:Connect(function()
        if selectedMobs[mobName] then
            selectedMobs[mobName] = nil
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        else
            selectedMobs[mobName] = mob
            button.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        end
    end)
end

-- Обновление списка мобов
local function updateMobList()
    selectedMobs = {}
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    local mobs = parseMobs()
    for mobName, mob in pairs(mobs) do
        createMobButton(mobName, mob)
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
end
updateMobList()

-- Функция атаки
local function attackMobs()
    local attackTable = {}
    for _, mob in pairs(selectedMobs) do
        table.insert(attackTable, mob)
    end
    if #attackTable > 0 then
        ReplicatedStorage.Systems.Combat.PlayerAttack:FireServer(attackTable)
    end
end

-- Логика непрерывной атаки
autoAttackButton.MouseButton1Click:Connect(function()
    isAutoAttacking = not isAutoAttacking
    autoAttackButton.Text = isAutoAttacking and "Stop Auto Attack" or "Start Auto Attack"
    autoAttackButton.BackgroundColor3 = isAutoAttacking and Color3.fromRGB(120, 0, 0) or Color3.fromRGB(0, 120, 0)

    if isAutoAttacking then
        spawn(function()
            while isAutoAttacking do
                attackMobs()
                wait(math.max(0.1, attackInterval))
            end
        end)
    end
end)

-- Закрытие меню и выгрузка скрипта
closeButton.MouseButton1Click:Connect(function()
    isAutoAttacking = false
    gui:Destroy()
    script:Destroy()
end)

-- Закрытие меню по Esc (только скрытие)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape then
        gui.Enabled = not gui.Enabled
    end
end)

-- Обновление списка мобов при изменении содержимого Workspace.Mobs
workspace.Mobs.ChildAdded:Connect(updateMobList) -- Строка ~110
workspace.Mobs.ChildRemoved:Connect(updateMobList)