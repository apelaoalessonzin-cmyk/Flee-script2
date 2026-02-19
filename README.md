--[[
    Flee the Facility Hub - Orion Edition (FIXED)
    - Link de carregamento atualizado (sem erro 404)
    - Sem Intro (evita bloqueio de toque no celular)
    - Botão MENU lateral para fechar/abrir a UI
]]

-- Carregamento com link estável
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Criando a Janela (IntroEnabled = false remove a notificação de carregamento)
local Window = OrionLib:MakeWindow({
    Name = "🎮 Flee the Facility Hub", 
    HidePremium = true, 
    SaveConfig = true, 
    ConfigFolder = "FleeHubOrion",
    IntroEnabled = false -- Desativado para não bugar o clique no celular
})

-- SERVIÇOS
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- VARIÁVEIS DE CONTROLE
local PlayerESPEnabled = false
local ComputerESPEnabled = false
local ESPObjects = {}
local ComputerESPObjects = {}
local walkspeedValue = 16
local speedLocked = false
local AntiErrorOn = false
local antiErrorHooked = false

-- BOTÃO FLUTUANTE (MOBILE TOGGLE)
local ScreenGui = Instance.new("ScreenGui")
local OpenBtn = Instance.new("TextButton")
local Corner = Instance.new("UICorner")

ScreenGui.Name = "OrionMobileFix"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

OpenBtn.Name = "OpenButton"
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
OpenBtn.BackgroundTransparency = 0.3
OpenBtn.Position = UDim2.new(0, 10, 0.5, -22)
OpenBtn.Size = UDim2.new(0, 55, 0, 45)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Text = "MENU"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 12

Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = OpenBtn

OpenBtn.MouseButton1Click:Connect(function()
    local target = game:GetService("CoreGui"):FindFirstChild("Orion")
    if target then
        target.Enabled = not target.Enabled
    end
end)

-- LOGICA ISBEAST
local function IsBeast(player)
    if not player.Character then return false end
    if player.Character:FindFirstChild("Hammer") or player.Character:FindFirstChild("Chainsaw") then return true end
    if player.Backpack:FindFirstChild("Hammer") or player.Backpack:FindFirstChild("Chainsaw") then return true end
    local hum = player.Character:FindFirstChild("Humanoid")
    if hum and hum.WalkSpeed > 20 then return true end
    if player.Team and (player.Team.Name == "Beast" or player.Team.Name == "Fera") then return true end
    return false
end

-- ABA VISUAIS
local MainTab = Window:MakeTab({
    Name = "Visuals / ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "ESP Players",
    Default = false,
    Callback = function(Value)
        PlayerESPEnabled = Value
        if not Value then
            for p, _ in pairs(ESPObjects) do
                pcall(function() ESPObjects[p].Highlight:Destroy() end)
                pcall(function() ESPObjects[p].Billboard:Destroy() end)
            end
            ESPObjects = {}
        end
    end    
})

MainTab:AddToggle({
    Name = "ESP Computadores",
    Default = false,
    Callback = function(Value)
        ComputerESPEnabled = Value
        if not Value then
            for obj, hl in pairs(ComputerESPObjects) do
                pcall(function() hl:Destroy() end)
            end
            ComputerESPObjects = {}
        end
    end    
})

-- ABA PLAYER
local PlayerTab = Window:MakeTab({
    Name = "Player / Speed",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PlayerTab:AddTextbox({
    Name = "Velocidade",
    Default = "16",
    TextDisappear = false,
    Callback = function(Text)
        local speed = tonumber(Text)
        if speed then walkspeedValue = speed end
    end      
})

PlayerTab:AddButton({
    Name = "Ativar Velocidade (SET)",
    Callback = function()
        speedLocked = true
    end    
})

PlayerTab:AddButton({
    Name = "Resetar Velocidade (UNLOCK)",
    Callback = function()
        speedLocked = false
        walkspeedValue = 16
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end    
})

PlayerTab:AddToggle({
    Name = "Anti Error (Beta)",
    Default = false,
    Callback = function(Value)
        AntiErrorOn = Value
        if Value and not antiErrorHooked then
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
    end    
})

-- LOOP HEARTBEAT (ESP & SPEED)
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
            esp.Highlight.FillColor = beast and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
            
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
        end
    end
    
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

-- LOOP COMPUTADORES
task.spawn(function()
    while true do
        task.wait(2)
        if ComputerESPEnabled then
            for _, obj in pairs(game.Workspace:GetDescendants()) do
                if obj.Name == "ComputerTable" and obj:IsA("Model") then
                    if not ComputerESPObjects[obj] then
                        pcall(function()
                            local greenNeons = 0
                            for _, part in pairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
                                    if part.Color.G > 0.4 then greenNeons = greenNeons + 1 end
                                end
                            end
                            if greenNeons == 0 then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = obj
                                hl.FillColor = Color3.fromRGB(0, 150, 255)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.Parent = game.CoreGui
                                ComputerESPObjects[obj] = hl
                            end
                        end)
                    end
                end
            end
        end
    end
end)

OrionLib:Init()
