local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS
local PlayerESPEnabled = false
local ComputerESPEnabled = false
local ESPObjects = {}
local ComputerESPObjects = {}
local walkspeedValue = 16
local speedLocked = false
local AntiErrorOn = false
local antiErrorHooked = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FleeHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 450)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎮 Flee the Facility Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0, 7.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.new(0, 10, 0, 60)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
Content.BorderSizePixel = 0
Content.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = Content

-- CRIAR TOGGLE
local function CreateToggle(name, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = Content
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 15
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 50, 0, 25)
    Switch.Position = UDim2.new(1, -60, 0.5, -12.5)
    Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Switch.BorderSizePixel = 0
    Switch.Parent = ToggleFrame
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 19, 0, 19)
    Circle.Position = UDim2.new(0, 3, 0.5, -9.5)
    Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Circle.BorderSizePixel = 0
    Circle.Parent = Switch
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle
    
    local enabled = false
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = ToggleFrame
    
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        
        TweenService:Create(Switch, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
        }):Play()
        
        TweenService:Create(Circle, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
        }):Play()
    end)
end

-- CRIAR INPUT
local function CreateInput(name, placeholder, callback)
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, 0, 0, 70)
    InputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Content
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = InputFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = InputFrame
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -20, 0, 30)
    TextBox.Position = UDim2.new(0, 10, 1, -35)
    TextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    TextBox.BorderSizePixel = 0
    TextBox.PlaceholderText = placeholder
    TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 14
    TextBox.Font = Enum.Font.Gotham
    TextBox.Parent = InputFrame
    
    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 6)
    TextBoxCorner.Parent = TextBox
    
    TextBox.FocusLost:Connect(function()
        callback(TextBox.Text)
    end)
end

-- CRIAR TOGGLES
CreateToggle("ESP Players", function(val)
    PlayerESPEnabled = val
    if not val then
        for p, _ in pairs(ESPObjects) do
            pcall(function() ESPObjects[p].Highlight:Destroy() end)
            pcall(function() ESPObjects[p].Billboard:Destroy() end)
        end
        ESPObjects = {}
    end
end)

CreateToggle("ESP Computadores", function(val)
    ComputerESPEnabled = val
    if not val then
        for obj, hl in pairs(ComputerESPObjects) do
            pcall(function() hl:Destroy() end)
        end
        ComputerESPObjects = {}
    end
end)

CreateInput("Walkspeed", "Digite velocidade (ex: 50)", function(text)
    local speed = tonumber(text)
    if speed then walkspeedValue = speed end
end)

CreateToggle("Anti Error", function(val)
    AntiErrorOn = val
    if val and not antiErrorHooked then
        antiErrorHooked = true
        pcall(function()
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = function(self, ...)
                local method = getnamecallmethod()
                if AntiErrorOn and method == "FireServer" then
                    local a1 = ...
                    if a1 == "SetPlayerMinigameResult" then
                        return old(self, "SetPlayerMinigameResult", true)
                    end
                end
                return old(self, ...)
            end
            setreadonly(mt, true)
        end)
    end
end)

Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
end)

-- DRAG
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- BOTÕES SET/UNLOCK
local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "FloatButtons"
FloatGui.ResetOnSpawn = false
FloatGui.Parent = game.CoreGui

local SetBtn = Instance.new("TextButton")
SetBtn.Size = UDim2.new(0, 90, 0, 40)
SetBtn.Position = UDim2.new(0.85, 0, 0.35, 0)
SetBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
SetBtn.Text = "SET"
SetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetBtn.TextSize = 16
SetBtn.Font = Enum.Font.GothamBold
SetBtn.Parent = FloatGui
Instance.new("UICorner", SetBtn).CornerRadius = UDim.new(0, 10)

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Size = UDim2.new(0, 90, 0, 40)
UnlockBtn.Position = UDim2.new(0.85, 0, 0.42, 0)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
UnlockBtn.Text = "UNLOCK"
UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnlockBtn.TextSize = 14
UnlockBtn.Font = Enum.Font.GothamBold
UnlockBtn.Parent = FloatGui
Instance.new("UICorner", UnlockBtn).CornerRadius = UDim.new(0, 10)

SetBtn.MouseButton1Click:Connect(function()
    speedLocked = true
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = walkspeedValue
    end
end)

UnlockBtn.MouseButton1Click:Connect(function()
    speedLocked = false
    walkspeedValue = 16
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

-- ESP PLAYERS
local function IsBeast(player)
    if not player.Character then return false end
    if player.Character:FindFirstChild("Hammer") or player.Character:FindFirstChild("Chainsaw") then return true end
    if player.Backpack:FindFirstChild("Hammer") or player.Backpack:FindFirstChild("Chainsaw") then return true end
    local hum = player.Character:FindFirstChild("Humanoid")
    if hum and hum.WalkSpeed > 20 then return true end
    if player.Team and (player.Team.Name == "Beast" or player.Team.Name == "Fera") then return true end
    return false
end

RunService.Heartbeat:Connect(function()
    if PlayerESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                if ESPObjects[player] then
                    pcall(function() ESPObjects[player].Highlight:Destroy() end)
                    pcall(function() ESPObjects[player].Billboard:Destroy() end)
                    ESPObjects[player] = nil
                end
                continue
            end
            
            local root = player.Character.HumanoidRootPart
            local beast = IsBeast(player)
            
            if not ESPObjects[player] then
                local hl = Instance.new("Highlight")
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.Adornee = player.Character
                hl.Parent = player.Character
                ESPObjects[player] = {Highlight = hl, Billboard = nil}
            end
            
            local esp = ESPObjects[player]
            if esp.Highlight.Adornee ~= player.Character then
                esp.Highlight.Adornee = player.Character
            end
            
            esp.Highlight.FillColor = beast and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
            esp.Highlight.OutlineColor = beast and Color3.fromRGB(150,0,0) or Color3.fromRGB(0,150,0)
            
            if beast and not esp.Billboard then
                local bb = Instance.new("BillboardGui")
                bb.Adornee = root
                bb.Size = UDim2.new(0, 200, 0, 50)
                bb.StudsOffset = Vector3.new(0, 4, 0)
                bb.AlwaysOnTop = true
                bb.Parent = game.CoreGui
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.TextColor3 = Color3.fromRGB(255, 0, 0)
                tl.TextStrokeTransparency = 0
                tl.TextScaled = true
                tl.Font = Enum.Font.SourceSansBold
                tl.Text = "BEAST"
                tl.Parent = bb
                esp.Billboard = bb
            elseif not beast and esp.Billboard then
                esp.Billboard:Destroy()
                esp.Billboard = nil
            end
            
            if esp.Billboard then esp.Billboard.Adornee = root end
        end
    end
    
    -- Walkspeed
    if speedLocked then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.WalkSpeed ~= walkspeedValue then
                hum.WalkSpeed = walkspeedValue
            end
        end
    end
end)

-- ESP COMPUTADORES
task.spawn(function()
    while true do
        task.wait(2)
        if ComputerESPEnabled then
            for _, obj in pairs(game.Workspace:GetDescendants()) do
                if obj.Name == "ComputerTable" and obj:IsA("Model") then
                    if not ComputerESPObjects[obj] then
                        pcall(function()
                            local greenNeons = 0
                            local blueNeons = 0
                            for _, part in pairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
                                    local c = part.Color
                                    if c.G > 0.4 and c.G > c.R and c.G > c.B then greenNeons = greenNeons + 1 end
                                    if c.B > 0.4 and c.B > c.R and c.B > c.G then blueNeons = blueNeons + 1 end
                                end
                            end
                            
                            if not (greenNeons > 0 and greenNeons > blueNeons) then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = obj
                                hl.FillColor = Color3.fromRGB(0, 150, 255)
                                hl.OutlineColor = Color3.fromRGB(0, 100, 200)
                                hl.FillTransparency = 0.5
                                hl.OutlineTransparency = 0
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = game.CoreGui
                                ComputerESPObjects[obj] = hl
                            end
                        end)
                    end
                end
            end
        end
        
        -- Remove completados
        for obj, hl in pairs(ComputerESPObjects) do
            if obj.Parent then
                local greenNeons = 0
                local blueNeons = 0
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
                        local c = part.Color
                        if c.G > 0.4 and c.G > c.R and c.G > c.B then greenNeons = greenNeons + 1 end
                        if c.B > 0.4 and c.B > c.R and c.B > c.G then blueNeons = blueNeons + 1 end
                    end
                end
                
                if greenNeons > 0 and greenNeons > blueNeons then
                    hl:Destroy()
                    ComputerESPObjects[obj] = nil
                end
            else
                hl:Destroy()
                ComputerESPObjects[obj] = nil
            end
        end
    end
end)
