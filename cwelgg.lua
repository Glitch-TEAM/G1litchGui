--[[ 
    KICI KICI MAFIA V11: THE FINAL SUPREME
    ฅ^•ﻌ•^ฅ - THE DEFINITIVE ALL-IN-ONE
    FIXED & OPTIMIZED VERSION
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- GŁÓWNA NAZWA (Używana do ochrony przed auto-usuwaniem)
local GUI_NAME = "KiciKici_Final_Supreme"

-- Usuń poprzednie wersje jeśli istnieją
if player:WaitForChild("PlayerGui"):FindFirstChild(GUI_NAME) then
    player.PlayerGui[GUI_NAME]:Destroy()
end

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = GUI_NAME
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

-- === STATE & CONFIG ===
local ACCENT = Color3.fromRGB(255, 85, 175)
local stickOn, aimbotOn, walkSpeedOn, noClipOn = false, false, false, false
local lines = {}
local TEXTURE_ID = "rbxassetid://119770705825149"

-- === BEZPIECZNE CZYSZCZENIE OBCYCH MENU ===
local function safeCleanup(targetKeywords)
    local locations = {player.PlayerGui}
    
    -- Próba dostępu do CoreGui (tylko dla lepszych executorów)
    local s, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if s then table.insert(locations, coreGui) end

    for _, location in pairs(locations) do
        for _, ui in pairs(location:GetChildren()) do
            -- OCHRONA WŁASNEGO GUI
            if ui.Name ~= GUI_NAME and ui:IsA("ScreenGui") then 
                for _, keyword in pairs(targetKeywords) do
                    if ui.Name:lower():find(keyword:lower()) then
                        pcall(function() ui:Destroy() end)
                    end
                end
            end
        end
    end
end

-- === CLEANUP & RESET LOGIC ===
local function resetState()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
        player.Character.Humanoid.JumpPower = 50
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then pcall(function() part.CanCollide = true end) end
        end
    end
    Lighting.Brightness = 2
    Lighting.GlobalShadows = true
    for _, l in pairs(lines) do l.Visible = false end
end

-- === FUNKCJE ZEWNĘTRZNYCH MENU ===
local function gcmenu(v)
    if v then
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Glitch-TEAM/G1litchGui/refs/heads/main/gui.lua"))()
        end)
        if not success then warn("Błąd GC Menu: " .. err) end
    else
        safeCleanup({"Gl1tchBoy11 GUI", "G1litch", "G-TEAM", "GC"})
    end
end

local function dexmenu(v)
    if v then
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/AlterX404/DarkDEX-V5/refs/heads/main/DarkDEX-V5"))()
        end)
        if not success then warn("Błąd DEX: " .. err) end
    else
        -- Szukamy wszystkich wariantów nazw Dexa
        safeCleanup({"Dex", "DarkDex", "Explorer", "DexExplorer"})
    end
end

-- === MAIN FRAME UI ===
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 800, 0, 550)
mainFrame.Position = UDim2.new(0.5, -400, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 20)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 4

-- SIDEBAR
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 230, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Instance.new("UICorner", sidebar)

local logo = Instance.new("ImageLabel", sidebar)
logo.Size = UDim2.new(0, 160, 0, 160)
logo.Position = UDim2.new(0.5, -80, 0, 10)
logo.Image = TEXTURE_ID
logo.BackgroundTransparency = 1

local nav = Instance.new("ScrollingFrame", sidebar)
nav.Size = UDim2.new(1, -10, 1, -180)
nav.Position = UDim2.new(0, 5, 0, 170)
nav.BackgroundTransparency = 1
nav.ScrollBarThickness = 0
Instance.new("UIListLayout", nav).Padding = UDim.new(0, 8)

-- CONTENT
local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, -250, 1, -20)
container.Position = UDim2.new(0, 240, 0, 10)
container.BackgroundTransparency = 1

local tabs = {}

-- === UI BUILDERS ===
local function createTab(name, icon)
    local f = Instance.new("ScrollingFrame", container)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ScrollBarThickness = 0
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 12)
    
    local b = Instance.new("TextButton", nav)
    b.Size = UDim2.new(1, 0, 0, 55)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.Text = icon .. "  " .. name
    b.Font = Enum.Font.GothamBold
    b.TextSize = 20
    b.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
    Instance.new("UIPadding", b).PaddingLeft = UDim.new(0, 15)
    
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do t.Visible = false end
        for _, btn in pairs(nav:GetChildren()) do 
            if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end 
        end
        f.Visible = true
        b.BackgroundColor3 = ACCENT
    end)
    tabs[name] = f
    return f
end

local function addToggle(tab, name, callback)
    local b = Instance.new("TextButton", tab)
    b.Size = UDim2.new(1, -10, 0, 60)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    b.Text = "  " .. name .. ": OFF"
    b.Font = Enum.Font.GothamBold
    b.TextSize = 18
    b.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
    
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = s and "  " .. name .. ": ON" or "  " .. name .. ": OFF"
        b.TextColor3 = s and Color3.new(1, 1, 1) or Color3.new(0.7, 0.7, 0.7)
        b.BackgroundColor3 = s and ACCENT or Color3.fromRGB(20, 20, 25)
        
        if not s then resetState() end
        callback(s)
    end)
end

-- === TABS & SETUP ===
local tCombat = createTab("Combat", "🎯")
local tVisuals = createTab("Visuals", "👁️")
local tPlayer = createTab("Player", "🏃")
local tMenus = createTab("Premium menus", "🛡️")
local tDumper = createTab("Dumper", "📂")
local tExec = createTab("Executor", "⌨️")

-- Toggles
addToggle(tCombat, "Aimbot (Silent)", function(v) aimbotOn = v end)
addToggle(tVisuals, "Stickman ESP", function(v) stickOn = v end)
addToggle(tVisuals, "Fullbright", function(v) Lighting.Brightness = v and 5 or 2 Lighting.GlobalShadows = not v end)
addToggle(tPlayer, "Speed (100)", function(v) walkSpeedOn = v end)
addToggle(tPlayer, "Noclip", function(v) noClipOn = v end)

-- Menus (Fixed)
addToggle(tMenus, "GC MENU v1", gcmenu)
addToggle(tMenus, "DEX EXPLORER", dexmenu)

-- Dumper
local dBtn = Instance.new("TextButton", tDumper)
dBtn.Size = UDim2.new(1, -10, 0, 70)
dBtn.Text = "MEGA DUMP TO CONSOLE"
dBtn.Font = Enum.Font.GothamBold
dBtn.TextSize = 22
dBtn.BackgroundColor3 = ACCENT
Instance.new("UICorner", dBtn)
dBtn.MouseButton1Click:Connect(function()
    print("--- KICI KICI SUPREME DUMP ---")
    local d = {}
    for _, v in pairs(game:GetDescendants()) do
        table.insert(d, "[" .. v.ClassName .. "] " .. v:GetFullName())
        if #d % 1000 == 0 then task.wait() end
    end
    local s = table.concat(d, "\n")
    for i = 1, #s, 15000 do print(s:sub(i, i + 14999)) end
    if writefile then pcall(function() writefile("SupremeDump.txt", s) end) end
end)

-- Executor
local eBox = Instance.new("TextBox", tExec)
eBox.Size = UDim2.new(1, -10, 0, 250)
eBox.MultiLine, eBox.Text = true, "-- Kici Kici Mafia Supreme Executor"
eBox.BackgroundColor3 = Color3.new(0,0,0)
eBox.TextColor3 = Color3.new(1,1,1)
eBox.Font = Enum.Font.Code
eBox.TextSize = 16
Instance.new("UICorner", eBox)
local run = Instance.new("TextButton", tExec)
run.Size = UDim2.new(1, -10, 0, 50)
run.Text, run.BackgroundColor3 = "EXECUTE", ACCENT
Instance.new("UICorner", run)
run.MouseButton1Click:Connect(function() 
    local code = eBox.Text
    local func, err = loadstring(code)
    if func then pcall(func) else warn("Exec Error: "..err) end
end)

-- === MAIN LOOP ===
tabs["Combat"].Visible = true
nav:GetChildren()[2].BackgroundColor3 = ACCENT -- Podświetl pierwszy tab

RunService.RenderStepped:Connect(function()
    local c = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    mainStroke.Color = c
    logo.ImageColor3 = c
    
    if stickOn then
        local idx = 1
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = p.Character:FindFirstChild("Head")
                local t = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
                if h and t then
                    local v1, vis1 = camera:WorldToViewportPoint(h.Position)
                    local v2, vis2 = camera:WorldToViewportPoint(t.Position)
                    if vis1 and vis2 then
                        local l = lines[idx] or Instance.new("Frame", screenGui)
                        l.BorderSizePixel = 0 lines[idx] = l l.Visible = true l.BackgroundColor3 = c
                        l.Size = UDim2.new(0, (Vector2.new(v1.X, v1.Y) - Vector2.new(v2.X, v2.Y)).Magnitude, 0, 2)
                        l.Position = UDim2.new(0, (v1.X + v2.X)/2, 0, (v1.Y + v2.Y)/2)
                        l.Rotation = math.deg(math.atan2(v2.Y - v1.Y, v2.X - v1.X))
                        idx = idx + 1
                    end
                end
            end
        end
        for i = idx, #lines do lines[i].Visible = false end
    end
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        if walkSpeedOn then player.Character.Humanoid.WalkSpeed = 100 end
        if noClipOn then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- Draggable logic
local d, ds, sp
mainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = mainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
    local dl = i.Position - ds
    mainFrame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dl.X, sp.Y.Scale, sp.Y.Offset + dl.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
UserInputService.InputBegan:Connect(function(i, p) if not p and i.KeyCode == Enum.KeyCode.Insert then mainFrame.Visible = not mainFrame.Visible end end)

print("KICI KICI MAFIA V11 SUPREME LOADED! 🐾👑")
