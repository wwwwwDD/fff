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
frame.Size = UDim2.new(0, 350, 0, 500)  -- Увеличили размер окна
frame.Position = UDim2.new(0.5, -175, 0.5, -250)
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
scrollFrame.Size = UDim2.new(1, -10, 1, -220)  -- Увеличили высоту
scrollFrame.Position = UDim2.new(0, 5, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.Parent = scrollFrame

-- Кнопки для массового выбора
local selectButtonsFrame = Instance.new("Frame")
selectButtonsFrame.Size = UDim2.new(1, -10, 0, 40)
selectButtonsFrame.Position = UDim2.new(0, 5, 0, 55)
selectButtonsFrame.BackgroundTransparency = 1
selectButtonsFrame.Parent = frame

local selectAllButton = Instance.new("TextButton")
selectAllButton.Size = UDim2.new(0.5, -5, 1, 0)
selectAllButton.Position = UDim2.new(0, 0, 0, 0)
selectAllButton.Text = "Select All"
selectAllButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
selectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
selectAllButton.TextScaled = true
selectAllButton.Parent = selectButtonsFrame

local deselectAllButton = Instance.new("TextButton")
deselectAllButton.Size = UDim2.new(0.5, -5, 1, 0)
deselectAllButton.Position = UDim2.new(0.5, 5, 0, 0)
deselectAllButton.Text = "Deselect All"
deselectAllButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
deselectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deselectAllButton.TextScaled = true
deselectAllButton.Parent = selectButtonsFrame

-- Ползунок для интервала атаки
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(1, -10, 0, 50)
sliderFrame.Position = UDim2.new(0, 5, 1, -160)
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
autoAttackButton.Position = UDim2.new(0, 5, 1, -110)
autoAttackButton.Text = "Start Auto Attack"
autoAttackButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
autoAttackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoAttackButton.TextScaled = true
autoAttackButton.Parent = frame

-- Кнопка для единоразовой атаки
local singleAttackButton = Instance.new("TextButton")
singleAttackButton.Size = UDim2.new(1, -10, 0, 50)
singleAttackButton.Position = UDim2.new(0, 5, 1, -60)
singleAttackButton.Text = "Single Attack"
singleAttackButton.BackgroundColor3 = Color3.fromRGB(120, 0, 120)
singleAttackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
singleAttackButton.TextScaled = true
singleAttackButton.Parent = frame

-- Таблица для хранения выбранных мобов и интервал атаки
local selectedMobs = {}
local mobButtons = {} -- Таблица для хранения ссылок на кнопки мобов
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

    -- Сохраняем ссылку на кнопку
    mobButtons[mobData.Name] = button

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
    
    mobButtons = {} -- Очищаем таблицу кнопок
    selectedMobs = {} -- Очищаем выбранных мобов
    
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
            if mobButtons[mobName] then
                mobButtons[mobName].BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end
        end
    end
    
    if #attackTable > 0 then
        ReplicatedStorage.Systems.Combat.PlayerAttack:FireServer(attackTable)
        return true
    end
    return false
end

-- Выбрать всех мобов
selectAllButton.MouseButton1Click:Connect(function()
    local mobs = parseMobs()
    for _, mobData in pairs(mobs) do
        selectedMobs[mobData.Name] = mobData.Model
        if mobButtons[mobData.Name] then
            mobButtons[mobData.Name].BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        end
    end
end)

-- Снять выбор со всех мобов
deselectAllButton.MouseButton1Click:Connect(function()
    for mobName, button in pairs(mobButtons) do
        selectedMobs[mobName] = nil
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
end)

-- Логика непрерывной атаки
autoAttackButton.MouseButton1Click:Connect(function()
    isAutoAttacking = not isAutoAttacking
    autoAttackButton.Text = isAutoAttacking and "Stop Auto Attack" or "Start Auto Attack"
    autoAttackButton.BackgroundColor3 = isAutoAttacking and Color3.fromRGB(120, 0, 0) or Color3.fromRGB(0, 120, 0)

    if isAutoAttacking then
        spawn(function()
            while isAutoAttacking do
                if not attackMobs() then
                    -- Если нет мобов для атаки, останавливаем автоатаку
                    isAutoAttacking = false
                    autoAttackButton.Text = "Start Auto Attack"
                    autoAttackButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
                    break
                end
                wait(math.max(0.1, attackInterval))
            end
        end)
    end
end)

-- Логика единоразовой атаки
singleAttackButton.MouseButton1Click:Connect(function()
    attackMobs()
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
