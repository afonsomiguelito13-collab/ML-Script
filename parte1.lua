--[[ parte1.lua — Config + Helpers + Glitch Rocks | Userspin45 ]]

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
    AutoExecute = false,
    GlitchRock = false,
    GlitchRockName = "Punching Rock",
    GlitchSpeed = 2,
    AuraSize = 12,
    AnimSpeed = 1.5,
}

U.Char, U.Hum, U.HRP = nil, nil, nil
U.currentTarget, U.killCount, U.KillLabel = nil, 0, nil

U.ROCK_NAMES = {
    "Tiny Rock", "Punching Rock", "Large Rock", "Golden Rock",
    "Frozen Rock", "Mythical Rock", "Eternal Rock", "Legends Rock",
    "Legend Rock", "Jungle Rock", "Ancient Jungle Rock",
    "Muscle King Rock", "MuscleKing Rock", "King Rock",
}

local TRAIN_TOOLS = {"Weight", "Pushups", "Situps", "Handstands"}
local PUNCH_NAMES = {"Punch", "Combat Punch", "Fist", "Gloves"}

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

local function unequipAll()
    pcall(function()
        local bp, ch = LP:FindFirstChild("Backpack"), LP.Character
        if not bp or not ch then return end
        for _, t in pairs(ch:GetChildren()) do
            if t:IsA("Tool") then t.Parent = bp end
        end
    end)
end

function U.equipTrain()
    pcall(function()
        local bp, ch = LP:FindFirstChild("Backpack"), LP.Character
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

function U.equipPunch()
    pcall(function()
        local bp, ch = LP:FindFirstChild("Backpack"), LP.Character
        if not bp or not ch then return end
        unequipAll()
        local punch = nil
        for _, name in ipairs(PUNCH_NAMES) do
            punch = bp:FindFirstChild(name)
            if punch and punch:IsA("Tool") then break end
            punch = nil
        end
        if not punch then
            for _, t in pairs(bp:GetChildren()) do
                if t:IsA("Tool") then
                    local n = t.Name:lower()
                    if n:find("punch") and not n:find("push") and not n:find("weight")
                        and not n:find("sit") and not n:find("handstand") then
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

function U.doStrength()
    U.fireRep()
    U.equipTrain()
end

function U.doPunch()
    U.equipPunch()
    U.fireRep()
    pcall(function()
        VU:CaptureController()
        VU:ClickButton1(Vector2.new())
    end)
end

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

function U.doRebirth() U.remote("rebirthRemote", "InvokeServer", "rebirthRequest") end
function U.doChests()
    for _, c in ipairs({"Magma Chest", "Mythical Chest", "Golden Chest", "Enchanted Chest", "Legends Chest"}) do
        U.remote("checkChestRemote", "InvokeServer", c)
    end
end
function U.doBrawl() U.remote("brawlEvent", "FireServer", "joinBrawl") end
function U.openCrystal(n) U.remote("openCrystalRemote", "InvokeServer", "openCrystal", n) end
function U.setSize(s) U.remote("changeSpeedSizeRemote", "InvokeServer", "changeSize", s) end

function U.setAnim(s)
    pcall(function()
        U.refresh()
        if not U.Hum then return end
        for _, t in pairs(U.Hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(s) end
        local a = U.Hum:FindFirstChildOfClass("Animator")
        if a then for _, t in pairs(a:GetPlayingAnimationTracks()) do t:AdjustSpeed(s) end end
    end)
end

function U.updateCounter()
    if U.KillLabel then
        pcall(function() U.KillLabel:SetDesc("Kills: " .. tostring(U.killCount)) end)
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
        if r and U.HRP then U.HRP.CFrame = r.CFrame * CFrame.new(0, 0, 3) end
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
            U.Fluent:Notify({ Title = "Server Limpo!", Content = "Kills: " .. U.killCount .. " | Hop...", Duration = 4 })
        end
        task.wait(1.2)
        local pid = game.PlaceId
        local ok, res = pcall(function()
            return HS:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. pid .. "/servers/Public?sortOrder=Asc&limit=100"))
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

function U.setAutoExecute(on)
    pcall(function()
        if on then
            if not isfolder("autoexecute") then makefolder("autoexecute") end
            local loader = [[
print("[Userspin45] AutoExecute...")
pcall(function()
    loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/afonsomiguelito13-collab/ML-Script@main/main.lua"))()
end)
]]
            writefile("autoexecute/Userspin45_ML_FINAL.lua", loader)
            writefile("autoexecute/ml_userspin45.lua", loader)
            if U.Fluent then U.Fluent:Notify({ Title = "AutoExecute ON", Content = "Salvo!", Duration = 4 }) end
        else
            pcall(function() delfile("autoexecute/Userspin45_ML_FINAL.lua") end)
            pcall(function() delfile("autoexecute/ml_userspin45.lua") end)
            if U.Fluent then U.Fluent:Notify({ Title = "AutoExecute OFF", Content = "Removido", Duration = 3 }) end
        end
    end)
end

-- GLITCH ROCKS
function U.findRock(name)
    local target = nil
    local function scan(parent)
        for _, obj in pairs(parent:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local n = obj.Name
                if n == name or n:lower() == (name and name:lower() or "") or (name and n:find(name)) then
                    if obj:IsA("Model") then
                        local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if p then target = p return end
                    else
                        target = obj
                        return
                    end
                end
            end
        end
    end
    pcall(function()
        if workspace:FindFirstChild("Rocks") then scan(workspace.Rocks) end
        scan(workspace)
    end)
    return target
end

function U.findAnyRock()
    for _, name in ipairs(U.ROCK_NAMES) do
        local r = U.findRock(name)
        if r then return r, name end
    end
    local found = nil
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("rock") and not n:find("bedrock") then
                    found = obj
                    break
                end
            end
        end
    end)
    return found, found and found.Name or nil
end

function U.hitRock(part)
    if not part then return end
    pcall(function()
        U.equipPunch()
        U.refresh()
        local hrp = U.HRP
        if not hrp then return end
        if firetouchinterest then
            firetouchinterest(hrp, part, 0)
            firetouchinterest(hrp, part, 1)
        end
        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
        VU:CaptureController()
        VU:ClickButton1(Vector2.new())
        U.fireRep()
    end)
end

function U.doGlitchRock()
    local name = U.Config.GlitchRockName or "Punching Rock"
    local rock = U.findRock(name)
    if not rock then rock = select(1, U.findAnyRock()) end
    if rock then U.hitRock(rock) end
end

print("[Userspin45] parte1 OK")
