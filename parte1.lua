-- ML Script | parte1.lua
-- Shared state, remotes, equip helpers (Userspin45)
print("[ML] parte1 shared OK")

getgenv().ML = getgenv().ML or {}
local ML = getgenv().ML

ML.Version = "MEGA-FINAL-2"
ML.Creator = "Userspin45"

ML.Flags = ML.Flags or {
    AutoLift = false, FastPunch = false, AutoStrength = false, AutoWeight = false,
    AutoRebirth = false, AutoChests = false, AutoBrawl = false,
    SilentKill = false, SilentKill2 = false, KillAura = false,
    GlitchRocks = false, AntiAFK = false, AntiDie = false,
    AutoExecute = false, KillCounter = false, AutoReconnect = false,
}
for k, v in pairs({
    AutoLift = false, FastPunch = false, AutoStrength = false, AutoWeight = false,
    AutoRebirth = false, AutoChests = false, AutoBrawl = false,
    SilentKill = false, SilentKill2 = false, KillAura = false,
    GlitchRocks = false, AntiAFK = false, AntiDie = false,
    AutoExecute = false, KillCounter = false, AutoReconnect = false,
}) do
    if ML.Flags[k] == nil then ML.Flags[k] = v end
end

ML.Settings = ML.Settings or { AuraSize = 15, WalkSpeed = 16, GlitchSpeed = 2 }
ML.FoundRocks = ML.FoundRocks or {}
ML.FoundRockNames = ML.FoundRockNames or {}

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
ML.LP = Players.LocalPlayer
ML.Remotes = ML.Remotes or {}

local function findRemote()
    local pe = ML.LP:FindFirstChild("muscleEvent")
    if pe then ML.Remotes.muscleEvent = pe end
    local rEvents = RS:FindFirstChild("rEvents")
    if rEvents then
        local reb = rEvents:FindFirstChild("rebirthRemote")
        if reb then ML.Remotes.rebirthRemote = reb end
    end
    pcall(function()
        for _, v in ipairs(RS:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local n = string.lower(v.Name)
                if n:find("rebirth") and not ML.Remotes.rebirthRemote then ML.Remotes.rebirthRemote = v end
                if n:find("muscle") and v:IsA("RemoteEvent") and not ML.Remotes.muscleEvent then ML.Remotes.muscleEvent = v end
            end
        end
    end)
end
findRemote()

ML.PunchNames = { "Punch" }
ML.WeightNames = { "Weight", "Weights" }
ML.TrainNames = {
    "Handstands", "Situps", "Pushups", "Pushup", "Situp", "Handstand",
    "Dumbbell", "Barbell", "Training"
}

local function nameMatchExact(toolName, list)
    local t = string.lower(toolName or "")
    for _, n in ipairs(list) do
        if t == string.lower(n) then return true end
    end
    return false
end

local function nameMatchLoose(toolName, list)
    local t = string.lower(toolName or "")
    for _, n in ipairs(list) do
        local ln = string.lower(n)
        if t == ln or t:find(ln, 1, true) then return true end
    end
    return false
end

function ML.unequipAll()
    local char = ML.LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:UnequipTools() end) end
end

function ML.equipPunch()
    local char = ML.LP.Character
    local bag = ML.LP:FindFirstChild("Backpack")
    if not char or not bag then return false end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") and nameMatchExact(v.Name, ML.PunchNames) then return true end
    end
    ML.unequipAll()
    for _, v in ipairs(bag:GetChildren()) do
        if v:IsA("Tool") and nameMatchExact(v.Name, ML.PunchNames) then
            v.Parent = char
            return true
        end
    end
    return false
end

function ML.equipWeight()
    local char = ML.LP.Character
    local bag = ML.LP:FindFirstChild("Backpack")
    if not char or not bag then return false end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") and nameMatchLoose(v.Name, ML.WeightNames) then return true end
    end
    ML.unequipAll()
    for _, v in ipairs(bag:GetChildren()) do
        if v:IsA("Tool") and nameMatchLoose(v.Name, ML.WeightNames) then
            v.Parent = char
            return true
        end
    end
    return false
end

function ML.equipTrain()
    local char = ML.LP.Character
    local bag = ML.LP:FindFirstChild("Backpack")
    if not char or not bag then return false end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") and nameMatchLoose(v.Name, ML.TrainNames) then return true end
    end
    ML.unequipAll()
    for _, v in ipairs(bag:GetChildren()) do
        if v:IsA("Tool") and nameMatchLoose(v.Name, ML.TrainNames) then
            v.Parent = char
            return true
        end
    end
    return ML.equipWeight()
end

function ML.fireRep()
    local rem = ML.Remotes.muscleEvent
    if rem then pcall(function() rem:FireServer("rep") end) end
end

function ML.fireRebirth()
    local rem = ML.Remotes.rebirthRemote
    if rem then
        pcall(function()
            if rem:IsA("RemoteFunction") then rem:InvokeServer("rebirthRequest")
            else rem:FireServer("rebirthRequest") end
        end)
    end
end

function ML.getHRP()
    local c = ML.LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

function ML.getHum()
    local c = ML.LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

ML.RockNames = {
    "Rock", "Golden", "Legends", "Legend", "Muscle King", "King",
    "Punching", "Training", "Tiny", "Frost", "Frozen", "Eternal",
    "Mythical", "Mythic", "Green", "Jungle", "Ancient", "Strength",
    "Durability", "Mountain", "White Rock", "Large"
}

print("[ML] parte1 ready | Punch-only | Weight-only | train | " .. ML.Version)
