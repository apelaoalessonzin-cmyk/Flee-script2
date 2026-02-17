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
    KeySystem = false,
})

local MainTab = Window:CreateTab("Principal", 4483362458)
MainTab:CreateSection("ESP")

local PlayerESPEnabled = false
local ComputerESPEnabled = false
local ESPObjects = {}
local ComputerESPObjects = {}
local CompletedComputers = {}
local walkspeedValue = 16
local speedLocked = false
local FullBrightEnabled = false
local AntiErrorOn = false

-- ESP JOGADORES
local function IsBeast(player)
    if not player.Character then return false end
    if player.Character:FindFirstChild("Hammer") then return true end
    if player.Character:FindFirstChild("Chainsaw") then return true end
    if player.Backpack:FindFirstChild("Hammer") then return true end
    if player.Backpack:FindFirstChild("Chainsaw") then return true end
    local hum = player.Character:FindFirstChild("Humanoid")
    if hum and hum.WalkSpeed > 20 then return true end
    if player.Team then
        if player.Team.Name == "Beast" then return true end
        if player.Team.Name == "Fera" then return true end
    end
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

        -- Se não tem personagem, mantém ESP existente e aguarda respawn
        if not player.Character then continue end
        if not player.Character:FindFirstChild("HumanoidRootPart") then continue end

        local root = player.Character.HumanoidRootPart
        local beast = IsBeast(player)

        -- Recria ESP se não existe ou se o Highlight foi destruído
        if not ESPObjects[player] or not ESPObjects[player].Highlight or not ESPObjects[player].Highlight.Parent then
            -- Remove o antigo se existir
            RemovePlayerESP(player)
            -- Cria novo
            local hl = Instance.new("Highlight")
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Adornee = player.Character
            hl.Parent = player.Character
            ESPObjects[player] = {Highlight = hl, Billboard = nil}
        end

        local esp = ESPObjects[player]

        -- Atualiza adornee se personagem mudou (respawnou)
        if esp.Highlight.Adornee ~= player.Character then
            esp.Highlight.Adornee = player.Character
            esp.Highlight.Parent = player.Character
        end

        -- Atualiza cores
        esp.Highlight.FillColor = beast and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
        esp.Highlight.OutlineColor = beast and Color3.fromRGB(150,0,0) or Color3.fromRGB(0,150,0)

        -- Billboard BEAST
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

        if esp.Billboard then
            esp.Billboard.Adornee = root
        end
    end

    -- Remove ESPs de jogadores que saíram do servidor
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
local function ScanComputers()
    if not ComputerESPEnabled then return end
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj.Name == "ComputerTable" and obj:IsA("Model") then
            if not CompletedComputers[obj] and not ComputerESPObjects[obj] then
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
                    spawn(function()
                        while ComputerESPObjects[obj] and obj.Parent do
                            for _, part in pairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
                                    if part.BrickColor == BrickColor.new("Lime green") or part.BrickColor == BrickColor.new("Bright green") then
                                        CompletedComputers[obj] = true
                                        if ComputerESPObjects[obj] then
                                            ComputerESPObjects[obj]:Destroy()
                                            ComputerESPObjects[obj] = nil
                                        end
                                        return
                                    end
                                end
                            end
                            wait(0.5)
                        end
                    end)
                end)
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

MainTab:CreateToggle({
    Name = "ESP Computadores",
    CurrentValue = false,
    Flag = "ComputerESP",
    Callback = function(Value)
        ComputerESPEnabled = Value
        if not Value then
            for _, hl in pairs(ComputerESPObjects) do pcall(function() hl:Destroy() end) end
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
        if speed then walkspeedValue = speed end
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

local function ApplyFullBright()
    local L = game:GetService("Lighting")
    if FullBrightEnabled then
        L.Ambient = Color3.fromRGB(255, 255, 255)
        L.Brightness = 2
        L.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
        L.ColorShift_Top = Color3.fromRGB(255, 255, 255)
        L.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        L.FogEnd = 999999
        L.FogStart = 999999
        L.GlobalShadows = false
        L.ClockTime = 14
        for _, e in pairs(L:GetChildren()) do
            if e:IsA("BloomEffect") or e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end
    else
        L.Ambient = Color3.fromRGB(0, 0, 0)
        L.Brightness = 1
        L.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        L.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        L.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        L.FogEnd = 100000
        L.FogStart = 0
        L.GlobalShadows = true
        for _, e in pairs(L:GetChildren()) do
            if e:IsA("BloomEffect") or e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = true
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not FullBrightEnabled then return end
    local L = game:GetService("Lighting")
    if L.Ambient ~= Color3.fromRGB(255,255,255) then ApplyFullBright() end
end)

MainTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        FullBrightEnabled = Value
        ApplyFullBright()
    end,
})

-- ANTI ERROR
local antiErrorHooked = false

local function HookAntiError()
    if antiErrorHooked then return end
    
    -- Testa se getrawmetatable funciona
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if AntiErrorOn and method == "FireServer" then
                local a1, a2 = ...
                if a1 == "SetPlayerMinigameResult" then
                    -- Sempre manda true pro servidor
                    return old(self, "SetPlayerMinigameResult", true)
                end
            end
            return old(self, ...)
        end)
        
        setreadonly(mt, true)
    end)
    
    if ok then
        antiErrorHooked = true
        print("[Anti Error] Hook ativado com sucesso!")
    else
        -- Fallback sem newcclosure
        pcall(function()
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            
            mt.__namecall = function(self, ...)
                local method = getnamecallmethod()
                if AntiErrorOn and method == "FireServer" then
                    local a1, a2 = ...
                    if a1 == "SetPlayerMinigameResult" then
                        return old(self, "SetPlayerMinigameResult", true)
                    end
                end
                return old(self, ...)
            end
            
            setreadonly(mt, true)
            antiErrorHooked = true
            print("[Anti Error] Hook fallback ativado!")
        end)
    end
end

MainTab:CreateToggle({
    Name = "Anti Error",
    CurrentValue = false,
    Flag = "AntiError",
    Callback = function(Value)
        AntiErrorOn = Value
        if Value then
            HookAntiError()
        else
        end
    end,
})

-- BOTÕES FLUTUANTES
local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "FloatButtons"
FloatGui.ResetOnSpawn = false
FloatGui.Parent = game.CoreGui

local SetFrame = Instance.new("TextButton")
SetFrame.Parent = FloatGui
SetFrame.BackgroundColor3 = Color3.fromRGB(20, 120, 20)
SetFrame.BorderSizePixel = 0
SetFrame.Position = UDim2.new(0.85, 0, 0.35, 0)
SetFrame.Size = UDim2.new(0, 100, 0, 40)
SetFrame.Font = Enum.Font.SourceSansBold
SetFrame.Text = "SET"
SetFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
SetFrame.TextSize = 18
Instance.new("UICorner", SetFrame).CornerRadius = UDim.new(0, 8)

local UnlockFrame = Instance.new("TextButton")
UnlockFrame.Parent = FloatGui
UnlockFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
UnlockFrame.BorderSizePixel = 0
UnlockFrame.Position = UDim2.new(0.85, 0, 0.45, 0)
UnlockFrame.Size = UDim2.new(0, 100, 0, 40)
UnlockFrame.Font = Enum.Font.SourceSansBold
UnlockFrame.Text = "UNLOCK"
UnlockFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
UnlockFrame.TextSize = 18
Instance.new("UICorner", UnlockFrame).CornerRadius = UDim.new(0, 8)

local drag1, di1, ds1, sp1
SetFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag1 = true
        ds1 = i.Position
        sp1 = SetFrame.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then drag1 = false end
        end)
    end
end)
SetFrame.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di1 = i end
end)

local drag2, di2, ds2, sp2
UnlockFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag2 = true
        ds2 = i.Position
        sp2 = UnlockFrame.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then drag2 = false end
        end)
    end
end)
UnlockFrame.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di2 = i end
end)

UIS.InputChanged:Connect(function(i)
    if drag1 and i == di1 and ds1 and sp1 then
        local d = i.Position - ds1
        SetFrame.Position = UDim2.new(sp1.X.Scale, sp1.X.Offset + d.X, sp1.Y.Scale, sp1.Y.Offset + d.Y)
    end
    if drag2 and i == di2 and ds2 and sp2 then
        local d = i.Position - ds2
        UnlockFrame.Position = UDim2.new(sp2.X.Scale, sp2.X.Offset + d.X, sp2.Y.Scale, sp2.Y.Offset + d.Y)
    end
end)

SetFrame.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        speedLocked = true
        char.Humanoid.WalkSpeed = walkspeedValue
        SetFrame.BackgroundColor3 = Color3.fromRGB(20, 200, 20)
    end
end)

UnlockFrame.MouseButton1Click:Connect(function()
    speedLocked = false
    -- NÃO reseta walkspeedValue, só destrava
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 16
    end
    SetFrame.BackgroundColor3 = Color3.fromRGB(20, 120, 20)
end)

