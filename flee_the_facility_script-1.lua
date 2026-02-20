local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
    Name = "Flee the Facility | Hub",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "by Script",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- SISTEMA ANTI-NOTIFICAÇÃO (aguarda Rayfield carregar)
task.wait(2)
spawn(function()
    local blockedWords = {"discord", "sirius", "enjoying", "library", "find it at", "notification"}
    while true do
        wait(0.5)
        pcall(function()
            for _, gui in pairs(game.CoreGui:GetChildren()) do
                if gui.Name:find("Rayfield") or gui.Name:find("%x%x%x%x%x%x%x") then
                    for _, obj in pairs(gui:GetDescendants()) do
                        if obj.Name == "Notifications" or obj.Name == "Notification" then
                            obj:Destroy()
                        end
                        if obj:IsA("TextLabel") then
                            local text = obj.Text:lower()
                            for _, word in pairs(blockedWords) do
                                if text:find(word) then
                                    -- Destrói 3 níveis acima (pega o container da notificação)
                                    local target = obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Parent or obj
                                    if target and target ~= gui then
                                        target:Destroy()
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

local MainTab = Window:CreateTab("Principal", 4483362458)
MainTab:CreateSection("ESP")

-- CRIAR BOTÕES SET/UNLOCK PRIMEIRO (antes do menu)
local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "FleeFloatButtons"
FloatGui.ResetOnSpawn = false
FloatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FloatGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local SetBtn = Instance.new("TextButton")
SetBtn.Size = UDim2.new(0, 110, 0, 50)
SetBtn.Position = UDim2.new(0, 50, 0.35, 0)  -- Posição inicial
SetBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
SetBtn.BorderSizePixel = 0
SetBtn.Text = "SET (50)"  -- Mostra valor padrão
SetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetBtn.TextSize = 18
SetBtn.Font = Enum.Font.SourceSansBold
SetBtn.ZIndex = 10
SetBtn.Parent = FloatGui

local SetCorner = Instance.new("UICorner")
SetCorner.CornerRadius = UDim.new(0, 10)
SetCorner.Parent = SetBtn

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Size = UDim2.new(0, 110, 0, 50)
UnlockBtn.Position = UDim2.new(0, 50, 0.43, 0)  -- Abaixo do SET
UnlockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
UnlockBtn.BorderSizePixel = 0
UnlockBtn.Text = "UNLOCK"
UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnlockBtn.TextSize = 16
UnlockBtn.Font = Enum.Font.SourceSansBold
UnlockBtn.ZIndex = 10
UnlockBtn.Parent = FloatGui

local UnlockCorner = Instance.new("UICorner")
UnlockCorner.CornerRadius = UDim.new(0, 10)
UnlockCorner.Parent = UnlockBtn

-- SISTEMA DE ARRASTAR
local buttonsLocked = false

local function MakeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if buttonsLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

MakeDraggable(SetBtn)
MakeDraggable(UnlockBtn)

-- EVENTOS DOS BOTÕES
SetBtn.MouseButton1Click:Connect(function()
    -- Validação: garante que velocidade é um número válido
    if not walkspeedValue or walkspeedValue < 1 then
        walkspeedValue = 50 -- Valor padrão caso não tenha digitado
    end
    
    speedLocked = true
    SetBtn.Text = "SET ("..tostring(walkspeedValue)..")"
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = walkspeedValue
    end
end)

UnlockBtn.MouseButton1Click:Connect(function()
    speedLocked = false
    SetBtn.Text = "SET"
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 16
    end
end)

local UnlockCorner = Instance.new("UICorner")
UnlockCorner.CornerRadius = UDim.new(0, 10)
UnlockCorner.Parent = UnlockBtn

-- VARIÁVEIS
local PlayerESPEnabled = false
local ComputerESPEnabled = false
local ESPObjects = {}
local ComputerESPObjects = {}
local walkspeedValue = 50  -- Valor padrão quando clicar SET sem digitar
local speedLocked = false
local AntiErrorOn = false
local antiErrorHooked = false

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

local function RemovePlayerESP(player)
    if ESPObjects[player] then
        pcall(function() ESPObjects[player].Highlight:Destroy() end)
        pcall(function() ESPObjects[player].Billboard:Destroy() end)
        ESPObjects[player] = nil
    end
end

RunService.Heartbeat:Connect(function()
    if not PlayerESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if ESPObjects[player] then RemovePlayerESP(player) end
            continue
        end
        
        local char = player.Character
        local root = char.HumanoidRootPart
        local beast = IsBeast(player)
        
        if not ESPObjects[player] then
            local hl = Instance.new("Highlight")
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Adornee = char
            hl.Parent = char
            ESPObjects[player] = {Highlight = hl, Billboard = nil}
        end
        
        local esp = ESPObjects[player]
        if esp.Highlight.Adornee ~= char then
            esp.Highlight.Adornee = char
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
    
    for player, _ in pairs(ESPObjects) do
        if not player.Parent then RemovePlayerESP(player) end
    end
end)

MainTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        PlayerESPEnabled = Value
        if not Value then
            for p, _ in pairs(ESPObjects) do RemovePlayerESP(p) end
        end
    end,
})

Players.PlayerRemoving:Connect(RemovePlayerESP)

-- ESP COMPUTADORES
local function IsComputerCompleted(computer)
    local screenIsGreen = false
    local screenIsBlue = false
    
    for _, obj in pairs(computer:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
            if obj.Name:lower():find("screen") or obj.Name:lower():find("monitor") or obj.Name:lower():find("display") then
                local c = obj.Color
                
                if c.G > 0.4 and c.G > c.R and c.G > c.B then
                    screenIsGreen = true
                end
                
                if c.B > 0.4 and c.B > c.R and c.B > c.G then
                    screenIsBlue = true
                end
            end
        end
    end
    
    return screenIsGreen and not screenIsBlue
end

local function ScanComputers()
    if not ComputerESPEnabled then return end
    
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj.Name == "ComputerTable" and obj:IsA("Model") then
            if not ComputerESPObjects[obj] then
                if not IsComputerCompleted(obj) then
                    pcall(function()
                        local hl = Instance.new("Highlight")
                        hl.Adornee = obj
                        hl.FillColor = Color3.fromRGB(0, 150, 255)
                        hl.OutlineColor = Color3.fromRGB(0, 100, 200)
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = game.CoreGui
                        ComputerESPObjects[obj] = hl
                    end)
                end
            end
        end
    end
end

spawn(function()
    while true do
        wait(2)
        if ComputerESPEnabled then ScanComputers() end
    end
end)

game.Workspace.DescendantAdded:Connect(function(obj)
    if ComputerESPEnabled and obj.Name == "ComputerTable" and obj:IsA("Model") then
        wait(0.5)
        ScanComputers()
    end
end)

-- Remove completados
spawn(function()
    while true do
        wait(0.5)
        if ComputerESPEnabled then
            for obj, hl in pairs(ComputerESPObjects) do
                if obj.Parent then
                    if IsComputerCompleted(obj) then
                        hl:Destroy()
                        ComputerESPObjects[obj] = nil
                    end
                else
                    hl:Destroy()
                    ComputerESPObjects[obj] = nil
                end
            end
        end
    end
end)

MainTab:CreateToggle({
    Name = "ESP Computadores",
    CurrentValue = false,
    Flag = "ComputerESP",
    Callback = function(Value)
        ComputerESPEnabled = Value
        if not Value then
            for obj, hl in pairs(ComputerESPObjects) do
                pcall(function() hl:Destroy() end)
            end
            ComputerESPObjects = {}
        else
            ScanComputers()
        end
    end,
})

-- WALKSPEED
MainTab:CreateSection("Walkspeed")

MainTab:CreateInput({
    Name = "Set Your Walkspeed",
    PlaceholderText = "Digite a velocidade (ex: 50)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local speed = tonumber(Text)
        if speed and speed >= 1 then
            walkspeedValue = speed
            SetBtn.Text = "SET ("..tostring(speed)..")"
        else
            -- Se valor inválido, mantém o anterior
            SetBtn.Text = "SET ("..tostring(walkspeedValue)..")"
        end
    end,
})

RunService.Heartbeat:Connect(function()
    if not speedLocked then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum and hum.WalkSpeed ~= walkspeedValue then
        hum.WalkSpeed = walkspeedValue
    end
end)

-- UTILIDADES
MainTab:CreateSection("Utilidades")

MainTab:CreateToggle({
    Name = "Anti Error",
    CurrentValue = false,
    Flag = "AntiError",
    Callback = function(Value)
        AntiErrorOn = Value
        if Value and not antiErrorHooked then
            antiErrorHooked = true
            
            -- Tenta várias abordagens para compatibilidade com Delta
            local success = pcall(function()
                -- Método 1: hookmetamethod (compatível com Delta)
                if hookmetamethod then
                    local old
                    old = hookmetamethod(game, "__namecall", function(self, ...)
                        if AntiErrorOn then
                            local method = getnamecallmethod()
                            if method == "FireServer" then
                                local args = {...}
                                if args[1] == "SetPlayerMinigameResult" then
                                    return old(self, "SetPlayerMinigameResult", true)
                                end
                            end
                        end
                        return old(self, ...)
                    end)
                else
                    -- Método 2: getrawmetatable (fallback)
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
                end
            end)
            
            if not success then
                print("[Anti Error] Não foi possível ativar - executor não suportado")
            end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Esconder Botões SET/UNLOCK",
    CurrentValue = false,
    Flag = "HideButtons",
    Callback = function(Value)
        SetBtn.Visible = not Value
        UnlockBtn.Visible = not Value
    end,
})

MainTab:CreateToggle({
    Name = "Travar Botões SET/UNLOCK",
    CurrentValue = false,
    Flag = "LockButtons",
    Callback = function(Value)
        buttonsLocked = Value
    end,
})

-- BOTÕES SET/UNLOCK

