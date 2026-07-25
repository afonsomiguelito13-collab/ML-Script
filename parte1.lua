--[[ part1.lua — Config + Helpers | Userspin45 ]]

getgenv().Userspin45 = getgenv().Userspin45 or {}
local U = getgenv().Userspin45

U.Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
U.SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
U.InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local TS = game:GetService("TeleportService")
local HS = game:GetService("HttpService")
local LP = Players.LocalPlayer

U.Config = {
    AutoStrength = false, AutoRebirth = false, AutoChests = false, AutoBrawl = false,
    FastPunch = false, AntiAFK = false, AntiDie = false,
    SilentKill = false, SilentKill2 = false, KillAura = false,
    AutoServerHop = true, AuraSize = 12, AnimSpeed = 1.5
}

U.Char, U.Hum, U.HRP, U.currentTarget, U.killCount, U.KillLabel = nil, nil, nil, nil, 0, nil

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

function U.equip(list)
    pcall(function()
        local bp, ch = LP:FindFirstChild("Backpack"), LP.Character
        if not bp or not ch then return end
        for _, t in pairs(ch:GetChildren()) do if t:IsA("Tool") then t.Parent = bp end end
        for _, n in ipairs(list) do
            local t = bp:FindFirstChild(n)
            if t then t.Parent = ch pcall(function() t:Activate() end) end
        end
    end)
end

function U.equipPunch()
    pcall(function()
        local bp, ch = LP:FindFirstChild("Backpack"), LP.Character
        if not bp or not ch then return end
        for _, t in pairs(ch:GetChildren()) do if t:IsA("Tool") then t.Parent = bp end end
        for _, t in pairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if n:find("punch") or n:find("glove") or n:find("fist") or n:find("brawl") or n:find("fight") or n:find("hand") or n:find("strength") or n:find("soco") then
                    t.Parent = ch pcall(function() t:Activate() end)
                end
            end
        end
        U.equip({"Weight", "Handstands", "Pushups"})
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
    U.equip({"Weight", "Pushups", "Situps", "Handstands"})
end

function U.doPunch()
    U.fireRep()
    U.equipPunch()
    pcall(function()
        VU:CaptureController()
        VU:ClickButton1(Vector2.new())
    end)
end

function U.remote(name, method, ...)
    pcall(function()
        local r = RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild(name)
        if r then r[method](r, ...) end
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
    if U.KillLabel then pcall(function() U.KillLabel:SetDesc("Kills: " .. U.killCount) end) end
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
    local s = U.Config.AuraSize or 12
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health > 0 and (U.HRP.Position - r.Position).Magnitude <= s then
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
        U.Fluent:Notify({Title = "Server Limpo!", Content = "Kills: " .. U.killCount .. " | Hop...", Duration = 4})
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

function U.saveAuto()
    pcall(function()
        if not isfolder("autoexecute") then makefolder("autoexecute") end
        local c = 'print("[Userspin45] AutoExecute OK")\ngame:GetService("StarterGui"):SetCore("SendNotification",{Title="Userspin45",Text="AutoExecute!",Duration=5})'
        writefile("autoexecute/Userspin45_ML_FINAL.lua", c)
        writefile("autoexecute/ml_userspin45.lua", c)
        U.Fluent:Notify({Title = "AutoExecute", Content = "Salvo! Hop = executa sozinho", Duration = 5})
    end)
end

print("[Userspin45] part1 OK")
