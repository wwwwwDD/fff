local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Создаем ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "MobAttackGUI"
gui.Parent = PlayerGui

-- Создаем основное окно
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 450)
frame.Position = UDim2.new(0.5, -150, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Parent = gui

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

-- Логика перетаскивания окна
local isDraggingFrame = false
local dragStartPos, frameStartPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingFrame = true
        dragStartPos = input.Position
        frameStartPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingFrame and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        frame.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingFrame = false
    end
end)

-- Логика ползунка
local isDraggingSlider = false

slider.MouseButton1Down:Connect(function()
    isDraggingSlider = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = input.Position
        local sliderAbsPos = slider.AbsolutePosition
        local sliderAbsSize = slider.AbsoluteSize
        
        local mouseX = input.Position.X
        local sliderX = slider.AbsolutePosition.X
        local sliderWidth = slider.AbsoluteSize.X
        local relativeX = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        attackInterval = relativeX * 30
        sliderKnob.Position = UDim2.new(relativeX, -5, 0, 0)
        sliderLabel.Text = string.format("Attack Interval: %.1fs", attackInterval)
    end
end)

-- Функция для парсинга мобов из Workspace.Mobs
local function parseMobs()
    local mobs = {}
    local mobFolder = workspace:FindFirstChild("Mobs")
    
    if mobFolder then
        for _, mob in pairs(mobFolder:GetChildren()) do
            if mob:IsA("Model") then
                -- Проверяем, что это действительно моб (например, имеет PrimaryPart)
                if mob.PrimaryPart then
                    table.insert(mobs, {
                        Name = mob.Name,
                        Model = mob
                    })
                end
            end
        end
    else
        warn("Mobs folder not found in Workspace!")
    end
    
    return mobs
end

-- Функция создания кнопки для моба
local function createMobButton(mobData)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Text = mobData.Name
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Parent = scrollFrame

    button.MouseButton1Click:Connect(function()
        if selectedMobs[mobData.Name] then
            selectedMobs[mobData.Name] = nil
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        else
            selectedMobs[mobData.Name] = mobData.Model
            button.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        end
    end)
end

-- Обновление списка мобов
local function updateMobList()
    -- Очищаем текущий список
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local mobs = parseMobs()
    
    if #mobs == 0 then
        local noMobsLabel = Instance.new("TextLabel")
        noMobsLabel.Size = UDim2.new(1, -10, 0, 30)
        noMobsLabel.Text = "No mobs found"
        noMobsLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        noMobsLabel.BackgroundTransparency = 1
        noMobsLabel.TextScaled = true
        noMobsLabel.Parent = scrollFrame
    else
        for _, mobData in pairs(mobs) do
            createMobButton(mobData)
        end
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
end

-- Функция атаки
local function attackMobs()
    local attackTable = {}
    for mobName, mob in pairs(selectedMobs) do
        -- Проверяем, что моб еще существует
        if mob and mob.Parent then
            table.insert(attackTable, mob)
        else
            -- Удаляем несуществующего моба из выбранных
            selectedMobs[mobName] = nil
        end
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
if workspace:FindFirstChild("Mobs") then
    workspace.Mobs.ChildAdded:Connect(updateMobList)
    workspace.Mobs.ChildRemoved:Connect(updateMobList)
end

-- Первоначальное обновление списка
updateMobList()
