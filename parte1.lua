--[[ parte1.lua — Config + Helpers | Userspin45 ]]
-- Fix: só Punch no kill | treino separado | AutoExecute toggle

getgenv().Userspin45 = getgenv().Userspin45 or {}
local U = getgenv().Userspin45

local function loadLib(urls)
    for _, url in ipairs(urls) do
        local ok, src = pcall(function() return game:HttpGet(url) end)
        if ok and type(src) == "string" and #src > 50 then
            local fn = loadstring(src)
            if fn then
                local ok2, lib = pcall(fn)
                if ok2 and lib then return lib end
            end
        end
    end
    return nil
end

U.Fluent = loadLib({
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@master/main.lua",
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
})
U.SaveManager = loadLib({
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@master/Addons/SaveManager.lua",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
})
U.InterfaceManager = loadLib({
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@master/Addons/InterfaceManager.lua",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua",
})

if not U.Fluent then
    warn("[Userspin45] Fluent NÃO carregou")
    return
end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local TS = game:GetService("TeleportService")
local HS = game:GetService("HttpService")
local LP = Players.LocalPlayer

U.Config = {
    AutoStrength = false,
    AutoRebirth = false,
    AutoChests = false,
    AutoBrawl = false,
    FastPunch = false,
    AntiAFK = false,
    AntiDie = false,
    SilentKill = false,
    SilentKill2 = false,
    KillAura = false,
    AutoServerHop = true,
    AutoExecute = false, -- TOGGLE
    AuraSize = 12,
    AnimSpeed = 1.5
}

U.Char, U.Hum, U.HRP = nil, nil, nil
U.currentTarget, U.killCount, U.KillLabel = nil, 0, nil

function U.refresh()
    U.Char = LP.Character
    if U.Char then
        U.Hum = U.Char:FindFirstChildOfClass("Humanoid")
        U.HRP = U.Char:FindFirstChild("HumanoidRootPart")
    end
end
U.refresh()

LP.CharacterAdded:Connect(function(c)
    U.Char = c
    U.Hum = c:WaitForChild("Humanoid", 5)
    U.HRP = c:WaitForChild("HumanoidRootPart", 5)
    U.currentTarget = nil
end)

-- Desequipa todas as tools da mão
local function unequipAll()
    pcall(function()
        local bp = LP:FindFirstChild("Backpack")
        local ch = LP.Character
        if not bp or not ch then return end
        for _, t in pairs(ch:GetChildren()) do
            if t:IsA("Tool") then t.Parent = bp end
        end
    end)
end

-- AUTO LIFT / AUTO STRENGTH → só tools de TREINO
local TRAIN_TOOLS = {"Weight", "Pushups", "Situps", "Handstands"}

function U.equipTrain()
    pcall(function()
        local bp = LP:FindFirstChild("Backpack")
        local ch = LP.Character
        if not bp or not ch then return end
        unequipAll()
        for _, name in ipairs(TRAIN_TOOLS) do
            local t = bp:FindFirstChild(name)
            if t and t:IsA("Tool") then
                t.Parent = ch
                pcall(function() t:Activate() end)
            end
        end
    end)
end

-- SILENT KILL / FAST PUNCH → só PUNCH
local PUNCH_NAMES = {"Punch", "Combat Punch", "Fist", "Gloves"}

function U.equipPunch()
    pcall(function()
        local bp = LP:FindFirstChild("Backpack")
        local ch = LP.Character
        if not bp or not ch then return end
        unequipAll()

        local punch = nil
        for _, name in ipairs(PUNCH_NAMES) do
            punch = bp:FindFirstChild(name)
            if punch and punch:IsA("Tool") then break end
            punch = nil
        end

        -- fallback: nome tem "punch" e NÃO é treino
        if not punch then
            for _, t in pairs(bp:GetChildren()) do
                if t:IsA("Tool") then
                    local n = t.Name:lower()
                    if n:find("punch")
                        and not n:find("push")
                        and not n:find("weight")
                        and not n:find("sit")
                        and not n:find("handstand") then
                        punch = t
                        break
                    end
                end
            end
        end

        if punch then
            punch.Parent = ch
            pcall(function() punch:Activate() end)
        end
    end)
end

function U.fireRep()
    pcall(function()
        local e = LP:FindFirstChild("muscleEvent")
        if e then e:FireServer("rep") end
    end)
end

-- Auto Lift / Auto Strength
function U.doStrength()
    U.fireRep()
    U.equipTrain()
end

-- Auto Punch / Silent Kill punch
function U.doPunch()
    U.equipPunch()
    U.fireRep()
    pcall(function()
        VU:CaptureController()
        VU:ClickButton1(Vector2.new())
    end)
end

-- remote sem erro do "..."
function U.remote(name, method, ...)
    local args = {...}
    pcall(function()
        local folder = RS:FindFirstChild("rEvents")
        if not folder then return end
        local r = folder:FindFirstChild(name)
        if not r then return end
        if method == "InvokeServer" then
            r:InvokeServer(unpack(args))
        else
            r:FireServer(unpack(args))
        end
    end)
end

function U.doRebirth()
    U.remote("rebirthRemote", "InvokeServer", "rebirthRequest")
end

function U.doChests()
    for _, c in ipairs({"Magma Chest", "Mythical Chest", "Golden Chest", "Enchanted Chest", "Legends Chest"}) do
        U.remote("checkChestRemote", "InvokeServer", c)
    end
end

function U.doBrawl()
    U.remote("brawlEvent", "FireServer", "joinBrawl")
end

function U.openCrystal(n)
    U.remote("openCrystalRemote", "InvokeServer", "openCrystal", n)
end

function U.setSize(s)
    U.remote("changeSpeedSizeRemote", "InvokeServer", "changeSize", s)
end

function U.setAnim(s)
    pcall(function()
        U.refresh()
        if not U.Hum then return end
        for _, t in pairs(U.Hum:GetPlayingAnimationTracks()) do
            t:AdjustSpeed(s)
        end
        local a = U.Hum:FindFirstChildOfClass("Animator")
        if a then
            for _, t in pairs(a:GetPlayingAnimationTracks()) do
                t:AdjustSpeed(s)
            end
        end
    end)
end

function U.updateCounter()
    if U.KillLabel then
        pcall(function()
            U.KillLabel:SetDesc("Kills: " .. tostring(U.killCount))
        end)
    end
end

function U.getNearest()
    local n, d = nil, math.huge
    U.refresh()
    if not U.HRP then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health > 0 then
                local dist = (U.HRP.Position - r.Position).Magnitude
                if dist < d then d, n = dist, p end
            end
        end
    end
    return n
end

function U.getRandom()
    local t = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then table.insert(t, p) end
        end
    end
    return #t > 0 and t[math.random(1, #t)] or nil
end

function U.inAura()
    local t = {}
    U.refresh()
    if not U.HRP then return t end
    local size = U.Config.AuraSize or 12
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health > 0 and (U.HRP.Position - r.Position).Magnitude <= size then
                table.insert(t, p)
            end
        end
    end
    return t
end

function U.aliveCount()
    local n = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then n = n + 1 end
        end
    end
    return n
end

function U.tp(p)
    pcall(function()
        if not p or not p.Character then return end
        local r = p.Character:FindFirstChild("HumanoidRootPart")
        U.refresh()
        if r and U.HRP then
            U.HRP.CFrame = r.CFrame * CFrame.new(0, 0, 3)
        end
    end)
end

function U.dead(p)
    if not p or not p.Character then return true end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    return not h or h.Health <= 0
end

function U.hop()
    pcall(function()
        if U.Fluent then
            U.Fluent:Notify({
                Title = "Server Limpo!",
                Content = "Kills: " .. tostring(U.killCount) .. " | Hop...",
                Duration = 4
            })
        end
        task.wait(1.2)
        local pid = game.PlaceId
        local ok, res = pcall(function()
            return HS:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. pid .. "/servers/Public?sortOrder=Asc&limit=100"
            ))
        end)
        if ok and res and res.data then
            for _, s in pairs(res.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TS:TeleportToPlaceInstance(pid, s.id, LP)
                    return
                end
            end
        end
        TS:Teleport(pid, LP)
    end)
end

-- AUTO EXECUTE (toggle ON = grava ficheiro | OFF = apaga)
function U.setAutoExecute(on)
    pcall(function()
        if on then
            if not isfolder("autoexecute") then makefolder("autoexecute") end
            local loader = [[
-- Userspin45 ML AutoExecute
print("[Userspin45] AutoExecute a correr...")
pcall(function()
    loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/afonsomiguelito13-collab/ML-Script@main/main.lua"))()
end)
]]
            writefile("autoexecute/Userspin45_ML_FINAL.lua", loader)
            writefile("autoexecute/ml_userspin45.lua", loader)
            if U.Fluent then
                U.Fluent:Notify({
                    Title = "AutoExecute ON",
                    Content = "Salvo na pasta autoexecute do Delta",
                    Duration = 4
                })
            end
            print("[Userspin45] AutoExecute ON")
        else
            pcall(function() delfile("autoexecute/Userspin45_ML_FINAL.lua") end)
            pcall(function() delfile("autoexecute/ml_userspin45.lua") end)
            if U.Fluent then
                U.Fluent:Notify({
                    Title = "AutoExecute OFF",
                    Content = "Ficheiros removidos",
                    Duration = 3
                })
            end
            print("[Userspin45] AutoExecute OFF")
        end
    end)
end

print("[Userspin45] parte1 OK")
